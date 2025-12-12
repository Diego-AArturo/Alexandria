from __future__ import annotations

import json
from typing import Any, Dict, List, Literal, Optional

from dotenv import load_dotenv
from crewai import Crew, Agent, Task
from crewai.crews.crew_output import CrewOutput
from pydantic import BaseModel
from loguru import logger

try:
    from llm_config import build_gemini_llm
    from execution_limits import agent_limits, crew_limits
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.agents.llm_config import build_gemini_llm  # type: ignore
    from src.agents.execution_limits import agent_limits, crew_limits  # type: ignore

try:
    from utils.json_utils import extract_json_dict
except ModuleNotFoundError:  # pragma: no cover - fallback for package imports
    from src.utils.json_utils import extract_json_dict  # type: ignore

load_dotenv()

the_one_llm = build_gemini_llm(1600)

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
                challenge learners just enough to keep them engaged while ensuring they always understand why 
                something is right or wrong. You blend pedagogy, clarity, and motivation — every question feels 
                like a friendly mini-challenge that teaches by doing.
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
    Questions must be simple, mobile-friendly, concept-focused, and aligned with the unit’s objectives.
    Use only the three allowed question types:
    - multiple_choice
    - true_false
    - fill_in_blank
    Each question must reinforce understanding through immediate explanatory feedback.
    Follow the learner’s language preferences, tone, and user_level as indicated in additional_context.
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


def run_question_generation(topic: str, units: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    crew = create_question_generation_crew()
    logger.info("Question crew: generating questions for %s units on topic=%s", len(units), topic)
    inputs = [
        {"item_name": f"unit_{i+1}", "topic": topic, "unit_data": unit}
        for i, unit in enumerate(units)
    ]
    results = crew.kickoff_for_each(inputs=inputs)
    logger.info("Question crew: completed generation for all units")
    return _format_question_outputs(results)


# if __name__ == "__main__":
#     units_json = "outputs/unit_generation.json"
#     topic_json = "outputs/topic_extraction.json"

#     with open(units_json, "r", encoding="utf-8") as f:
#         units_data = json.load(f)

#     with open(topic_json, "r", encoding="utf-8") as f:
#         topic_data = json.load(f)

#     payload = run_question_generation(topic_data["learning_topic"], units_data["units"])
#     print(json.dumps(payload, indent=2, ensure_ascii=False))
