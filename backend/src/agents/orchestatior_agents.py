from __future__ import annotations

from typing import Any, Dict
from loguru import logger

try:
    from .course_generation import run_course_generation
    from .concept_generation import run_concept_generation
    from .question_generation import run_question_generation
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.course_generation import run_course_generation  # type: ignore
    from backend.src.agents.concept_generation import run_concept_generation  # type: ignore
    from backend.src.agents.question_generation import run_question_generation  # type: ignore


def _extract_topic_value(topic_payload: Dict[str, Any], units_payload: Dict[str, Any]) -> str:
    topic = topic_payload.get("learning_topic")
    if not topic:
        topic = units_payload.get("learning_topic", "")
    return topic


def _title_case_words(value: str) -> str:
    return " ".join(word.capitalize() for word in value.split())


def _normalize_payload_titles(topic_payload: Dict[str, Any], units_payload: Dict[str, Any]) -> None:
    topic_value = topic_payload.get("learning_topic")
    if isinstance(topic_value, str) and topic_value.strip():
        topic_payload["learning_topic"] = topic_value[:1].upper() + topic_value[1:]

    units_list = units_payload.get("units", [])
    if isinstance(units_list, list):
        for unit in units_list:
            if not isinstance(unit, dict):
                continue
            unit_title = unit.get("unit_title")
            if isinstance(unit_title, str) and unit_title.strip():
                unit["unit_title"] = unit_title[:1].upper() + unit_title[1:]


def get_course_generation_crews(user_prompt: str) -> Dict[str, Any]:
    """Run the three crews sequentially and return in-memory payloads."""
    logger.info("Orchestrator: launching course generation crew")
    topic_payload, units_payload = run_course_generation(user_prompt)
    _normalize_payload_titles(topic_payload, units_payload)

    units_list = units_payload.get("units", [])
    topic_value = _extract_topic_value(topic_payload, units_payload)

    logger.info(
        "Orchestrator: running concept generation (topic=%s, units=%s)",
        topic_value,
        len(units_list),
    )

    if topic_payload.get("teachability") is False:
        return {"topic": topic_payload, "units": units_payload, "concepts": [], "questions": []}

    concept_results = run_concept_generation(topic_value, units_list)
    logger.info("Orchestrator: concept generation completed")

    logger.info(
        "Orchestrator: running question generation (topic=%s, units=%s)",
        topic_value,
        len(units_list),
    )
    question_results = run_question_generation(topic_value, units_list)
    logger.info("Orchestrator: question generation completed")

    return {
        "prompt": user_prompt,
        "topic": topic_payload,
        "units": units_payload,
        "concepts": concept_results,
        "questions": question_results,
    }
