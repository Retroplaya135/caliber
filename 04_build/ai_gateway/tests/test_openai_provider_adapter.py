from __future__ import annotations

import sys
from types import ModuleType, SimpleNamespace
from typing import Any

import pytest

from caliber_ai_gateway.models import ProviderRequest
from caliber_ai_gateway.provider import OpenAIProviderAdapter, ProviderTransportError


def provider_request() -> ProviderRequest:
    return ProviderRequest(
        request_hash="a" * 64,
        model_id="gpt-5.4-mini",
        route_hash="b" * 64,
        schema_name="interview_content_judgment",
        response_schema={
            "type": "object",
            "properties": {"ok": {"type": "boolean"}},
            "required": ["ok"],
            "additionalProperties": False,
        },
        messages=[{"role": "user", "content": '{"input":true}'}],
        timeout_seconds=4.5,
        max_completion_tokens=900,
    )


def install_fake_openai(monkeypatch: pytest.MonkeyPatch, result: Any) -> dict[str, Any]:
    captured: dict[str, Any] = {}

    class FakeCompletions:
        def create(self, **kwargs: Any) -> Any:
            captured.update(kwargs)
            if isinstance(result, Exception):
                raise result
            return result

    class FakeOpenAI:
        def __init__(self) -> None:
            self.chat = SimpleNamespace(completions=FakeCompletions())

    module = ModuleType("openai")
    module.OpenAI = FakeOpenAI
    monkeypatch.setitem(sys.modules, "openai", module)
    return captured


def completion_with(content: str | None, refusal: str | None = None) -> Any:
    message = SimpleNamespace(content=content, refusal=refusal)
    usage = SimpleNamespace(prompt_tokens=31, completion_tokens=7, total_tokens=38)
    return SimpleNamespace(choices=[SimpleNamespace(message=message)], usage=usage)


def test_openai_provider_adapter_sends_strict_json_schema(monkeypatch: pytest.MonkeyPatch) -> None:
    captured = install_fake_openai(monkeypatch, completion_with('{"ok":true}'))
    request = provider_request()

    result = OpenAIProviderAdapter(model_id="gpt-5.4-mini").complete(request)

    assert result.output == {"ok": True}
    assert result.usage is not None
    assert result.usage.prompt_tokens == 31
    assert result.usage.completion_tokens == 7
    assert result.usage.total_tokens == 38
    assert captured["model"] == "gpt-5.4-mini"
    assert captured["messages"] == request.messages
    assert captured["timeout"] == request.timeout_seconds
    assert captured["max_completion_tokens"] == 900
    assert captured["response_format"] == {
        "type": "json_schema",
        "json_schema": {
            "name": "interview_content_judgment",
            "strict": True,
            "schema": request.response_schema,
        },
    }


@pytest.mark.parametrize(
    ("result", "message", "safe_status"),
    [
        (
            RuntimeError("timeout"),
            "provider_transport_error:RuntimeError",
            "provider_transport_error:RuntimeError",
        ),
        (
            SimpleNamespace(choices=[]),
            "malformed_provider_response",
            "malformed_provider_response",
        ),
        (completion_with(None), "empty_provider_content", "empty_provider_content"),
        (completion_with("not-json"), "invalid_provider_json", "invalid_provider_json"),
        (completion_with("{}", refusal="blocked"), "provider_refusal", "provider_refusal"),
    ],
)
def test_openai_provider_adapter_normalizes_provider_failures(
    monkeypatch: pytest.MonkeyPatch,
    result: Any,
    message: str,
    safe_status: str,
) -> None:
    install_fake_openai(monkeypatch, result)

    with pytest.raises(ProviderTransportError, match=message) as exc_info:
        OpenAIProviderAdapter(model_id="gpt-5.4-mini").complete(provider_request())
    assert exc_info.value.safe_status == safe_status


def test_openai_provider_adapter_keeps_safe_upstream_error_metadata(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    class FakeBadRequest(Exception):
        status_code = 400
        code = "unsupported_response_format"
        type = "invalid_request_error"

    install_fake_openai(monkeypatch, FakeBadRequest("prompt text should stay out"))

    with pytest.raises(ProviderTransportError) as exc_info:
        OpenAIProviderAdapter(model_id="gpt-5.4-mini").complete(provider_request())

    assert str(exc_info.value) == (
        "provider_transport_error:FakeBadRequest:"
        "status_code=400:code=unsupported_response_format:type=invalid_request_error"
    )
    assert exc_info.value.safe_status == str(exc_info.value)
    assert "prompt text" not in str(exc_info.value)
