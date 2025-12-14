from fastapi import APIRouter
from pydantic import BaseModel

from src.deps.auth import verify_google_token_and_get_user, create_access_token

router = APIRouter()

class GoogleTokenSchema(BaseModel):
    id_token: str

@router.post("/google/callback")
async def google_callback(body: GoogleTokenSchema):
    """
    Verifica el id_token de Google, crea/obtiene usuario y devuelve JWT.
    """
    user = await verify_google_token_and_get_user(body.id_token)
    token = create_access_token({"sub": user.get("email") if isinstance(user, dict) else getattr(user, "email"), "role": user.get("role") if isinstance(user, dict) else getattr(user, "role")})
    return {"access_token": token, "token_type": "bearer"}
