from __future__ import annotations

from typing import Any, List

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, status
from sqlalchemy import func, insert, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from loguru import logger

try:
    from ...agents.orchestatior_agents import (
        get_course_generation_crews,
        get_course_structure,
        get_unit_content,
    )
except ModuleNotFoundError:  # pragma: no cover - fallback for direct script execution
    from src.agents.orchestatior_agents import (  # type: ignore
        get_course_generation_crews,
        get_course_structure,
        get_unit_content,
    )

from src.models.database import get_db, session_scope
from src.models.tables import courses, jobs, progress
from src.schemas.course_generation import (
    CourseGenerationRequest,
    CourseGenerationResponse,
    CourseGenerationJobResponse,
    CourseGenerationJobStatusResponse,
    CourseGenerationStoredResponse,
    UserCourseList,
)

router = APIRouter(prefix="/ai", tags=["ai"])

JOB_TYPE_COURSE_GENERATION = "course_generation"
JOB_STATUS_QUEUED = "queued"
JOB_STATUS_PROCESSING = "processing"
JOB_STATUS_PARTIAL = "partial"
JOB_STATUS_COMPLETED = "completed"
JOB_STATUS_FAILED = "failed"


def _update_job(job_id: int, **values: Any) -> None:
    """Persist job updates with a fresh session to avoid stale connections in background tasks."""
    if not values:
        return
    values["updated_at"] = func.now()
    with session_scope() as db:
        db.execute(jobs.update().where(jobs.c.id == job_id).values(**values))


def _process_course_generation_job(job_id: int, prompt: str, user_id: int | None) -> None:
    """Run the long-running generation pipeline and persist results progressively."""
    _update_job(job_id, status=JOB_STATUS_PROCESSING, progress=5)
    try:
        logger.info("Job {}: generating course structure", job_id)
        topic_payload, units_payload, topic_value = get_course_structure(prompt)
        units_list: List[Any] = units_payload.get("units", [])
        total_units = len(units_list)
        _update_job(job_id, progress=10)

        if topic_payload.get("teachability") is False or total_units == 0:
            course_payload = CourseGenerationResponse(
                topic=topic_payload, units=units_payload, concepts=[], questions=[]
            ).model_dump()
            with session_scope() as db:
                course_id = db.execute(
                    insert(courses)
                    .values(course_data=course_payload, user_id=user_id)
                    .returning(courses.c.id)
                ).scalar_one()
                db.execute(
                    jobs.update()
                    .where(jobs.c.id == job_id)
                    .values(
                        status=JOB_STATUS_COMPLETED,
                        result_id=course_id,
                        progress=100,
                        updated_at=func.now(),
                    )
                )
            logger.info("Job {}: completed (unteachable) with course_id={}", job_id, course_id)
            return

        all_concepts: List[Any] = []
        all_questions: List[Any] = []
        course_id: int | None = None

        for i, unit in enumerate(units_list):
            logger.info("Job {}: generating content for unit {}/{}", job_id, i + 1, total_units)
            unit_concepts, unit_questions = get_unit_content(topic_value, unit)
            all_concepts.extend(unit_concepts)
            all_questions.extend(unit_questions)

            progress_pct = 10 + int(((i + 1) / total_units) * 85)
            course_payload = CourseGenerationResponse(
                topic=topic_payload,
                units=units_payload,
                concepts=all_concepts,
                questions=all_questions,
            ).model_dump()

            with session_scope() as db:
                if course_id is None:
                    course_id = db.execute(
                        insert(courses)
                        .values(course_data=course_payload, user_id=user_id)
                        .returning(courses.c.id)
                    ).scalar_one()
                    db.execute(
                        jobs.update()
                        .where(jobs.c.id == job_id)
                        .values(
                            status=JOB_STATUS_PARTIAL,
                            result_id=course_id,
                            progress=progress_pct,
                            updated_at=func.now(),
                        )
                    )
                else:
                    db.execute(
                        courses.update()
                        .where(courses.c.id == course_id)
                        .values(course_data=course_payload)
                    )
                    db.execute(
                        jobs.update()
                        .where(jobs.c.id == job_id)
                        .values(
                            status=JOB_STATUS_PARTIAL,
                            progress=progress_pct,
                            updated_at=func.now(),
                        )
                    )
            logger.info("Job {}: unit {}/{} saved", job_id, i + 1, total_units)

        with session_scope() as db:
            db.execute(
                jobs.update()
                .where(jobs.c.id == job_id)
                .values(status=JOB_STATUS_COMPLETED, progress=100, updated_at=func.now())
            )
        logger.info("Job {}: completed with course_id={}", job_id, course_id)
    except Exception as exc:  # pragma: no cover - runtime safety
        logger.exception("Job %s failed while generating course", job_id)
        _update_job(job_id, status=JOB_STATUS_FAILED, error=str(exc), progress=100)


