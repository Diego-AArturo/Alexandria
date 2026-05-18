from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Literal, Optional

from dotenv import load_dotenv
from crewai import Crew, Agent, Task
from crewai.crews.crew_output import CrewOutput
from pydantic import BaseModel
from loguru import logger

try:
    from llm_config import build_llm
    from execution_limits import agent_limits, crew_limits
    from fill_blank_extraction import transform_questions
    from fill_blank_reviewer import run_fill_blank_check
    from fill_blank_reintegration import run_fill_blank_reintegration
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.llm_config import build_llm  # type: ignore
    from src.agents.execution_limits import agent_limits, crew_limits  # type: ignore
    from src.agents.fill_blank_extraction import transform_questions  # type: ignore
    from src.agents.fill_blank_reviewer import run_fill_blank_check  # type: ignore
    from src.agents.fill_blank_reintegration import run_fill_blank_reintegration  # type: ignore

try:
    from utils.json_utils import extract_json_dict
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.utils.json_utils import extract_json_dict  # type: ignore

load_dotenv()

the_one_llm = build_llm(1600)

class QuestionModel(BaseModel):
    type: Literal["multiple_choice", "true_false", "fill_in_blank"]
    stem: str
    options: Optional[List[str]] = None      # only for multiple_choice or fill_in_blank
    answer: str                               # for fill_in_blank: comma-separated words
    explanation_correct: str
    explanation_incorrect: str


class QuestionOutputModel(BaseModel):
    unit_title: str
    questions: List[QuestionModel]


question_engineer = Agent(
    role=       """AI Educational Question Designer""",

    goal=       """Generate a set of inquiry-driven, feedback-rich questions 
                for each unit that reinforce understanding through interaction and curiosity.
                """,

    backstory=  """
                You are a master of active learning. You design smart, accessible questions that 
                challenge learners just enough to keep them engage while ensuring they get challenged and adquire new knowledge while also understanding why 
                something is right or wrong. You blend pedagogy, clarity, profound knowledge and motivation — every question feels 
                like a mini-challenge that teaches by doing.
                """,
    verbose=False,
    llm=the_one_llm,
    **agent_limits()
)


question_generation_task = Task(
    description="""
    Topic information: {topic}
    Unit information: {unit_data}
    
    Using both the topic information and unit information with its
    description and objectives, generate a complete set of
    short, pedagogically sound questions presented in microlearning format.
    Questions must be simple yet conceptually challenging, mobile-friendly, concept-focused, and aligned with the unit’s objectives.
    Use only the three allowed question types:
    - multiple_choice
    - true_false
    - fill_in_blank
    Each question must reinforce understanding through immediate explanatory feedback.
    Follow the learner’s language preferences, tone, and user_level as indicated in the topic information
    """,
    expected_output="""
        Return ONLY valid JSON in the following structure:

        {
          "unit_title": "string",
          "questions": [
            {
              "type": "multiple_choice | true_false | fill_in_blank",
              "stem": "short question text",
              "options": ["A", "B", "C", ...],   // only for multiple_choice or fill_in_blank
              "answer": "string",                // for fill_in_blank: comma-separated correct words
              "explanation_correct": "string",
              "explanation_incorrect": "string"
            }
          ]
        }
        STRICT RULES:
        - Output must ALWAYS start with { "units": [...] } as the root.
        - Each unit must contain:
            - unit_title
            - questions (array)
        - Each question may only contain the keys:
            - type
            - stem
            - options (only for multiple_choice or fill_in_blank)
            - answer
            - explanation_correct
            - explanation_incorrect
        - NO other keys are allowed (no id, no difficulty, no snippet, no metadata).
        - Include at least 10 questions, and only use the 3 allowed types.
        - Keep stems and explanations under 40 words.
        - For fill_in_blank:
            - The "options" array must list the missing words.
            - The "answer" field must contain the correct words as a single comma-separated string (e.g., "species,breeds").
    """,
    agent=question_engineer,
    output_file="outputs/question_generation_{item_name}.json",
    llm=the_one_llm
)





def create_question_generation_crew() -> Crew:
    return Crew(
        agents=[question_engineer],
        tasks=[question_generation_task],
        **crew_limits()
    )


def _format_question_outputs(results: List[CrewOutput]) -> List[Dict[str, Any]]:
    formatted: List[Dict[str, Any]] = []
    for output in results:
        if output.json_dict:
            formatted.append(output.json_dict)
        elif output.pydantic:
            formatted.append(output.pydantic.model_dump())
        else:
            recovered = extract_json_dict(output.raw)
            if recovered:
                logger.warning("Question crew: recovered JSON from raw output after format violation")
                formatted.append(recovered)
            else:
                formatted.append({"raw": output.raw})
    return formatted


