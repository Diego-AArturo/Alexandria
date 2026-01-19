from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field, ConfigDict


class UserBase(BaseModel):
    email: EmailStr = Field(..., description="User email")
    name: str = Field(..., description="Natural name of the user")
    google_uid: str | None = Field(None, description="Google identifier when available")
    profile_photo: str | None = Field(None, description="Profile photo URL")


class UserCreate(UserBase):
    password: str | None = Field(
        None,
        min_length=8,
        max_length=128,
        description="Required when google_uid is not provided",
    )


class UserData(UserBase):
    id: int | None = Field(None, description="User identifier")
    model_config = ConfigDict(from_attributes=True)
