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


class BenchmarkFeedbackService:
    def __init__(self, providers: dict[str, BenchmarkProvider]) -> None:
        self.providers = providers

    def complete(self, request: BenchmarkFeedbackRequest | dict[str, Any]) -> BenchmarkFeedbackResponse:
        parsed = (
            request
            if isinstance(request, BenchmarkFeedbackRequest)
            else BenchmarkFeedbackRequest.model_validate(request)
        )
        provider = self.providers[parsed.provider]
        system_prompt, user_prompt = neutral_feedback_prompts(parsed)
        verdict, usage = provider.complete(parsed)
        model_id = getattr(provider, "last_model_id", provider.model_id)
        input_rate = getattr(
            provider,
            "last_input_usd_per_million_tokens",
            provider.input_usd_per_million_tokens,
        )
        output_rate = getattr(
            provider,
            "last_output_usd_per_million_tokens",
            provider.output_usd_per_million_tokens,
        )
        estimated_prompt_tokens = estimate_text_tokens(system_prompt) + estimate_text_tokens(user_prompt)
        estimated_completion_tokens = estimate_text_tokens(verdict)
        prompt_tokens = usage.prompt_tokens if usage is not None else None
        completion_tokens = usage.completion_tokens if usage is not None else None
        billable_prompt_tokens = prompt_tokens if prompt_tokens is not None else estimated_prompt_tokens
        billable_completion_tokens = (
            completion_tokens if completion_tokens is not None else estimated_completion_tokens
        )
        estimated_cost_usd = (
            billable_prompt_tokens * input_rate
            + billable_completion_tokens * output_rate
        ) / 1_000_000
        return BenchmarkFeedbackResponse(
            provider=provider.provider,
            model_id=model_id,
            prompt_version=parsed.prompt_version,
            verdict=verdict,
            prompt_tokens=prompt_tokens,
            completion_tokens=completion_tokens,
            total_tokens=usage.total_tokens if usage is not None else None,
            estimated_prompt_tokens=estimated_prompt_tokens,
            estimated_completion_tokens=estimated_completion_tokens,
            estimated_total_tokens=estimated_prompt_tokens + estimated_completion_tokens,
            input_usd_per_million_tokens=input_rate,
            output_usd_per_million_tokens=output_rate,
            estimated_cost_usd=estimated_cost_usd,
            attempts=1,
            created_at=datetime.now(UTC).isoformat(),
        )


