from __future__ import annotations

from typing import Any, Dict, List

from pydantic import BaseModel, Field


class CourseGenerationRequest(BaseModel):
    prompt: str = Field(..., description="End-user natural language goal for the course")


class CourseGenerationResponse(BaseModel):
    topic: Dict[str, Any]
    units: Dict[str, Any]
    concepts: List[Dict[str, Any]]
    questions: List[Dict[str, Any]]
