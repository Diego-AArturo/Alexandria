"""AI-specific API routes."""

from .course_generation import router as course_generation_router

__all__ = ["course_generation_router"]
