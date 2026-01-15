from __future__ import annotations

from pydantic import BaseModel, Field


class UserData(BaseModel):
    google_uid: str = Field(..., description="Google identifier")
    email: str = Field(..., description="User Gmail")
    name: str = Field(..., description="Natural name of the user")