import json
import re
from pathlib import Path
from typing import Any, Dict, List, Tuple


BLANK_TOKEN = "__________"
WRAPPED_ANSWER_PATTERN = re.compile(r"#(.*?)#")
DEBUG_INPUT_ORIGINAL_PATH = "outputs/fill_blank_reintegration_input_original.json"
DEBUG_INPUT_REVIEWED_PATH = "outputs/fill_blank_reintegration_input_reviewed.json"


def _extract_reviewed_stem_and_answer(stem: str) -> Tuple[str, str]:
    extracted_parts: List[str] = []

    def replace_wrapped_answer(match: re.Match[str]) -> str:
        wrapped_text = match.group(1).strip()
        if wrapped_text:
            concepts = [part.strip() for part in wrapped_text.split(",") if part.strip()]
            if concepts:
                extracted_parts.extend(concepts)
            else:
                extracted_parts.append(wrapped_text)
        return BLANK_TOKEN

    reviewed_stem = WRAPPED_ANSWER_PATTERN.sub(replace_wrapped_answer, stem)
    reviewed_answer = ", ".join(extracted_parts)
    return reviewed_stem, reviewed_answer


def _build_review_lookup(payload: List[Dict[str, Any]]) -> Dict[Tuple[str, int], Dict[str, str]]:
    lookup: Dict[Tuple[str, int], Dict[str, str]] = {}

    for item in payload:
        for unit in item.get("units", []):
            unit_title = unit.get("unit_title", "")
            for question in unit.get("questions", []):
                index = question.get("index")
                stem = question.get("stem") or ""
                if not isinstance(index, int):
                    continue
                reviewed_stem, reviewed_answer = _extract_reviewed_stem_and_answer(stem)
                lookup[(unit_title, index)] = {
                    "stem": reviewed_stem,
                    "answer": reviewed_answer,
                }

    return lookup


def _split_answer_concepts(answer: str) -> List[str]:
    return [part.strip() for part in answer.split(",") if part.strip()]


def _write_debug_input_snapshot(filename: str, payload: List[Dict[str, Any]]) -> None:
    # Temporary debug snapshot to inspect the exact reintegration inputs at runtime.
    backend_root = Path(__file__).resolve().parents[2]
    output_path = backend_root / filename
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


def apply_reviewed_fill_blanks(
    original_payload: List[Dict[str, Any]],
    reviewed_payload: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    review_lookup = _build_review_lookup(reviewed_payload)
    merged_payload: List[Dict[str, Any]] = []

    for item in original_payload:
        merged_units: List[Dict[str, Any]] = []

        for unit in item.get("units", []):
            unit_title = unit.get("unit_title", "")
            merged_questions: List[Dict[str, Any]] = []

            for question in unit.get("questions", []):
                updated_question = dict(question)
                index = updated_question.get("index")
                review_data = review_lookup.get((unit_title, index))
                if review_data:
                    updated_question["stem"] = review_data["stem"]
                    updated_question["answer"] = review_data["answer"]
                    options = updated_question.get("options")
                    if isinstance(options, list):
                        existing_options = {
                            str(option).strip() for option in options if str(option).strip()
                        }
                        for answer_concept in _split_answer_concepts(review_data["answer"]):
                            if answer_concept not in existing_options:
                                options.append(answer_concept)
                                existing_options.add(answer_concept)
                merged_questions.append(updated_question)

            merged_unit = dict(unit)
            merged_unit["questions"] = merged_questions
            merged_units.append(merged_unit)

        merged_item = dict(item)
        merged_item["units"] = merged_units
        merged_payload.append(merged_item)

    return merged_payload


def run_fill_blank_reintegration(
    original_payload: List[Dict[str, Any]],
    reviewed_payload: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    _write_debug_input_snapshot(DEBUG_INPUT_ORIGINAL_PATH, original_payload)
    _write_debug_input_snapshot(DEBUG_INPUT_REVIEWED_PATH, reviewed_payload)
    return apply_reviewed_fill_blanks(original_payload, reviewed_payload)


if __name__ == "__main__":
    backend_root = Path(__file__).resolve().parents[2]
    fill_blank_path = backend_root / "outputs" / "question_indexed.json"
    reviewed_answered_path = backend_root / "outputs" / "fill_blank_answered_reviewed.json"
    reviewed_output_path = backend_root / "outputs" / "fill_blank_question_reviewed.json"

    with open(fill_blank_path, "r", encoding="utf-8") as f:
        fill_blank_payload = json.load(f)

    with open(reviewed_answered_path, "r", encoding="utf-8") as f:
        reviewed_answered_payload = json.load(f)

    merged_payload = apply_reviewed_fill_blanks(fill_blank_payload, reviewed_answered_payload)

    with open(reviewed_output_path, "w", encoding="utf-8") as f:
        json.dump(merged_payload, f, ensure_ascii=False, indent=2)

    print(f"Wrote reviewed fill-in-blank questions to: {reviewed_output_path}")
