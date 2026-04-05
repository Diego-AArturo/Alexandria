import json
import re
from pathlib import Path
from typing import Any, Dict, List, Tuple


def _fill_stem_with_answer(stem: str, answer: str) -> str:
    answers = [part.strip() for part in answer.split(",") if part.strip()]
    blank_matches = list(re.finditer(r"_+", stem))

    if len(blank_matches) == 1 and len(answers) > 1:
        return re.sub(r"_+", f"#{' '.join(answers)}#", stem, count=1)


    answer_index = 0

    def replace_blank(match: re.Match[str]) -> str:
        nonlocal answer_index
        if answer_index >= len(answers):
            return match.group(0)
        value = answers[answer_index]
        answer_index += 1
        return f"#{value}#"

    return re.sub(r"_+", replace_blank, stem)


def transform_questions(
    payload: List[Dict[str, Any]],
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    answered_payload: List[Dict[str, Any]] = []
    indexed_payload: List[Dict[str, Any]] = []

    for item in payload:
        units = item.get("units", [])
        answered_units: List[Dict[str, Any]] = []
        indexed_units: List[Dict[str, Any]] = []

        for unit in units:
            questions = unit.get("questions", [])
            answered_questions: List[Dict[str, Any]] = []
            indexed_questions: List[Dict[str, Any]] = []

            for idx, question in enumerate(questions, start=1):
                indexed_question = dict(question)
                indexed_question["index"] = idx
                indexed_questions.append(indexed_question)

                if question.get("type") != "fill_in_blank":
                    continue

                stem = question.get("stem") or ""
                answer = question.get("answer") or ""

                answered_question = {
                    "index": idx,
                    "stem": _fill_stem_with_answer(stem, answer),
                }
                
                answered_questions.append(answered_question)

            answered_unit = dict(unit)
            answered_unit["questions"] = answered_questions
            answered_units.append(answered_unit)

            indexed_unit = dict(unit)
            indexed_unit["questions"] = indexed_questions
            indexed_units.append(indexed_unit)

        answered_item = dict(item)
        answered_item["units"] = answered_units
        answered_payload.append(answered_item)

        indexed_item = dict(item)
        indexed_item["units"] = indexed_units
        indexed_payload.append(indexed_item)

    return answered_payload, indexed_payload


if __name__ == "__main__":
    backend_root = Path(__file__).resolve().parents[2]
    input_path = backend_root / "outputs" / "question.json"
    answered_fill_blank_path = backend_root / "outputs" / "fill_blank_answered_question.json"
    indexed_questions_path = backend_root / "outputs" / "question_indexed.json"

    with open(input_path, "r", encoding="utf-8") as f:
        source_payload = json.load(f)

    answered_payload, indexed_payload = transform_questions(source_payload)

    with open(answered_fill_blank_path, "w", encoding="utf-8") as f:
        json.dump(answered_payload, f, ensure_ascii=False, indent=2)

    with open(indexed_questions_path, "w", encoding="utf-8") as f:
        json.dump(indexed_payload, f, ensure_ascii=False, indent=2)

    print(f"Wrote answered fill-in-blank questions to: {answered_fill_blank_path}")
    print(f"Wrote indexed questions to: {indexed_questions_path}")
