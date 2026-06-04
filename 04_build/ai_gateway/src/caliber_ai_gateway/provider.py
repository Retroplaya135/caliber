from __future__ import annotations

import json
from collections.abc import Iterable
from typing import Any, Protocol

from caliber_ai_gateway.models import ProviderRequest, ProviderResult, TokenUsage


class ProviderTransportError(RuntimeError):
    def __init__(
        self,
        message: str = "provider_transport_error",
        *,
        safe_status: str | None = None,
    ) -> None:
        super().__init__(message)
        self.safe_status = safe_status or (
            message if _is_safe_status_label(message) else "provider_transport_error"
        )


class ProviderAdapter(Protocol):
    name: str
    model_id: str
    adapter_version: str

    def complete(self, request: ProviderRequest) -> ProviderResult:
        """Return provider JSON already parsed into a dictionary."""


class ProviderRegistry:
    def __init__(self) -> None:
        self._adapters: dict[str, ProviderAdapter] = {}

    def register(self, adapter: ProviderAdapter) -> None:
        self._adapters[adapter.name] = adapter

    def get(self, name: str) -> ProviderAdapter:
        try:
            return self._adapters[name]
        except KeyError as exc:
            available = ", ".join(sorted(self._adapters)) or "none"
            raise KeyError(f"Provider adapter {name!r} is not registered; available: {available}") from exc

    def names(self) -> Iterable[str]:
        return tuple(sorted(self._adapters))


class OpenAIProviderAdapter:
    name = "openai"
    adapter_version = "openai-python-2.x-chat-completions-json-schema"

    def __init__(self, model_id: str) -> None:
        self.model_id = model_id

    def complete(self, request: ProviderRequest) -> ProviderResult:
        from openai import OpenAI

        client = OpenAI()
        try:
            completion = client.chat.completions.create(
                model=self.model_id,
                messages=request.messages,
                max_completion_tokens=request.max_completion_tokens,
                response_format={
                    "type": "json_schema",
                    "json_schema": {
                        "name": request.schema_name,
                        "strict": True,
                        "schema": request.response_schema,
                    },
                },
                timeout=request.timeout_seconds,
            )
        except Exception as exc:
            label = _safe_provider_error_label(exc)
            raise ProviderTransportError(label, safe_status=label) from exc
        try:
            choice = completion.choices[0]
            message = choice.message
        except (AttributeError, IndexError, TypeError) as exc:
            raise ProviderTransportError("malformed_provider_response") from exc
        refusal = getattr(message, "refusal", None)
        if refusal:
            raise ProviderTransportError("provider_refusal")
        content = message.content
        if not content:
            raise ProviderTransportError("empty_provider_content")
        try:
            output = json.loads(content)
        except json.JSONDecodeError as exc:
            raise ProviderTransportError("invalid_provider_json") from exc
        return ProviderResult(output=output, usage=_usage_from_completion(completion))


def _usage_from_completion(completion: Any) -> TokenUsage | None:
    usage = getattr(completion, "usage", None)
    if usage is None:
        return None
    return TokenUsage(
        prompt_tokens=_int_or_none(getattr(usage, "prompt_tokens", None)),
        completion_tokens=_int_or_none(getattr(usage, "completion_tokens", None)),
        total_tokens=_int_or_none(getattr(usage, "total_tokens", None)),
    )


def _int_or_none(value: Any) -> int | None:
    if value is None:
        return None
    return int(value)


def _safe_provider_error_label(exc: Exception) -> str:
    parts = ["provider_transport_error", type(exc).__name__]
    for name in ("status_code", "code", "type"):
        value = getattr(exc, name, None)
        if value is not None:
            parts.append(f"{name}={_safe_label_value(value)}")
    return ":".join(parts)


def _safe_label_value(value: Any) -> str:
    text = str(value).strip()
    if not text:
        return "empty"
    safe = []
    for char in text[:80]:
        safe.append(char if char.isalnum() or char in "._-" else "_")
    return "".join(safe)


def _is_safe_status_label(value: str) -> bool:
    if not value or len(value) > 160:
        return False
    return all(char.isalnum() or char in ":._-" for char in value)
