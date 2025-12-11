from __future__ import annotations

from fastapi import APIRouter, HTTPException, status

try:
    from ...agents.orchestatior_agents import get_course_generation_crews
except ModuleNotFoundError:  # pragma: no cover - fallback for direct script execution
    from src.agents.orchestatior_agents import get_course_generation_crews  # type: ignore

from schemas.course_generation import (
    CourseGenerationRequest,
    CourseGenerationResponse,
)

router = APIRouter(prefix="/ai", tags=["ai"])


@router.post(
    "/course-generation",
    response_model=CourseGenerationResponse,
    status_code=status.HTTP_200_OK,
)
async def generate_course(payload: CourseGenerationRequest) -> CourseGenerationResponse:
    try:
        result = get_course_generation_crews(payload.prompt)
    except Exception as exc:  # pragma: no cover - runtime sanitization
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Course generation failed: {exc}",
        ) from exc

    return CourseGenerationResponse(**result)
