from __future__ import annotations

import json
from pathlib import Path

import pytest

from caliber_ai_gateway.audit import InMemoryAuditSink
from caliber_ai_gateway.cache import MemoryExactCache
from caliber_ai_gateway.models import FeaturePolicy, JudgeRequest, TokenUsage
from caliber_ai_gateway.token_usage import InMemoryTokenUsageSink

from tests.helpers import build_judge, parsed_response_json, sample_request, valid_output_for
from tests.fakes import FakeProviderAdapter


class PolicyWithTimeout:
    def __init__(self, timeout_seconds: float) -> None:
        self.timeout_seconds = timeout_seconds

    def attach(self, request: JudgeRequest, provider_name: str) -> FeaturePolicy:
        return FeaturePolicy(
            feature=request.feature,
            provider_name=provider_name,
            max_attempts=2,
            timeout_seconds=self.timeout_seconds,
            allow_pii_to_provider=False,
            policy_version=request.routing_policy_version,
            max_prompt_tokens=12_000,
            max_completion_tokens=900,
            max_total_tokens=12_900,
            input_usd_per_million_tokens=1.0,
            output_usd_per_million_tokens=4.5,
            max_estimated_cost_usd=0.02,
        )


def test_same_input_returns_identical_canonical_json_from_cache() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    first = judge.judge(request)
    second = judge.judge(request.model_dump(mode="json"))

    assert first.cache_hit is False
    assert second.cache_hit is True
    assert first.canonical_json == second.canonical_json
    assert first.output_hash == second.output_hash
    assert len(provider.calls) == 1
    assert first.request_hash
    assert parsed_response_json(first.canonical_json)["schema_version"] == request.schema_version


def test_golden_output_is_byte_identical() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)

    golden = Path("tests/golden/interview_content_judgment.json").read_text(encoding="utf-8").strip()
    assert response.canonical_json == golden


@pytest.mark.parametrize(
    ("feature", "fixture"),
    [
        ("resume_bullet", "resume_bullet.json"),
        ("ats_report", "ats_report.json"),
    ],
)
def test_non_interview_golden_outputs_are_byte_identical(feature, fixture: str) -> None:
    request = sample_request(feature)
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)

    golden = Path("tests/golden", fixture).read_text(encoding="utf-8").strip()
    assert response.canonical_json == golden


@pytest.mark.parametrize(
    ("feature", "expected_schema_name"),
    [
        ("interview_content", "interview_content_judgment"),
        ("resume_bullet", "resume_bullet"),
        ("ats_report", "ats_report"),
    ],
)
def test_each_structured_judge_feature_routes_to_its_schema(feature, expected_schema_name: str) -> None:
    request = sample_request(feature=feature)
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    output = parsed_response_json(response.canonical_json)

    assert provider.calls[0].schema_name == expected_schema_name
    assert response.request_hash
    assert provider.calls[0].route_hash
    if "model_id" in output:
        assert output["model_id"] == "gpt-5.4-mini"


def test_schema_route_changes_request_hash_for_same_input_material() -> None:
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    interview = judge.prepare(sample_request("interview_content"), provider)
    resume = judge.prepare(sample_request("resume_bullet"), provider)
    ats = judge.prepare(sample_request("ats_report"), provider)

    assert {interview.schema_name, resume.schema_name, ats.schema_name} == {
        "interview_content_judgment",
        "resume_bullet",
        "ats_report",
    }
    assert len({interview.route_hash, resume.route_hash, ats.route_hash}) == 3
    assert len({interview.request_hash, resume.request_hash, ats.request_hash}) == 3


def test_invalid_cache_entry_is_not_returned_unvalidated() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    cache = MemoryExactCache()
    judge = build_judge(provider, cache=cache)
    prepared = judge.prepare(request, provider)
    cache.set(prepared.request_hash, '{"not":"schema-valid"}')
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)

    assert response.cache_hit is False
    assert len(provider.calls) == 1
    assert response.request_hash
    assert parsed_response_json(response.canonical_json)["schema_version"] == request.schema_version


def test_noncanonical_cache_entry_is_replaced_before_return() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    cache = MemoryExactCache()
    judge = build_judge(provider, cache=cache)
    valid_output = valid_output_for(judge, request, provider)
    prepared = judge.prepare(request, provider)
    cache.set(prepared.request_hash, json.dumps(valid_output, indent=2))
    provider.outputs.append(valid_output)

    response = judge.judge(request)

    assert response.cache_hit is False
    assert len(provider.calls) == 1
    assert response.canonical_json != json.dumps(valid_output, indent=2)


