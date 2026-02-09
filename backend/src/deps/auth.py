import os
import time
import jwt
import bcrypt
from typing import Callable, List, Mapping, Optional
from functools import wraps

from fastapi import Depends, Request, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy import select
from sqlalchemy.orm import Session

from src.models.database import SessionLocal
from src.models.tables import users


JWT_SECRET = os.getenv("JWT_SECRET", "change-me")
JWT_ALGORITHM = "HS256"
ACCESS_EXPIRE = int(os.getenv("ACCESS_EXPIRE", 60 * 60 * 24))  # seconds

security = HTTPBearer()


def create_access_token(data: dict, expires_in: int = ACCESS_EXPIRE) -> str:
    payload = data.copy()
    payload.update({"exp": int(time.time()) + expires_in})
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token expired")
    except Exception:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token")


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: Optional[str]) -> bool:
    if not password_hash:
        return False
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except ValueError:
        return False


def _get_token_from_header(request: Request) -> str:
    auth = request.headers.get("Authorization")
    if not auth:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing Authorization header")
    parts = auth.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid Authorization header")
    return parts[1]


def _normalize_user(row: Optional[Mapping]):
    if row is None:
        return None
    user = dict(row)
    role = user.get("role") or user.get("user_type")
    if role:
        user["role"] = role
    return user


def _get_user_by_email(email: str, db: Session):
    return (
        db.execute(select(users).where(users.c.email == email))
        .mappings()
        .one_or_none()
    )


def _get_user_from_token(token: str):
    payload = decode_token(token)
    subject = payload.get("sub")
    if not subject:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid token payload")

    with SessionLocal() as db:
        user = _get_user_by_email(subject, db)

    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "User not found")
    return _normalize_user(user)


async def get_current_user(request: Request):
    token = _get_token_from_header(request)
    return _get_user_from_token(token)


async def get_current_user_from_bearer(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    return _get_user_from_token(credentials.credentials)


def auth_required(func: Callable):
    """
    Decorador para proteger rutas. Anade current_user al kwargs.
    La ruta decorada debe aceptar (request: Request, current_user=...)
    """

    @wraps(func)
    async def wrapper(*args, **kwargs):
        request = kwargs.get("request", None)
        if request is None:
            for a in args:
                if isinstance(a, Request):
                    request = a
                    break
        if request is None:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "Request parameter required for auth check",
            )
        user = await get_current_user(request)
        kwargs["current_user"] = user
        return await func(*args, **kwargs)

    return wrapper


def role_required(roles: List[str]):
    """
    Decorador que verifica que current_user.role esta en roles.
    Usar junto a @auth_required o asegurarse que current_user esta disponible.
    """

    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            current_user = kwargs.get("current_user")
            if current_user is None:
                request = kwargs.get("request")
                if request is None:
                    for a in args:
                        if isinstance(a, Request):
                            request = a
                            break
                if request:
                    current_user = await get_current_user(request)
                else:
                    raise HTTPException(
                        status.HTTP_400_BAD_REQUEST,
                        "Request/current_user required for role check",
                    )
            role = (
                current_user.get("role")
                if isinstance(current_user, dict)
                else getattr(current_user, "role", None)
            )
            if role not in roles:
                raise HTTPException(
                    status.HTTP_403_FORBIDDEN, "Insufficient permissions"
                )
            return await func(*args, **kwargs)

        return wrapper

    return decorator
