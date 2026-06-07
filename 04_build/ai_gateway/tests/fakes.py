from __future__ import annotations

from collections.abc import Iterable
from typing import Any

from caliber_ai_gateway.models import ProviderRequest, ProviderResult, TokenUsage
from caliber_ai_gateway.provider import ProviderTransportError


class FakeProviderAdapter:
    name = "fake"
    adapter_version = "fake-provider-v1"

    def __init__(
        self,
        outputs: Iterable[dict[str, Any] | tuple[dict[str, Any], TokenUsage] | ProviderResult | Exception],
        model_id: str = "gpt-5.4-mini",
    ) -> None:
        self.model_id = model_id
        self.outputs = list(outputs)
        self.calls: list[ProviderRequest] = []

    def complete(self, request: ProviderRequest) -> ProviderResult:
        self.calls.append(request)
        if not self.outputs:
            raise ProviderTransportError("fake provider exhausted")
        output = self.outputs.pop(0)
        if isinstance(output, Exception):
            raise output
        if isinstance(output, ProviderResult):
            return output
        if isinstance(output, tuple):
            payload, usage = output
            return ProviderResult(output=payload, usage=usage)
        return ProviderResult(output=output)