def test_attached_policy_material_changes_request_hash_even_with_same_version() -> None:
    from caliber_ai_gateway.pipeline import GatewayStructuredJudge
    from caliber_ai_gateway.provider import ProviderRegistry

    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    registry = ProviderRegistry()
    registry.register(provider)
    fast_policy_judge = GatewayStructuredJudge(
        registry=registry,
        provider_name="fake",
        policy_engine=PolicyWithTimeout(timeout_seconds=10.0),
    )
    slow_policy_judge = GatewayStructuredJudge(
        registry=registry,
        provider_name="fake",
        policy_engine=PolicyWithTimeout(timeout_seconds=20.0),
    )

    fast = fast_policy_judge.prepare(request, provider)
    slow = slow_policy_judge.prepare(request, provider)

    assert fast.version_pins["routing_policy_version"] == slow.version_pins["routing_policy_version"]
    assert fast.route_hash != slow.route_hash
    assert fast.request_hash != slow.request_hash


@pytest.mark.parametrize(
    ("field", "replacement"),
    [
        ("schema_version", "ai-output-v2"),
        ("prompt_version", "interview-content-prompt-v2"),
        ("corpus_bundle_version", "corpus-2026-06-01"),
        ("routing_policy_version", "route-policy-v2"),
    ],
)
def test_each_declared_version_pin_changes_request_hash(field: str, replacement: str) -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    baseline = judge.prepare(request, provider)

    changed_request = request.model_copy(update={field: replacement})
    changed = judge.prepare(changed_request, provider)

    assert changed.version_pins[field] == replacement
    assert changed.request_hash != baseline.request_hash


def test_product_model_pin_changes_route_and_request_hash() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[], model_id="gpt-5.4-mini")
    alternate_provider = FakeProviderAdapter(outputs=[], model_id="gpt-5.4-mini-experimental")
    judge = build_judge(provider)

    baseline = judge.prepare(request, provider)
    changed = judge.prepare(request, alternate_provider)

    assert baseline.version_pins["model_id"] == "gpt-5.4-mini"
    assert changed.version_pins["model_id"] == "gpt-5.4-mini-experimental"
    assert changed.route_hash != baseline.route_hash
    assert changed.request_hash != baseline.request_hash


def test_audit_records_exact_version_pin_surface() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    audit_sink = InMemoryAuditSink()
    judge = build_judge(provider, audit_sink=audit_sink)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)

    audit_row = audit_sink.records[-1].safe_dump()
    assert audit_row["request_hash"] == response.request_hash
    assert audit_row["version_pins"] == {
        "schema_version": request.schema_version,
        "prompt_version": request.prompt_version,
        "corpus_bundle_version": request.corpus_bundle_version,
        "routing_policy_version": request.routing_policy_version,
        "model_id": "gpt-5.4-mini",
        "route_hash": audit_row["version_pins"]["route_hash"],
    }


def test_token_usage_records_actual_provider_usage_without_payloads() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    token_usage_sink = InMemoryTokenUsageSink()
    judge = build_judge(provider, token_usage_sink=token_usage_sink)
    provider.outputs.append(
        (
            valid_output_for(judge, request, provider),
            TokenUsage(prompt_tokens=123, completion_tokens=45, total_tokens=168),
        )
    )

    response = judge.judge(request)

    record = token_usage_sink.records[-1].safe_dump()
    assert record["audit_ref"] == response.audit_ref
    assert record["model_id"] == "gpt-5.4-mini"
    assert record["feature"] == "interview_content"
    assert record["cache_hit"] is False
    assert record["prompt_tokens"] == 123
    assert record["completion_tokens"] == 45
    assert record["total_tokens"] == 168
    assert record["estimated_total_tokens"] > 0
    serialized = json.dumps(record, sort_keys=True)
    assert "Riverpod" not in serialized
    assert "user@example.com" not in serialized


def test_token_usage_records_cache_hit_as_zero_cost_with_saved_estimate() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    token_usage_sink = InMemoryTokenUsageSink()
    judge = build_judge(provider, token_usage_sink=token_usage_sink)
    provider.outputs.append(
        (
            valid_output_for(judge, request, provider),
            TokenUsage(prompt_tokens=123, completion_tokens=45, total_tokens=168),
        )
    )

    first = judge.judge(request)
    second = judge.judge(request)

    assert first.cache_hit is False
    assert second.cache_hit is True
    assert len(token_usage_sink.records) == 2
    cache_record = token_usage_sink.records[-1].safe_dump()
    assert cache_record["cache_hit"] is True
    assert cache_record["prompt_tokens"] == 0
    assert cache_record["completion_tokens"] == 0
    assert cache_record["total_tokens"] == 0
    assert cache_record["cache_saved_estimated_tokens"] > 0