class AnthropicBenchmarkProvider:
    provider: Literal["claude"] = "claude"

    def __init__(
        self,
        *,
        model_id: str = DEFAULT_CLAUDE_MODEL,
        input_usd_per_million_tokens: float | None = None,
        output_usd_per_million_tokens: float | None = None,
    ) -> None:
        self.model_id = model_id
        self.input_usd_per_million_tokens = input_usd_per_million_tokens or float(
            os.environ.get("CALIBER_CLAUDE_INPUT_USD_PER_MILLION", "1.0")
        )
        self.output_usd_per_million_tokens = output_usd_per_million_tokens or float(
            os.environ.get("CALIBER_CLAUDE_OUTPUT_USD_PER_MILLION", "5.0")
        )

    def complete(self, request: BenchmarkFeedbackRequest) -> tuple[str, TokenUsage | None]:
        api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not api_key:
            raise ProviderTransportError("benchmark_provider_key_missing:claude")
        system_prompt, user_prompt = neutral_feedback_prompts(request)
        payload = {
            "model": self.model_id,
            "max_tokens": request.max_completion_tokens,
            "temperature": 0,
            "system": system_prompt,
            "messages": [{"role": "user", "content": user_prompt}],
        }
        http_request = urllib.request.Request(
            "https://api.anthropic.com/v1/messages",
            data=json.dumps(payload, separators=(",", ":")).encode("utf-8"),
            headers={
                "content-type": "application/json",
                "x-api-key": api_key,
                "anthropic-version": ANTHROPIC_API_VERSION,
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(http_request, timeout=20) as response:
                decoded = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            raise ProviderTransportError(
                f"benchmark_provider_error:claude:status_code={exc.code}"
            ) from exc
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
            raise ProviderTransportError("benchmark_provider_error:claude") from exc
        verdict = _anthropic_text(decoded)
        if not verdict.strip():
            raise ProviderTransportError("benchmark_provider_empty:claude")
        usage = decoded.get("usage") if isinstance(decoded, dict) else None
        return verdict.strip(), TokenUsage(
            prompt_tokens=_int_or_none(usage.get("input_tokens") if isinstance(usage, dict) else None),
            completion_tokens=_int_or_none(
                usage.get("output_tokens") if isinstance(usage, dict) else None
            ),
            total_tokens=(
                _int_or_none(usage.get("input_tokens")) + _int_or_none(usage.get("output_tokens"))
                if isinstance(usage, dict)
                and usage.get("input_tokens") is not None
                and usage.get("output_tokens") is not None
                else None
            ),
        )


def _openrouter_baseline_model(index: str) -> str:
    candidates = [
        f"CALIBER_OPENROUTER_BASELINE{index}_MODEL",
        "CALIBER_OPENROUTER_GPT_MODEL" if index == "1" else "CALIBER_OPENROUTER_ALT_MODEL",
        "CALIBER_OPENROUTER_NON_OPENAI_MODEL" if index == "2" else "",
    ]
    for name in candidates:
        if not name:
            continue
        value = os.environ.get(name, "").strip()
        if value:
            return value
    return ""


def _openrouter_rate(index: str, kind: str) -> float | None:
    lane_name = f"CALIBER_OPENROUTER_BASELINE{index}_{kind}_USD_PER_MILLION"
    shared_name = f"CALIBER_OPENROUTER_{kind}_USD_PER_MILLION"
    for name in (lane_name, shared_name):
        value = os.environ.get(name, "").strip()
        if value:
            return float(value)
    return None


def _openrouter_fallback_provider(provider: str) -> Literal["chatgpt", "claude"]:
    value = _openrouter_lane_env(provider, "FALLBACK_PROVIDER") or os.environ.get(
        "CALIBER_OPENROUTER_FALLBACK_PROVIDER",
        "chatgpt",
    )
    normalized = value.strip().lower()
    if normalized in {"chatgpt", "openai"}:
        return "chatgpt"
    if normalized in {"claude", "anthropic"}:
        return "claude"
    raise ProviderTransportError(
        f"benchmark_provider_fallback_unsupported:{provider}:{normalized}"
    )


def _openrouter_lane_env(provider: str, suffix: str) -> str:
    provider_upper = provider.upper()
    names = [f"CALIBER_{provider_upper}_{suffix}"]
    if provider_upper == "OPENROUTER_BASELINE1":
        names.append(f"CALIBER_OPENROUTER_BASELINE1_{suffix}")
    if provider_upper == "OPENROUTER_BASELINE2":
        names.append(f"CALIBER_OPENROUTER_BASELINE2_{suffix}")
    for name in names:
        value = os.environ.get(name, "").strip()
        if value:
            return value
    return ""


def _float_env(name: str, default: float) -> float:
    raw = os.environ.get(name)
    if raw is None or not raw.strip():
        return default
    try:
        value = float(raw)
    except ValueError:
        return default
    return value if value > 0 else default


def _openrouter_hard_timeout_seconds(provider: str) -> float:
    provider_suffix = provider.upper()
    lane_specific = f"CALIBER_{provider_suffix}_HARD_TIMEOUT_SECONDS"
    return _float_env(
        lane_specific,
        _float_env("CALIBER_OPENROUTER_HARD_TIMEOUT_SECONDS", OPENROUTER_TIMEOUT_SECONDS),
    )


def _read_json_response(request: urllib.request.Request, *, timeout: float) -> dict[str, Any]:
    with urllib.request.urlopen(request, timeout=timeout) as response:
        decoded = json.loads(response.read().decode("utf-8"))
    if not isinstance(decoded, dict):
        raise json.JSONDecodeError("OpenRouter response must be an object", "", 0)
    return decoded


def _run_with_timeout(func: Callable[[], T], *, timeout_seconds: float) -> T:
    results: queue.Queue[tuple[bool, T | BaseException]] = queue.Queue(maxsize=1)

    def target() -> None:
        try:
            results.put((True, func()))
        except BaseException as exc:  # noqa: BLE001
            results.put((False, exc))

    thread = threading.Thread(target=target, daemon=True)
    thread.start()
    thread.join(timeout_seconds)
    if thread.is_alive():
        raise TimeoutError("openrouter hard timeout")
    ok, value = results.get_nowait()
    if ok:
        return value  # type: ignore[return-value]
    raise value


def neutral_feedback_prompts(request: BenchmarkFeedbackRequest) -> tuple[str, str]:
    system_prompt = (
        "You are giving ordinary interview feedback to a software engineer. "
        "Be specific and actionable, but do not use Caliber rubrics, hidden scoring, or numeric scores."
    )
    user_prompt = (
        f"Role: {request.role}\n"
        f"Question ID: {request.question_id}\n"
        f"Question:\n{request.question}\n\n"
        f"Candidate answer:\n{request.answer}\n\n"
        "Evaluate whether this answer sounds senior-level yet. Explain the strongest signals, "
        "the main gaps, and what the candidate should change next."
    )
    return system_prompt, user_prompt


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


def _openrouter_text(payload: dict[str, Any]) -> str:
    choices = payload.get("choices")
    if not isinstance(choices, list) or not choices:
        return ""
    first = choices[0]
    if not isinstance(first, dict):
        return ""
    message = first.get("message")
    if not isinstance(message, dict):
        return ""
    content = message.get("content")
    return content if isinstance(content, str) else ""


def _dict_usage(usage: Any) -> TokenUsage | None:
    if not isinstance(usage, dict):
        return None
    return TokenUsage(
        prompt_tokens=_int_or_none(usage.get("prompt_tokens")),
        completion_tokens=_int_or_none(usage.get("completion_tokens")),
        total_tokens=_int_or_none(usage.get("total_tokens")),
    )


def _stable_seed(value: str) -> int:
    seed = 17
    for codepoint in value.encode("utf-8"):
        seed = (seed * 31 + codepoint) & 0x7FFFFFFF
    return seed


def _int_or_none(value: Any) -> int | None:
    if value is None:
        return None
    return int(value)
