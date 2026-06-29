# -*- coding: utf-8 -*-
from __future__ import annotations

from typing import Any, Dict, List, Tuple
from loguru import logger

try:
    from .course_generation import run_course_generation
    from .concept_generation import run_concept_generation
    from .question_generation import run_question_generation
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.course_generation import run_course_generation  # type: ignore
    from backend.src.agents.concept_generation import run_concept_generation  # type: ignore
    from backend.src.agents.question_generation import run_question_generation  # type: ignore

# --- Expertise level constants ---

_EXPERTISE_LABELS: Dict[int, str] = {
    1: "Level 1 - Beginner",
    2: "Level 2 - Introductory",
    3: "Level 3 - Confident",
    4: "Level 4 - Advanced",
    5: "Level 5 - Expert",
}

_EXPERTISE_UNIT_INSTRUCTIONS: Dict[int, str] = {
    1: (
        "Complete first contact with the topic. Assume zero prior knowledge. "
        "Build from absolute fundamentals using simple language, basic concepts, and vivid everyday analogies. "
        "Avoid all jargon. Each unit should feel like a friendly first introduction."
    ),
    2: (
        "Learner has introductory awareness but needs to consolidate fundamentals. "
        "Reinforce core concepts clearly. Slightly more precise language is appropriate; "
        "avoid deep assumptions but do not over-simplify."
    ),
    3: (
        "Learner is confident with the basics and ready to deepen understanding. "
        "Introduce nuanced concepts, connections between ideas, and mild complexity. "
        "Language can be domain-appropriate; explanations should challenge gently."
    ),
    4: (
        "Learner has significant knowledge and expects professional-level rigour. "
        "Structure content as deep knowledge transfer comparable to graduate seminars or professional training. "
        "Assume strong background; focus on precision, edge cases, and advanced relationships."
    ),
    5: (
        "Learner is a domain expert testing the limits of their knowledge. "
        "Maximum depth and academic precision -comparable to research papers or high-level professional evaluations. "
        "Challenge subtle distinctions, complex trade-offs, and highest-order reasoning."
    ),
}

_EXPERTISE_CONCEPT_INSTRUCTIONS: Dict[int, str] = {
    1: (
        "Write extremely accessible micro-explanations. Assume no background whatsoever. "
        "Use everyday analogies, concrete examples, and very short sentences. Zero jargon."
    ),
    2: (
        "Write clear foundational explanations that consolidate basics. "
        "Assume basic familiarity; treat each concept as a friendly review with gentle reinforcement."
    ),
    3: (
        "Write explanations that go beyond the surface. Connect ideas, introduce nuance, "
        "and gently challenge assumptions. Domain terms are welcome when clearly used."
    ),
    4: (
        "Write at professional depth. Precise domain language, connections to broader field knowledge, "
        "and attention to edge cases and subtleties. Expect an engaged, knowledgeable reader."
    ),
    5: (
        "Write at maximum rigor. Academic precision, complex inter-concept relationships, "
        "edge cases, and counter-examples. Expect critical engagement from a domain expert."
    ),
}

_EXPERTISE_QUESTION_INSTRUCTIONS: Dict[int, str] = {
    1: (
        "Questions must be accessible and test basic recall or simple understanding. "
        "Stems must be crystal-clear; distractors obvious. No complex reasoning required."
    ),
    2: (
        "Questions test comprehension of fundamentals with mild application. "
        "Some inference required; avoid highly abstract or complex scenarios."
    ),
    3: (
        "Questions should challenge deeper understanding. Require analysis, connections between "
        "concepts, and evaluation of options. Distractors should be plausible."
    ),
    4: (
        "Questions require professional-level reasoning. Include nuanced scenarios, domain-specific "
        "accuracy, and situations where multiple answers seem plausible but only one is correct."
    ),
    5: (
        "Questions must be rigorous and demanding. Test edge cases, subtle distinctions, "
        "and highest-order thinking. Comparable to qualifying exams or advanced academic assessments."
    ),
}


def _expertise_label(level: int) -> str:
    return _EXPERTISE_LABELS.get(level, _EXPERTISE_LABELS[3])


def _expertise_unit_instruction(level: int) -> str:
    return _EXPERTISE_UNIT_INSTRUCTIONS.get(level, _EXPERTISE_UNIT_INSTRUCTIONS[3])


def _expertise_concept_instruction(level: int) -> str:
    return _EXPERTISE_CONCEPT_INSTRUCTIONS.get(level, _EXPERTISE_CONCEPT_INSTRUCTIONS[3])


def _expertise_question_instruction(level: int) -> str:
    return _EXPERTISE_QUESTION_INSTRUCTIONS.get(level, _EXPERTISE_QUESTION_INSTRUCTIONS[3])


