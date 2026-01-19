from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import EmailStr
from sqlalchemy import insert, select, update
from sqlalchemy.exc import SQLAlchemyError, IntegrityError
from sqlalchemy.orm import Session
from loguru import logger

from src.models.database import get_db
from src.models.tables import users
from src.schemas.users import UserCreate, UserData
from src.deps.auth import hash_password

router = APIRouter(prefix="/users", tags=["Users"])

@router.post(
    "/",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def create_user(
    payload: UserCreate, db: Session = Depends(get_db)
) -> UserData:

    data = payload.model_dump()
    if not data.get("google_uid") and not data.get("password"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password is required when google_uid is not provided",
        )

    password_hash = (
        hash_password(data["password"]) if data.get("password") else None
    )
    data.pop("password", None)

    try:
        insert_stmt = (
            insert(users)
            .values(
                google_uid=data.get("google_uid"),
                email=data["email"],
                name=data["name"],
                profile_photo=data.get("profile_photo"),
                password_hash=password_hash,
            )
            .returning(users)
        )

        logger.info("Creating user with google_uid=%s", payload.google_uid)

        row = db.execute(insert_stmt).mappings().one()
        db.commit()

    except IntegrityError as exc:
        db.rollback()
        logger.exception("Failed to create user")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with provided identifiers already exists",
        ) from exc
    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to create user")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user",
        ) from exc

    return UserData(**row)


@router.get(
    "/by-email",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def get_user_by_email(
    email: EmailStr, db: Session = Depends(get_db)
) -> UserData:

    stmt = select(users).where(users.c.email == email).limit(1)

    row = db.execute(stmt).mappings().one_or_none()

    if not row:
        logger.warning("User not found with email=%s", email)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return UserData(**row)


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

    row = db.execute(stmt).mappings().one_or_none()

    if not row:
        logger.warning("User not found with google_uid=%s", google_uid)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return UserData(**row)


@router.put(
    "/{google_uid}",
    response_model=UserData,
    status_code=status.HTTP_200_OK,
)
async def update_user(
    google_uid: str,
    payload: UserCreate,
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

        update_values = {
            "email": data["email"],
            "name": data["name"],
            "profile_photo": data.get("profile_photo"),
        }
        if data.get("password"):
            update_values["password_hash"] = hash_password(data["password"])

        update_stmt = (
            update(users)
            .where(users.c.id == existing_id)
            .values(**update_values)
        )

        logger.info("Updating user with google_uid=%s", google_uid)

        db.execute(update_stmt)
        db.commit()

    except IntegrityError as exc:
        db.rollback()
        logger.exception("Failed to update user")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Another user already has these identifiers",
        ) from exc
    except SQLAlchemyError as exc:
        db.rollback()
        logger.exception("Failed to update user")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update user",
        ) from exc

    data.pop("password", None)
    return UserData(**data, google_uid=google_uid)
