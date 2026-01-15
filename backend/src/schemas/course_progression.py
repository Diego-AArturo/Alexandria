from __future__ import annotations

from pydantic import BaseModel, Field


class ProgressStorage(BaseModel):
    user_id: int = Field(..., description="User identifier")
    course_id: int = Field(..., description="Course identifier")
    current_unit: int = Field(..., description="Current unit the user is on")
    current_concept: int = Field(..., description="Current concept the user is on")
    current_question: int = Field(..., description="Current question the user is on")
    completion_percentage: float = Field(
        ..., description="Course completion percentage"
    )



