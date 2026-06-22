from __future__ import annotations

import json
import time
import urllib.error
import urllib.request
from typing import Any

import pytest

from caliber_ai_gateway.benchmark import (
    BenchmarkFeedbackRequest,
    OpenRouterBenchmarkProvider,
)
from caliber_ai_gateway.models import TokenUsage
from caliber_ai_gateway.provider import ProviderTransportError


def test_openrouter_provider_uses_chat_completion_shape(monkeypatch: pytest.MonkeyPatch) -> None:
    captured: dict[str, Any] = {}

    def fake_urlopen(request: urllib.request.Request, timeout: int) -> _FakeResponse:
        captured["timeout"] = timeout
        captured["payload"] = json.loads(request.data.decode("utf-8"))  # type: ignore[union-attr]
        return _FakeResponse(
            {
                "choices": [{"message": {"content": "OpenRouter feedback"}}],
                "usage": {
                    "prompt_tokens": 11,
                    "completion_tokens": 7,
                    "total_tokens": 18,
                },
            }
        )

    monkeypatch.setenv("OPENROUTER_API_KEY", "test-openrouter-key")
    monkeypatch.setattr(urllib.request, "urlopen", fake_urlopen)

    provider = OpenRouterBenchmarkProvider(model_id="openai/gpt-oss-120b:free")

    verdict, usage = provider.complete(_request("openrouter"))

    assert verdict == "OpenRouter feedback"
    assert usage == TokenUsage(prompt_tokens=11, completion_tokens=7, total_tokens=18)
    assert captured["timeout"] == 30
    assert captured["payload"]["model"] == "openai/gpt-oss-120b:free"
    assert captured["payload"]["temperature"] == 0
    assert captured["payload"]["seed"] > 0
    assert captured["payload"]["max_tokens"] == 700


