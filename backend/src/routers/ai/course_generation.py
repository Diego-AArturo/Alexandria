from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import insert, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

try:
    from ...agents.orchestatior_agents import get_course_generation_crews
except ModuleNotFoundError:  # pragma: no cover - fallback for direct script execution
    from src.agents.orchestatior_agents import get_course_generation_crews  # type: ignore

from src.models.database import get_db
from src.models.tables import courses
from src.schemas.course_generation import (
    CourseGenerationRequest,
    CourseGenerationResponse,
    CourseGenerationJobResponse,
    CourseGenerationStoredResponse,
)

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post(
    "/course-generation",
    response_model=CourseGenerationJobResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_course(
    payload: CourseGenerationRequest, db: Session = Depends(get_db)
) -> CourseGenerationJobResponse:
    try:
        result = get_course_generation_crews(payload.prompt)
    except Exception as exc:  # pragma: no cover - runtime sanitization
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Course generation failed: {exc}",
        ) from exc

    course_payload = CourseGenerationResponse(**result).model_dump()

    insert_stmt = insert(courses).values(course_data=course_payload).returning(courses.c.id)

    try:
        course_id = db.execute(insert_stmt).scalar_one()
        db.commit()
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to persist course data: {exc}",
        ) from exc

    return CourseGenerationJobResponse(course_id=course_id, status="ok")


@router.get(
    "/course-generation/{course_id}",
    response_model=CourseGenerationStoredResponse,
    status_code=status.HTTP_200_OK,
)
async def get_generated_course(
    course_id: int, db: Session = Depends(get_db)
) -> CourseGenerationStoredResponse:
    stmt = (
        select(courses.c.id, courses.c.course_data, courses.c.created_at)
        .where(courses.c.id == course_id)
        .limit(1)
    )
    row = db.execute(stmt).one_or_none()
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Course with id {course_id} was not found",
        )

    data = CourseGenerationResponse(**row.course_data)
    return CourseGenerationStoredResponse(
        course_id=row.id,
        created_at=row.created_at,
        course_data=data,
    )