# --- Helpers ---

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


def _format_covered_topics(covered_topics: List[str]) -> str:
    if not covered_topics:
        return "(none yet - this is the first unit)"
    return "\n".join(f"- {t}" for t in covered_topics)


def _format_thematic_points(unit: Dict[str, Any]) -> str:
    points: List[str] = unit.get("thematic_points", [])
    if not points:
        return "(thematic points not specified)"
    return "\n".join(f"{i + 1}. {p}" for i, p in enumerate(points))


def _format_previous_question_stems(stems: List[str]) -> str:
    if not stems:
        return "(none yet)"
    # Cap at 40 most recent to stay within token budget
    recent = stems[-40:]
    return "\n".join(f"- {s}" for s in recent)


def _extract_question_stems(unit_questions: List[Dict[str, Any]]) -> List[str]:
    stems: List[str] = []
    for wrapper in unit_questions:
        for q_unit in wrapper.get("units", []):
            for q in q_unit.get("questions", []):
                stem = q.get("stem", "").strip()
                if stem:
                    stems.append(stem)
    return stems


# --- Public API ---

def get_course_structure(
    user_prompt: str,
    expertise_level: int = 3,
) -> Tuple[Dict[str, Any], Dict[str, Any], str]:
    """Generate course topic and unit structure only (no concepts or questions)."""
    logger.info("Orchestrator: generating course structure for prompt (expertise_level=%s)", expertise_level)
    label = _expertise_label(expertise_level)
    instruction = _expertise_unit_instruction(expertise_level)
    topic_payload, units_payload = run_course_generation(user_prompt, label, instruction)
    _normalize_payload_titles(topic_payload, units_payload)
    topic_value = _extract_topic_value(topic_payload, units_payload)
    return topic_payload, units_payload, topic_value


def get_unit_content(
    topic_value: str,
    unit: Dict[str, Any],
    expertise_level: int = 3,
    covered_topics: List[str] | None = None,
    all_question_stems: List[str] | None = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Generate concepts and questions for a single unit with expertise calibration and memory."""
    if covered_topics is None:
        covered_topics = []
    if all_question_stems is None:
        all_question_stems = []

    label = _expertise_label(expertise_level)
    concept_instruction = _expertise_concept_instruction(expertise_level)
    question_instruction = _expertise_question_instruction(expertise_level)
    covered_str = _format_covered_topics(covered_topics)
    thematic_str = _format_thematic_points(unit)
    stems_str = _format_previous_question_stems(all_question_stems)

    concept_results = run_concept_generation(
        topic_value,
        [unit],
        expertise_label=label,
        expertise_instruction=concept_instruction,
        covered_topics_str=covered_str,
        thematic_points_str=thematic_str,
    )
    question_results = run_question_generation(
        topic_value,
        [unit],
        expertise_label=label,
        expertise_instruction=question_instruction,
        thematic_points_str=thematic_str,
        previous_question_stems_str=stems_str,
    )
    return concept_results, question_results


def get_course_generation_crews(user_prompt: str, expertise_level: int = 3) -> Dict[str, Any]:
    """Run the three crews sequentially and return in-memory payloads (legacy path)."""
    logger.info("Orchestrator: launching course generation crew")
    label = _expertise_label(expertise_level)
    unit_instruction = _expertise_unit_instruction(expertise_level)
    topic_payload, units_payload = run_course_generation(user_prompt, label, unit_instruction)
    _normalize_payload_titles(topic_payload, units_payload)

    units_list = units_payload.get("units", [])
    topic_value = _extract_topic_value(topic_payload, units_payload)

    if topic_payload.get("teachability") is False:
        return {"topic": topic_payload, "units": units_payload, "concepts": [], "questions": []}

    logger.info("Orchestrator: running concept generation (topic=%s, units=%s)", topic_value, len(units_list))

    covered_topics: List[str] = []
    all_question_stems: List[str] = []
    all_concepts: List[Dict[str, Any]] = []
    all_questions: List[Dict[str, Any]] = []

    for unit in units_list:
        unit_concepts, unit_questions = get_unit_content(
            topic_value, unit, expertise_level, covered_topics, all_question_stems
        )
        all_concepts.extend(unit_concepts)
        all_questions.extend(unit_questions)
        covered_topics.extend(unit.get("thematic_points", []))
        all_question_stems.extend(_extract_question_stems(unit_questions))

    logger.info("Orchestrator: generation completed")

    return {
        "prompt": user_prompt,
        "topic": topic_payload,
        "units": units_payload,
        "concepts": all_concepts,
        "questions": all_questions,
    }
