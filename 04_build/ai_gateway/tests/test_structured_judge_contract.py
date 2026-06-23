from __future__ import annotations

from typing import Any

from caliber_ai_gateway.config import load_gateway_config
from caliber_ai_gateway.models import FeaturePolicy, JudgeRequest
from caliber_ai_gateway.pipeline import StructuredJudge
from caliber_ai_gateway.provider import ProviderRegistry
from tests.fakes import FakeProviderAdapter
from tests.helpers import build_judge, sample_request, valid_output_for


def assert_structured_judge_contract(judge: StructuredJudge) -> None:
    request = sample_request()
    response = judge.judge(request)
    assert response.request_hash
    assert response.canonical_json.startswith("{")
    assert response.audit_ref.startswith("audit:")


def test_gateway_implements_structured_judge_contract() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    assert_structured_judge_contract(judge)


def test_provider_swap_by_registration_keeps_call_site_unchanged() -> None:
    request = sample_request()
    provider_a = FakeProviderAdapter(outputs=[], model_id="gpt-5.4-mini")
    provider_b = FakeProviderAdapter(outputs=[], model_id="gpt-5.4-mini")
    provider_a.name = "provider-a"  # type: ignore[misc]
    provider_b.name = "provider-b"  # type: ignore[misc]
    registry = ProviderRegistry()
    registry.register(provider_a)
    registry.register(provider_b)

    from caliber_ai_gateway.pipeline import GatewayStructuredJudge

    judge = GatewayStructuredJudge(registry=registry, provider_name="provider-b")
    provider_b.outputs.append(valid_output_for(judge, request, provider_b))

    response = judge.judge(request)

    assert len(provider_a.calls) == 0
    assert len(provider_b.calls) == 1
    assert response.canonical_json


def test_product_model_pin_is_loaded_from_provider_adapter_config() -> None:
    from pathlib import Path

    repo_root = Path(__file__).resolve().parents[3]
    config = load_gateway_config(repo_root / "config" / "ai" / "provider_adapter.yaml")

    assert config.provider_adapter.default_model == "gpt-5.4-mini"
    assert config.provider_adapter.strict_structured_outputs is True
    assert config.provider_adapter.gateway_only is True


def test_strict_schema_rejects_extra_keys() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider, policy_engine=TwoAttemptPolicy())
    output: dict[str, Any] = valid_output_for(judge, request, provider)
    output["unexpected"] = "rejected"
    provider.outputs.append(output)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)

    assert response.attempts == 2


class TwoAttemptPolicy:
    def attach(self, request: JudgeRequest, provider_name: str) -> FeaturePolicy:
        return FeaturePolicy(
            feature=request.feature,
            provider_name=provider_name,
            max_attempts=2,
            timeout_seconds=20.0,
            allow_pii_to_provider=False,
            policy_version=request.routing_policy_version,
            max_prompt_tokens=12_000,
            max_completion_tokens=900,
            max_total_tokens=12_900,
            input_usd_per_million_tokens=1.0,
            output_usd_per_million_tokens=4.5,
            max_estimated_cost_usd=0.02,
        )
