from __future__ import annotations

import json
import re
from typing import Any, Dict, Optional
from loguru import logger

JSON_OBJECT_PATTERN = re.compile(r"\{.*\}", re.DOTALL)


def fix_trailing_commas(json_str: str) -> str:
    # elimina comas antes de } o ]
    return re.sub(r",\s*([}\]])", r"\1", json_str)


def _strip_code_fences(raw: str) -> str:
    cleaned = raw.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned[3:].strip()
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:].strip()
        if cleaned.endswith("```"):
            cleaned = cleaned[:-3].strip()
    return cleaned


def _auto_close_brackets(json_str: str) -> str:
    """Heuristically close missing braces/brackets at the end of the payload."""
    braces_diff = json_str.count("{") - json_str.count("}")
    brackets_diff = json_str.count("[") - json_str.count("]")
    if braces_diff > 0:
        json_str = f"{json_str}{'}' * braces_diff}"
    if brackets_diff > 0:
        json_str = f"{json_str}{']' * brackets_diff}"
    return json_str


def _prepare_candidate(raw: str) -> str:
    candidate = _strip_code_fences(raw)
    candidate = fix_trailing_commas(candidate)
    candidate = _auto_close_brackets(candidate)
    return candidate


def extract_json_dict(raw: Any) -> Optional[Dict[str, Any]]:
    """Attempt to extract and parse a JSON object embedded within raw text."""
    if not isinstance(raw, str):
        return None

    candidate = _prepare_candidate(raw)
    try:
        return json.loads(candidate)
    except Exception:
        pass

    match = JSON_OBJECT_PATTERN.search(candidate)
    if not match:
        return None

    candidate = _prepare_candidate(match.group(0))
    try:
        return json.loads(candidate)
    except Exception as exc:
        logger.debug("JSON extraction failed: %s", exc)
        return None
