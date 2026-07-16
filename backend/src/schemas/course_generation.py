from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, List, Literal

from pydantic import BaseModel, Field

JobStatusLiteral = Literal["queued", "processing", "partial", "completed", "failed"]


class CourseGenerationRequest(BaseModel):
    prompt: str = Field(..., description="End-user natural language goal for the course")
    user_id: int | None = Field(
        None, description="Optional user id to own the generated course"
    )
    expertise_level: int = Field(
        3,
        ge=1,
        le=5,
        description=(
            "Learner expertise level from 1 (complete beginner) to 5 (domain expert). "
            "Controls depth, rigor, vocabulary, and assumed background knowledge."
        ),
    )


class CourseGenerationResponse(BaseModel):
    topic: Dict[str, Any]
    units: Dict[str, Any]
    concepts: List[Dict[str, Any]]
    questions: List[Dict[str, Any]]


class CourseGenerationJobResponse(BaseModel):
    job_id: int = Field(..., description="Identifier of the async job")
    status: JobStatusLiteral = Field(..., description="Job state for the generation task")
    progress: float | None = Field(None, ge=0, le=100, description="Completion percentage")
    course_id: int | None = Field(
        None, description="Identifier of the stored course payload when completed"
    )
    error: str | None = Field(None, description="Error message when status=failed")


class CourseGenerationJobStatusResponse(CourseGenerationJobResponse):
    pass


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

