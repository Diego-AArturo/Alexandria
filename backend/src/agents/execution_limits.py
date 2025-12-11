"""Shared throttling helpers for CrewAI agents and crews."""

from __future__ import annotations

import os
from typing import Any, Dict


def _int_from_env(var_name: str, default: int) -> int:
    """Best-effort conversion of environment overrides to integers."""
    try:
        value = os.getenv(var_name)
        return int(value) if value is not None else default
    except ValueError:
        return default


DEFAULT_AGENT_MAX_ITER = _int_from_env("AGENT_MAX_ITER", 10)
DEFAULT_AGENT_MAX_RPM = _int_from_env("AGENT_MAX_RPM", 3)
DEFAULT_CREW_MAX_RPM = _int_from_env("CREW_MAX_RPM", DEFAULT_AGENT_MAX_RPM)


def agent_limits(**overrides: Any) -> Dict[str, Any]:
    """Common agent execution limits with optional overrides."""
    limits: Dict[str, Any] = {
        "max_iter": DEFAULT_AGENT_MAX_ITER,
        "max_rpm": DEFAULT_AGENT_MAX_RPM,
    }
    limits.update(overrides)
    return limits


def crew_limits(**overrides: Any) -> Dict[str, Any]:
    """Common crew execution limits with optional overrides."""
    limits: Dict[str, Any] = {
        "max_rpm": DEFAULT_CREW_MAX_RPM,
    }
    limits.update(overrides)
    return limits
