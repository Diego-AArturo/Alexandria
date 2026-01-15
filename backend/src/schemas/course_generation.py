from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Literal

from pydantic import BaseModel, Field


class CourseGenerationRequest(BaseModel):
    prompt: str = Field(..., description="End-user natural language goal for the course")


class CourseGenerationResponse(BaseModel):
    topic: Dict[str, Any]
    units: Dict[str, Any]
    concepts: List[Dict[str, Any]]
    questions: List[Dict[str, Any]]


class CourseGenerationJobResponse(BaseModel):
    course_id: int = Field(..., description="Identifier of the stored course payload")
    status: Literal["ok"] = Field(..., description="Signals the course data was persisted")


class CourseGenerationStoredResponse(BaseModel):
    course_id: int = Field(..., description="Identifier of the stored course payload")
    created_at: datetime | None = Field(None, description="Creation timestamp registered in the DB")
    course_data: CourseGenerationResponse = Field(
        ..., description="The previously generated curriculum data"
    )


class CourseListItem(BaseModel):
    course_id: int = Field(..., description="Identifier of the stored course")
    learning_topic: str = Field(..., description="Requested learning topic")
    completion_percentage: float = Field(..., description="Completion percentage of the course")


class UserCourseList(BaseModel):
    courses: List[CourseListItem] = Field(
        ..., description="Stored courses for the specified user"
    )

