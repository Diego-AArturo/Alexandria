# -*- coding: utf-8 -*-
from __future__ import annotations

import json
from typing import Any, Dict, List

from dotenv import load_dotenv
from crewai import Crew, Agent, Task
from crewai.crews.crew_output import CrewOutput
from pydantic import BaseModel
from loguru import logger

try:
    from llm_config import build_llm
    from execution_limits import agent_limits, crew_limits
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.llm_config import build_llm  # type: ignore
    from src.agents.execution_limits import agent_limits, crew_limits  # type: ignore

try:
    from utils.json_utils import extract_json_dict
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.utils.json_utils import extract_json_dict  # type: ignore

load_dotenv()

the_one_llm = build_llm(max_tokens=2000)

class UnitModel(BaseModel):
    unit_title: str
    concepts: List[str]

class ConceptOutputModel(BaseModel):
    units: List[UnitModel]

concept_developer = Agent(
    role="""AI Concept and Example Generator""",

    goal="""
            For each unit, produce a rich set of short, engaging "concepts" -- factual reminders, analogies, 
            micro-explanations, and examples that bring the unit's objectives to life.
            """,

    backstory="""
            You are a creative educator who knows how to explain things simply. You turn abstract ideas into 
            relatable insights and connect with learners using friendly language. Your micro-lessons are like 
            conversations -- short, motivating, and full of vivid examples that make complex topics easy to remember.
            """,
    
    verbose=False,
    llm=the_one_llm,
    **agent_limits()
)


concept_generation_task = Task(
    description="""
    LEARNER EXPERTISE LEVEL: {expertise_level}
    CALIBRATION INSTRUCTION: {expertise_instruction}

    TOPICS ALREADY COVERED IN PREVIOUS UNITS (do NOT revisit, repeat, or re-explain any of these):
    {covered_topics}

    THIS UNIT'S THEMATIC POINTS (generate concepts that develop ONLY these topics):
    {thematic_points}

    Topic information: {topic}
    Unit information: {unit_data}

    Using the inputs above, generate a set of short, engaging, and pedagogically sound "concepts."
    Each concept must be a clear micro-explanation, factual reminder, relatable example, or analogy
    that directly develops one of the thematic points listed above.

    CRITICAL RULES:
    - Every concept must correspond to one of the thematic_points for this unit.
    - Do NOT produce concepts about topics already covered in previous units.
    - Apply the calibration instruction strictly: depth, vocabulary, and complexity must match the expertise level.
    - Keep tone mobile-friendly and motivational. No references to installations, tools, or setup.
    - Follow the learner's language preferences as indicated in the topic information.
    """,
    expected_output="""
    Return ONLY valid JSON with the following structure:
    {
        "units": [
        {
            "unit_title": "string",
            "concepts": ["string", "string", ...]
        }
        ]
    }

    Requirements:
    - Generate between 10 and 12 concepts for the given unit.
    - Each concept is under 60 words.
    - Each concept develops exactly one of the unit's thematic points.
    - Use a variety of forms: mini-examples, analogies, factual statements, clarifications.
    - No concept may revisit a topic from the covered_topics list.
    - Depth and vocabulary must reflect the expertise level calibration.

    IMPORTANT:
    - Return ONLY valid JSON.
    - Do NOT include trailing commas.
    - Do NOT include comments.
    - Do NOT include text before or after the JSON.

    FINAL CHECK BEFORE RESPONDING:
    - Validate the JSON syntax.
    - Remove any trailing commas.
    - Ensure all brackets and quotes are properly closed.
    - If the JSON is invalid, fix it silently and return ONLY the corrected JSON.
    """,
    agent=concept_developer,
    output_file="outputs/concept_generation_{item_name}.json",
)



def create_concept_generation_crew() -> Crew:
    return Crew(
        agents=[concept_developer],
        tasks=[concept_generation_task],
        **crew_limits()
    )


def _format_outputs(results: List[CrewOutput]) -> List[Dict[str, Any]]:
    parsed_results: List[Dict[str, Any]] = []
    for output in results:
        if output.json_dict:
            parsed_results.append(output.json_dict)
        elif output.pydantic:
            parsed_results.append(output.pydantic.model_dump())
        else:
            recovered = extract_json_dict(output.raw)
            if recovered:
                logger.warning("Concept crew: recovered JSON from raw output after format violation")
                parsed_results.append(recovered)
            else:
                parsed_results.append({"raw": output.raw})
    return parsed_results


def run_concept_generation(
    topic: str,
    units: List[Dict[str, Any]],
    expertise_label: str = "Level 3 - Confident",
    expertise_instruction: str = "Learner is comfortable with basics. Deepen knowledge and introduce nuanced concepts.",
    covered_topics_str: str = "(none yet -- this is the first unit)",
    thematic_points_str: str = "",
) -> List[Dict[str, Any]]:
    crew = create_concept_generation_crew()
    logger.info("Concept crew: generating concepts for %s units on topic=%s expertise=%s", len(units), topic, expertise_label)
    inputs = [
        {
            "item_name": f"unit_{i+1}",
            "topic": topic,
            "unit_data": unit,
            "expertise_level": expertise_label,
            "expertise_instruction": expertise_instruction,
            "covered_topics": covered_topics_str,
            "thematic_points": thematic_points_str,
        }
        for i, unit in enumerate(units)
    ]
    results = crew.kickoff_for_each(inputs=inputs)
    logger.info("Concept crew: completed generation for all units")
    return _format_outputs(results)

# # Comment if working with full flow
# if __name__ == "__main__":
#     units_json = "outputs/unit_generation.json"
#     topic_json = "outputs/topic_extraction.json"

#     with open(units_json, "r", encoding="utf-8") as f:
#         units_data = json.load(f)

#     with open(topic_json, "r", encoding="utf-8") as f:
#         topic_data = json.load(f)

#     payload = run_concept_generation(topic_data["learning_topic"], units_data["units"])
#     print(json.dumps(payload, indent=2, ensure_ascii=False))
