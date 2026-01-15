
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import insert, select, update
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from loguru import logger

from src.models.database import get_db
from src.models.tables import progress
from src.schemas.course_progression import ProgressStorage


router = APIRouter(prefix="/progress", tags=["Progress"])


@router.post(
    "/",
    response_model=ProgressStorage,
    status_code=status.HTTP_200_OK,
)

async def store_progress(
    payload: ProgressStorage, db: Session = Depends(get_db)
) -> ProgressStorage:

    data = payload.model_dump()

    # Convert ints to text for DB compatibility
    data["current_unit"] = str(data["current_unit"])
    data["current_concept"] = str(data["current_concept"])
    data["current_question"] = str(data["current_question"])

    try:
        # 1. Check if progress already exists
        stmt = select(progress.c.id).where(
            progress.c.user_id == payload.user_id,
            progress.c.course_id == payload.course_id,
        )

        existing_id = db.execute(stmt).scalar_one_or_none()

        if existing_id:
            # 2. UPDATE existing row
            update_stmt = (
                update(progress)
                .where(progress.c.id == existing_id)
                .values(
                    current_unit=data["current_unit"],
                    current_concept=data["current_concept"],
                    current_question=data["current_question"],
                    completion_percentage=data["completion_percentage"]
                )
            )

            logger.info("Updating progress for user=%s course=%s",
                        payload.user_id, payload.course_id)

            db.execute(update_stmt)

        else:
            # 3. INSERT new row
            insert_stmt = insert(progress).values(**data)

            logger.info("Creating new progress for user=%s course=%s",
                        payload.user_id, payload.course_id)

            db.execute(insert_stmt)

        db.commit()

    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to store progress")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to store progress: {exc}",
        ) from exc

    return payload



@router.get(
    "/",
    response_model=ProgressStorage,
    status_code=status.HTTP_200_OK,
)


async def get_progress(
    user_id: int, course_id: int, db: Session = Depends(get_db)
) -> ProgressStorage:

    stmt = (
        select(progress)
        .where(
            progress.c.user_id == user_id,
            progress.c.course_id == course_id,
        )
        .limit(1)
    )

    row = db.execute(stmt).one_or_none()

    if not row:
        logger.warning("Progress not found for user=%s course=%s", user_id, course_id)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Progress not found",
        )

    return ProgressStorage(**row._mapping)


