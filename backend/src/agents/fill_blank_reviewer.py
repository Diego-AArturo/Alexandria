from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Optional

from crewai import Agent, Crew, Task
from crewai.crews.crew_output import CrewOutput
from dotenv import load_dotenv
from loguru import logger
from pydantic import BaseModel




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

the_one_llm = build_llm(1600)
DEBUG_REVIEWER_INPUT_PATH = "outputs/fill_blank_reviewer_input.json"
DEBUG_REVIEWER_RAW_OUTPUT_PATH = "outputs/fill_blank_reviewer_raw_output.json"
DEBUG_REVIEWER_FORMATTED_OUTPUT_PATH = "outputs/fill_blank_reviewer_formatted_output.json"


class FillBlankQuestionModel(BaseModel):
    index: int
    stem: str


class FillBlankUnitModel(BaseModel):
    unit_title: str
    questions: List[FillBlankQuestionModel]


class FillBlankOutputModel(BaseModel):
    units: List[FillBlankUnitModel]
    


fill_blank_checker = Agent(
    role="Fill-in-the-Blank JSON Validator and Repairer",
    goal=(
        "Validate and minimally repair the JSON so that "
        "stems are grammatically correct, internally consistent, "
    ),
    backstory=(
        "You are a strict linguistic and structural validator."
        "You receive JSON objects containing units, unit titles and stems "
        "You do not paraphrase unnecessarily. You only make the smallest possible edits required "
        "to fix grammar, casing, spelling, duplicated answer content already written in the stem."
        "You preserve all keys, object nesting, and array order unless a correction requires replacing "
        "or removing an invalid option. "
    ),
    verbose=False,
    llm=the_one_llm,
    **agent_limits(),
)


fill_blank_check_task = Task(
    description="""
        Input JSON payload:
        {payload_json}

        Your job is to inspect the given affirmation and correct any grammar, punctuation, or formatting issues that would make the phrase sound unnatural or contain duplicated content.
        Modifications if necessary should comply with one of the following types:

        ------------------------------------------------------------
        Modification 1 — Remove a word if duplicated inside and outside the ##.
        ------------------------------------------------------------


        Incorrect affirmation:
        {
        "index": 5,
        "stem": "Understanding veterinary care helps improve the #health well-being# and the well-being of dogs."
        }

        Corrected affirmation:
        {
        "index": 5,
        "stem": "Understanding veterinary care helps improve the #health# and the well-being of dogs."
        }

        ------------------------------------------------------------
        Modification 2 —  Add possessive such as (a, an, the) or determiner (its, his, her, their) outside the ##
        ------------------------------------------------------------

        Example:

        Incorrect affirmation:
        {
        "index": 6,
        "stem": "The CNN tower is recognized by #height#."
        }

        Corrected affirmation:
        {
        "index": 6,
        "stem": "The CNN tower is recognized by its #height#."
        }
        ------------------------------------------------------------
        Modification 3 — Add a "##" wrapped connector  such as "#and#" or "#or#" when required esnure the connector is in the same language as the affirmation.
        ------------------------------------------------------------

        Example:

        Incorrect affirmation:
        {
        "index": 6,
        "stem": "Canada is recognized for being a #large cold stable# country."
        }

        Corrected affirmation:
        {
        "index": 6,
        "stem": "Canada is recognized for being a #large cold #and# stable# country."
        }

        
        ------------------------------------------------------------
        NO ERROR 
        ------------------------------------------------------------

        If no error is present, return the original JSON without any modifications.

        Example:
        {
        "index": 7,
        "stem": "The Labrador is a very _______ and _______ dog."
        }

        ------------------------------------------------------------
        GENERAL RULES
        ------------------------------------------------------------

        • Do NOT change the JSON structure.
        • Do NOT remove keys.
        • Do NOT reorder arrays.
        • Only modify values under the given considerations.
        • Preserve original wording whenever possible.
        • Return ONLY valid JSON.


    """,
    expected_output="""
    Return ONLY valid JSON with this structure:
    {
      "units": [
        {
          "unit_title": "string",
          "questions": [
            {
              "index": 1,
              "stem": "string",
            }
          ]
        }
      ]
    }
    """,
    agent=fill_blank_checker,
    llm=the_one_llm,
)


def create_fill_blank_check_crew() -> Crew:
    return Crew(
        agents=[fill_blank_checker],
        tasks=[fill_blank_check_task],
        verbose=False,
        **crew_limits(),
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
                logger.warning("Fill-blank check: recovered JSON from raw output after format violation")
                parsed_results.append(recovered)
            else:
                parsed_results.append({"raw": output.raw})
    return parsed_results


def _write_debug_snapshot(path_str: str, payload: Any) -> None:
    # Temporary debug snapshot to inspect reviewer I/O around the LLM boundary.
    backend_root = Path(__file__).resolve().parents[2]
    output_path = backend_root / path_str
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


def run_fill_blank_check(payload: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    crew = create_fill_blank_check_crew()
    logger.info("Fill-blank check: processing %s payload item(s)", len(payload))
    inputs = [
        {
            "item_name": f"item_{i+1}",
            "payload_json": json.dumps(item, ensure_ascii=False),
        }
        for i, item in enumerate(payload)
    ]
    _write_debug_snapshot(DEBUG_REVIEWER_INPUT_PATH, inputs)
    results = crew.kickoff_for_each(inputs=inputs)
    raw_results = [
        {
            "raw": output.raw,
            "json_dict": output.json_dict,
            "pydantic": output.pydantic.model_dump() if output.pydantic else None,
        }
        for output in results
    ]
    _write_debug_snapshot(DEBUG_REVIEWER_RAW_OUTPUT_PATH, raw_results)
    logger.info("Fill-blank check: completed for all payload items")
    formatted_results = _format_outputs(results)
    _write_debug_snapshot(DEBUG_REVIEWER_FORMATTED_OUTPUT_PATH, formatted_results)
    return formatted_results


if __name__ == "__main__":
    backend_root = Path(__file__).resolve().parents[2]
    input_path = backend_root / "outputs" / "fill_blank_answered_question.json"
    output_path = backend_root / "outputs" / "fill_blank_answered_reviewed.json"

    with open(input_path, "r", encoding="utf-8") as f:
        source_payload = json.load(f)

    if isinstance(source_payload, dict):
        payload_items = [source_payload]
    elif isinstance(source_payload, list):
        payload_items = source_payload
    else:
        raise ValueError("Expected fill_blank_answered_reviewed.json to contain a JSON object or list")

    parsed_results = run_fill_blank_check(payload_items)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(parsed_results, f, ensure_ascii=False, indent=2)

    print(f"Wrote fill-blank reviewed payload to: {output_path}")