def test_openrouter_provider_requires_key(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("OPENROUTER_API_KEY", raising=False)
    provider = OpenRouterBenchmarkProvider()

    with pytest.raises(ProviderTransportError, match="benchmark_provider_key_missing:openrouter"):
        provider.complete(_request("openrouter"))


def test_openrouter_http_error_falls_back_to_openai(monkeypatch: pytest.MonkeyPatch) -> None:
    def rejected(request: urllib.request.Request, timeout: int) -> _FakeResponse:
        raise urllib.error.HTTPError(
            url="https://openrouter.ai/api/v1/chat/completions",
            code=401,
            msg="user not found",
            hdrs={},
            fp=None,
        )

    monkeypatch.setenv("OPENROUTER_API_KEY", "test-openrouter-key")
    monkeypatch.setattr(urllib.request, "urlopen", rejected)
    provider = OpenRouterBenchmarkProvider(model_id="openai/gpt-oss-120b:free")
    provider.fallback = _FallbackProvider()

    verdict, usage = provider.complete(_request("openrouter"))

    assert verdict == "Fallback OpenAI feedback"
    assert usage == TokenUsage(prompt_tokens=13, completion_tokens=5, total_tokens=18)
    assert provider.last_model_id == "openrouter-fallback:gpt-5.4-mini"
    assert provider.last_input_usd_per_million_tokens == 1.0
    assert provider.last_output_usd_per_million_tokens == 4.5


def test_openrouter_transport_error_falls_back_to_openai(monkeypatch: pytest.MonkeyPatch) -> None:
    def transport_failed(request: urllib.request.Request, timeout: int) -> _FakeResponse:
        raise urllib.error.URLError("connection reset")

    monkeypatch.setenv("OPENROUTER_API_KEY", "test-openrouter-key")
    monkeypatch.setattr(urllib.request, "urlopen", transport_failed)
    provider = OpenRouterBenchmarkProvider(model_id="openai/gpt-oss-120b:free")
    provider.fallback = _FallbackProvider()

    verdict, usage = provider.complete(_request("openrouter"))

    assert verdict == "Fallback OpenAI feedback"
    assert usage == TokenUsage(prompt_tokens=13, completion_tokens=5, total_tokens=18)
    assert provider.last_model_id == "openrouter-fallback:gpt-5.4-mini"


def test_openrouter_hard_timeout_falls_back_to_openai(monkeypatch: pytest.MonkeyPatch) -> None:
    def transport_hung(request: urllib.request.Request, timeout: int) -> _FakeResponse:
        time.sleep(0.05)
        return _FakeResponse({"choices": [{"message": {"content": "Too late"}}]})

    monkeypatch.setenv("OPENROUTER_API_KEY", "test-openrouter-key")
    monkeypatch.setenv("CALIBER_OPENROUTER_HARD_TIMEOUT_SECONDS", "0.01")
    monkeypatch.setattr(urllib.request, "urlopen", transport_hung)
    provider = OpenRouterBenchmarkProvider(model_id="openai/gpt-oss-120b:free")
    provider.fallback = _FallbackProvider()

    verdict, usage = provider.complete(_request("openrouter"))

    assert verdict == "Fallback OpenAI feedback"
    assert usage == TokenUsage(prompt_tokens=13, completion_tokens=5, total_tokens=18)
    assert provider.last_model_id == "openrouter-fallback:gpt-5.4-mini"


def test_openrouter_lane_specific_hard_timeout(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("CALIBER_OPENROUTER_HARD_TIMEOUT_SECONDS", "30")
    monkeypatch.setenv("CALIBER_OPENROUTER_BASELINE2_HARD_TIMEOUT_SECONDS", "7")

    baseline1 = OpenRouterBenchmarkProvider(
        provider="openrouter_baseline1",
        model_id="nvidia/nemotron-3-super-120b-a12b:free",
    )
    baseline2 = OpenRouterBenchmarkProvider(
        provider="openrouter_baseline2",
        model_id="nvidia/nemotron-3-ultra-550b-a55b:free",
    )

    assert baseline1.hard_timeout_seconds == 30
    assert baseline2.hard_timeout_seconds == 7


def test_openrouter_baseline_can_select_lane_specific_claude_fallback(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("CALIBER_OPENROUTER_BASELINE2_FALLBACK_PROVIDER", "claude")
    monkeypatch.setenv(
        "CALIBER_OPENROUTER_BASELINE2_FALLBACK_MODEL",
        "claude-haiku-4-5-20251001",
    )

    baseline1 = OpenRouterBenchmarkProvider(
        provider="openrouter_baseline1",
        model_id="nvidia/nemotron-3-super-120b-a12b:free",
    )
    baseline2 = OpenRouterBenchmarkProvider(
        provider="openrouter_baseline2",
        model_id="nvidia/nemotron-3-ultra-550b-a55b:free",
    )

    assert baseline1.fallback_provider == "chatgpt"
    assert baseline1.fallback.model_id == "gpt-5.4-mini"
    assert baseline2.fallback_provider == "claude"
    assert baseline2.fallback.model_id == "claude-haiku-4-5-20251001"


def test_openrouter_lane_specific_fallback_label_is_honest(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def rejected(request: urllib.request.Request, timeout: int) -> _FakeResponse:
        raise urllib.error.HTTPError(
            url="https://openrouter.ai/api/v1/chat/completions",
            code=429,
            msg="rate limit",
            hdrs={},
            fp=None,
        )

    monkeypatch.setenv("OPENROUTER_API_KEY", "test-openrouter-key")
    monkeypatch.setenv("CALIBER_OPENROUTER_BASELINE2_FALLBACK_PROVIDER", "claude")
    monkeypatch.setattr(urllib.request, "urlopen", rejected)
    provider = OpenRouterBenchmarkProvider(
        provider="openrouter_baseline2",
        model_id="nvidia/nemotron-3-ultra-550b-a55b:free",
    )
    provider.fallback = _FallbackProvider(model_id="claude-haiku-4-5-20251001")

    verdict, usage = provider.complete(_request("openrouter_baseline2"))

    assert verdict == "Fallback feedback"
    assert usage == TokenUsage(prompt_tokens=13, completion_tokens=5, total_tokens=18)
    assert provider.last_model_id == "openrouter-fallback:claude-haiku-4-5-20251001"


def _request(provider: str) -> BenchmarkFeedbackRequest:
    return BenchmarkFeedbackRequest(
        provider=provider,
        answer_id="answer-1",
        question_id="question-1",
        role="Backend Engineer",
        question="Design a rate limiter.",
        answer="I would define quotas and compare token bucket versus sliding windows.",
    )


class _FakeResponse:
    def __init__(self, payload: dict[str, Any]) -> None:
        self.payload = payload

    def __enter__(self) -> _FakeResponse:
        return self

    def __exit__(self, *args: object) -> None:
        return None

    def read(self) -> bytes:
        return json.dumps(self.payload).encode("utf-8")


class _FallbackProvider:
    input_usd_per_million_tokens = 1.0
    output_usd_per_million_tokens = 4.5

    def __init__(self, model_id: str = "gpt-5.4-mini") -> None:
        self.model_id = model_id

    def complete(self, request: BenchmarkFeedbackRequest) -> tuple[str, TokenUsage | None]:
        return (
            "Fallback OpenAI feedback" if self.model_id == "gpt-5.4-mini" else "Fallback feedback",
            TokenUsage(prompt_tokens=13, completion_tokens=5, total_tokens=18),
        )