def _write_json_output(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


def _deduplicate_fill_blank_options(options: Any) -> List[Any]:
    if not isinstance(options, list):
        return []

    seen: set[str] = set()
    deduplicated: List[Any] = []
    for option in options:
        normalized = str(option).strip()
        if normalized in seen:
            continue
        seen.add(normalized)
        deduplicated.append(option)
    return deduplicated


def _finalize_fill_blank_questions(payload: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    finalized_payload: List[Dict[str, Any]] = []

    for item in payload:
        merged_item = dict(item)
        merged_units: List[Dict[str, Any]] = []

        for unit in item.get("units", []):
            merged_unit = dict(unit)
            merged_questions: List[Dict[str, Any]] = []

            for question in unit.get("questions", []):
                updated_question = dict(question)
                if updated_question.get("type") == "fill_in_blank":
                    updated_question["options"] = _deduplicate_fill_blank_options(
                        updated_question.get("options")
                    )
                    stem = str(updated_question.get("stem") or "")
                    options = updated_question.get("options") or []
                    if len(options) <= 1:
                        continue
                    if "___" not in stem:
                        continue
                    if stem.count("___") == len(options):
                        continue
                merged_questions.append(updated_question)

            merged_unit["questions"] = merged_questions
            merged_units.append(merged_unit)

        merged_item["units"] = merged_units
        finalized_payload.append(merged_item)

    return finalized_payload


def _run_fill_blank_pipeline(question_payload: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    backend_root = Path(__file__).resolve().parents[2]
    outputs_root = backend_root / "outputs"

    question_path = outputs_root / "question.json"
    answered_fill_blank_path = outputs_root / "fill_blank_answered_question.json"
    indexed_questions_path = outputs_root / "question_indexed.json"
    reviewed_answered_path = outputs_root / "fill_blank_answered_reviewed.json"
    reviewed_output_path = outputs_root / "fill_blank_question_reviewed.json"

    _write_json_output(question_path, question_payload)

    answered_payload, indexed_payload = transform_questions(question_payload)
    _write_json_output(answered_fill_blank_path, answered_payload)
    _write_json_output(indexed_questions_path, indexed_payload)

    reviewed_payload = run_fill_blank_check(answered_payload)
    _write_json_output(reviewed_answered_path, reviewed_payload)

    reintegrated_payload = run_fill_blank_reintegration(indexed_payload, reviewed_payload)
    finalized_payload = _finalize_fill_blank_questions(reintegrated_payload)
    _write_json_output(reviewed_output_path, finalized_payload)

    logger.info("Question crew: fill-blank pipeline completed")
    return finalized_payload


def run_question_generation(topic: str, units: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    crew = create_question_generation_crew()
    logger.info("Question crew: generating questions for %s units on topic=%s", len(units), topic)
    inputs = [
        {"item_name": f"unit_{i+1}", "topic": topic, "unit_data": unit}
        for i, unit in enumerate(units)
    ]
    results = crew.kickoff_for_each(inputs=inputs)
    logger.info("Question crew: completed generation for all units")
    question_payload = _format_question_outputs(results)
    return _run_fill_blank_pipeline(question_payload)

# Comment if working with full flow

# if __name__ == "__main__":
#     units_json = "outputs/unit_generation.json"
#     topic_json = "outputs/topic_extraction.json"

#     with open(units_json, "r", encoding="utf-8") as f:
#         units_data = json.load(f)

#     with open(topic_json, "r", encoding="utf-8") as f:
#         topic_data = json.load(f)

#     payload = run_question_generation(topic_data["learning_topic"], units_data["units"])
#     print(json.dumps(payload, indent=2, ensure_ascii=False))

# TEMP DEBUG BLOCK - DELETE LATER
# Purpose: quick independent test for this file using backend/outputs examples
if __name__ == "__main__":
    project_root = Path(__file__).resolve().parents[2]  # backend/
    units_json = project_root / "outputs" / "unit_generation.json"
    topic_json = project_root / "outputs" / "topic_extraction.json"

    with open(units_json, "r", encoding="utf-8") as f:
        units_data = json.load(f)

    with open(topic_json, "r", encoding="utf-8") as f:
        topic_data = json.load(f)

    crew = create_question_generation_crew()
    test_inputs = [
        {"item_name": f"unit_{i+1}", "topic": topic_data["learning_topic"], "unit_data": unit}
        for i, unit in enumerate(units_data["units"])
    ]

    # Print native CrewOutput objects and key fields for inspection
    crew_results = crew.kickoff_for_each(inputs=test_inputs)
    print(f"Total CrewOutput objects: {len(crew_results)}")
    for idx, output in enumerate(crew_results, start=1):
        print(f"\n--- CrewOutput #{idx} ---")
        print("raw:")
        print(output.raw)
        print("json_dict:")
        print(json.dumps(output.json_dict, indent=2, ensure_ascii=False))
        print("pydantic:")
        if output.pydantic:
            print(output.pydantic.model_dump_json(indent=2))
        else:
            print(None)

    # Print normalized output produced by existing formatter
    payload = _format_question_outputs(crew_results)
    print("\n--- Formatted payload ---")
    print(json.dumps(payload, indent=2, ensure_ascii=False))