@router.post(
    "/courses",
    response_model=CourseGenerationJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def enqueue_course_generation(
    payload: CourseGenerationRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
) -> CourseGenerationJobResponse:
    logger.info("Queueing course generation for prompt: {!r}", payload.prompt[:80])
    insert_stmt = (
        insert(jobs)
        .values(
            type=JOB_TYPE_COURSE_GENERATION,
            status=JOB_STATUS_QUEUED,
            progress=0,
        )
        .returning(jobs.c.id)
    )

    try:
        job_id = db.execute(insert_stmt).scalar_one()
        db.commit()
    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to enqueue course generation job")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to enqueue job: {exc}",
        ) from exc

    background_tasks.add_task(_process_course_generation_job, job_id, payload.prompt, payload.user_id)
    return CourseGenerationJobResponse(job_id=job_id, status=JOB_STATUS_QUEUED, progress=0)


@router.get(
    "/courses/status/{job_id}",
    response_model=CourseGenerationJobStatusResponse,
    status_code=status.HTTP_200_OK,
)
async def get_course_generation_status(
    job_id: int, db: Session = Depends(get_db)
) -> CourseGenerationJobStatusResponse:
    logger.info("Checking status for job_id=%s", job_id)
    stmt = (
        select(
            jobs.c.id,
            jobs.c.status,
            jobs.c.progress,
            jobs.c.result_id,
            jobs.c.error,
        )
        .where(jobs.c.id == job_id)
        .limit(1)
    )
    row = db.execute(stmt).one_or_none()
    if not row:
        logger.warning("Job with id=%s was not found", job_id)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Job with id {job_id} was not found",
        )

    progress_value = float(row.progress) if row.progress is not None else None
    return CourseGenerationJobStatusResponse(
        job_id=row.id,
        status=row.status,
        progress=progress_value,
        course_id=row.result_id,
        error=row.error,
    )


@router.get(
    "/courses/{course_id}",
    response_model=CourseGenerationStoredResponse,
    status_code=status.HTTP_200_OK,
)
async def get_generated_course(
    course_id: int, db: Session = Depends(get_db)
) -> CourseGenerationStoredResponse:
    logger.info("Fetching generated course with id=%s", course_id)
    stmt = (
        select(courses.c.id, courses.c.course_data, courses.c.created_at)
        .where(courses.c.id == course_id)
        .limit(1)
    )
    row = db.execute(stmt).one_or_none()
    if not row:
        logger.warning("Course with id=%s was not found", course_id)
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


@router.get(
    "/generate-courselist/{user_id}",
    response_model=UserCourseList,
    status_code=status.HTTP_200_OK,
)
async def get_courses_user(
    user_id: int, db: Session = Depends(get_db)
) -> UserCourseList:
    logger.info("Fetching generated courses for user_id=%s", user_id)
    stmt = (
        select(
            courses.c.id,
            courses.c.course_data,
            courses.c.created_at,
            func.coalesce(progress.c.completion_percentage, 0).label("completion_percentage"),
        )
        .select_from(
            courses.outerjoin(
                progress,
                (progress.c.course_id == courses.c.id)
                & (progress.c.user_id == courses.c.user_id),
            )
        )
        .where(courses.c.user_id == user_id)
        .order_by(courses.c.created_at.desc())
    )
    rows = db.execute(stmt).all()

    courses_out = [
        {
            "course_id": row.id,
            "learning_topic": row.course_data["topic"]["learning_topic"],
            "completion_percentage": row.completion_percentage,
        }
        for row in rows
    ]

    return UserCourseList(courses=courses_out)
