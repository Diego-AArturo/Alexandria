from __future__ import annotations

from typing import Any, Dict

try:
    from .course_generation import run_course_generation
    from .concept_gen_testing import run_concept_generation
    from .question_gen_testing import run_question_generation
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.course_generation import run_course_generation  # type: ignore
    from src.agents.concept_gen_testing import run_concept_generation  # type: ignore
    from src.agents.question_gen_testing import run_question_generation  # type: ignore


def _extract_topic_value(topic_payload: Dict[str, Any], units_payload: Dict[str, Any]) -> str:
    topic = topic_payload.get("learning_topic")
    if not topic:
        topic = units_payload.get("learning_topic", "")
    return topic


def get_course_generation_crews(user_prompt: str) -> Dict[str, Any]:
    """Run the three crews sequentially and return in-memory payloads."""
    topic_payload, units_payload = run_course_generation(user_prompt)

    units_list = units_payload.get("units", [])
    topic_value = _extract_topic_value(topic_payload, units_payload)

    concept_results = run_concept_generation(topic_value, units_list)
    question_results = run_question_generation(topic_value, units_list)

    return {
        "topic": topic_payload,
        "units": units_payload,
        "concepts": concept_results,
        "questions": question_results,
    }
