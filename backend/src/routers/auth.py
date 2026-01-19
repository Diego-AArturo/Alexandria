from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy import insert, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from src.deps.auth import create_access_token, hash_password, verify_password
from src.models.database import get_db
from src.models.tables import users


router = APIRouter(prefix="/auth", tags=["Auth"])


class GoogleTokenSchema(BaseModel):
    id_token: str


class RegisterSchema(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, description="Display name")
    password: str = Field(..., min_length=8, max_length=128)


class LoginSchema(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=1)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


def _issue_token(email: str) -> TokenResponse:
    token = create_access_token({"sub": email})
    return TokenResponse(access_token=token)


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register_user(payload: RegisterSchema, db: Session = Depends(get_db)) -> TokenResponse:
    """Crea un usuario local (sin Google) y devuelve el JWT."""
    try:
        existing = db.execute(
            select(users.c.id).where(users.c.email == payload.email)
        ).scalar_one_or_none()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already exists with this email",
            )

        insert_stmt = (
            insert(users)
            .values(
                email=payload.email,
                name=payload.name,
                password_hash=hash_password(payload.password),
            )
            .returning(users.c.email)
        )
        row = db.execute(insert_stmt).mappings().one()
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unable to create user with provided data",
        ) from exc

    return _issue_token(row["email"])


@router.post("/login", response_model=TokenResponse, status_code=status.HTTP_200_OK)
async def login(payload: LoginSchema, db: Session = Depends(get_db)) -> TokenResponse:
    """Autentica con email/password y devuelve el JWT."""
    row = (
        db.execute(
            select(
                users.c.email,
                users.c.password_hash,
            ).where(users.c.email == payload.email)
        )
        .mappings()
        .one_or_none()
    )

    if not row or not verify_password(payload.password, row.get("password_hash")):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    return _issue_token(row["email"])


@router.post("/google/callback", response_model=TokenResponse)
async def google_callback(body: GoogleTokenSchema, db: Session = Depends(get_db)) -> TokenResponse:
    """
    Verifica el id_token de Google, crea/actualiza el usuario y devuelve JWT.
    """
    try:
        idinfo = id_token.verify_oauth2_token(body.id_token, google_requests.Request())
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Google token"
        ) from exc

    email = idinfo.get("email")
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Google token missing email",
        )

    name = idinfo.get("name") or email.split("@")[0]
    google_uid = idinfo.get("sub")
    profile_photo = idinfo.get("picture")

    try:
        existing = (
            db.execute(select(users).where(users.c.email == email)).mappings().one_or_none()
        )

        if existing:
            # If the account existed without Google, attach the Google UID and keep name/photo up to date.
            if google_uid and not existing.get("google_uid"):
                db.execute(
                    update(users)
                    .where(users.c.id == existing["id"])
                    .values(
                        google_uid=google_uid,
                        name=name or existing["name"],
                        profile_photo=profile_photo or existing.get("profile_photo"),
                    )
                )
                db.commit()
            user_email = existing["email"]
        else:
            insert_stmt = (
                insert(users)
                .values(
                    email=email,
                    name=name,
                    google_uid=google_uid,
                    profile_photo=profile_photo,
                )
                .returning(users.c.email)
            )
            row = db.execute(insert_stmt).mappings().one()
            db.commit()
            user_email = row["email"]

    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to persist Google user",
        ) from exc

    return _issue_token(user_email)
