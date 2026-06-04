from __future__ import annotations

import json
import os
import queue
import threading
import urllib.error
import urllib.request
from datetime import UTC, datetime
from typing import Any, Callable, Literal, Protocol, TypeVar

from pydantic import Field

from caliber_ai_gateway.models import StrictModel, TokenUsage
from caliber_ai_gateway.policy import (
    INPUT_USD_PER_MILLION_TOKENS,
    OUTPUT_USD_PER_MILLION_TOKENS,
)
from caliber_ai_gateway.provider import ProviderTransportError
from caliber_ai_gateway.token_usage import estimate_text_tokens


BenchmarkProviderName = Literal[
    "chatgpt",
    "claude",
    "openrouter",
    "openrouter_baseline1",
    "openrouter_baseline2",
]

BENCHMARK_PROMPT_VERSION = "gate0_neutral_interview_feedback.v0.1"
DEFAULT_CLAUDE_MODEL = "claude-haiku-4-5-20251001"
ANTHROPIC_API_VERSION = "2023-06-01"
OPENROUTER_TIMEOUT_SECONDS = 30.0

T = TypeVar("T")


class BenchmarkFeedbackRequest(StrictModel):
    provider: BenchmarkProviderName
    answer_id: str = Field(min_length=1)
    question_id: str = Field(min_length=1)
    role: str = Field(min_length=1)
    question: str = Field(min_length=1)
    answer: str = Field(min_length=1)
    prompt_version: str = BENCHMARK_PROMPT_VERSION
    max_completion_tokens: int = Field(default=700, ge=128, le=1200)


class BenchmarkFeedbackResponse(StrictModel):
    provider: BenchmarkProviderName
    model_id: str = Field(min_length=1)
    prompt_version: str = Field(min_length=1)
    verdict: str = Field(min_length=1)
    prompt_tokens: int | None = Field(default=None, ge=0)
    completion_tokens: int | None = Field(default=None, ge=0)
    total_tokens: int | None = Field(default=None, ge=0)
    estimated_prompt_tokens: int = Field(ge=0)
    estimated_completion_tokens: int = Field(ge=0)
    estimated_total_tokens: int = Field(ge=0)
    input_usd_per_million_tokens: float = Field(ge=0)
    output_usd_per_million_tokens: float = Field(ge=0)
    estimated_cost_usd: float = Field(ge=0)
    attempts: int = Field(default=1, ge=1, le=1)
    created_at: str = Field(min_length=1)


class BenchmarkProvider(Protocol):
    provider: BenchmarkProviderName
    model_id: str
    input_usd_per_million_tokens: float
    output_usd_per_million_tokens: float

    def complete(self, request: BenchmarkFeedbackRequest) -> tuple[str, TokenUsage | None]:
        """Return neutral benchmark feedback text plus provider token usage."""


def _float_env(name: str, default: float) -> float:
    raw = os.environ.get(name)
    if raw is None or not raw.strip():
        return default
    try:
        value = float(raw)
    except ValueError:
        return default
    return value if value > 0 else default


def _openai_usage(completion: Any) -> TokenUsage | None:
    usage = getattr(completion, "usage", None)
    if usage is None:
        return None
    return TokenUsage(
        prompt_tokens=_int_or_none(getattr(usage, "prompt_tokens", None)),
        completion_tokens=_int_or_none(getattr(usage, "completion_tokens", None)),
        total_tokens=_int_or_none(getattr(usage, "total_tokens", None)),
    )


def _anthropic_text(payload: dict[str, Any]) -> str:
    content = payload.get("content")
    if not isinstance(content, list):
        return ""
    parts: list[str] = []
    for item in content:
        if isinstance(item, dict) and item.get("type") == "text":
            text = item.get("text")
            if isinstance(text, str):
                parts.append(text)
    return "\n".join(parts)


def _dict_usage(usage: Any) -> TokenUsage | None:
    if not isinstance(usage, dict):
        return None
    return TokenUsage(
        prompt_tokens=_int_or_none(usage.get("prompt_tokens")),
        completion_tokens=_int_or_none(usage.get("completion_tokens")),
        total_tokens=_int_or_none(usage.get("total_tokens")),
    )


def _int_or_none(value: Any) -> int | None:
    if value is None:
        return None
    return int(value)
