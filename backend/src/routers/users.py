from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import insert, select, update
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from loguru import logger

from src.models.database import get_db
from src.models.tables import users
from src.schemas.users import UserData

router = APIRouter(prefix="/users", tags=["Users"])

@router.post(
    "/",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def create_user(
    payload: UserData, db: Session = Depends(get_db)
) -> UserData:

    data = payload.model_dump()

    try:
        insert_stmt = insert(users).values(**data)

        logger.info("Creating user with google_uid=%s", payload.google_uid)

        db.execute(insert_stmt)
        db.commit()

    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to create user")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create user: {exc}",
        ) from exc

    return payload


@router.get(
    "/{google_uid}",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def get_user(
    google_uid: str, db: Session = Depends(get_db)
) -> UserData:

    stmt = (
        select(users)
        .where(users.c.google_uid == google_uid)
        .limit(1)
    )

    row = db.execute(stmt).one_or_none()

    if not row:
        logger.warning("User not found with google_uid=%s", google_uid)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return UserData(**row._mapping)


@router.put(
    "/{google_uid}",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def update_user(
    google_uid: str,
    payload: UserData,
    db: Session = Depends(get_db),
) -> UserData:

    data = payload.model_dump()

    try:
        stmt = select(users.c.id).where(users.c.google_uid == google_uid)
        existing_id = db.execute(stmt).scalar_one_or_none()

        if not existing_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        update_stmt = (
            update(users)
            .where(users.c.id == existing_id)
            .values(
                email=data["email"],
                name=data["name"],
            )
        )

        logger.info("Updating user with google_uid=%s", google_uid)

        db.execute(update_stmt)
        db.commit()

    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to update user")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update user: {exc}",
        ) from exc

    return payload
