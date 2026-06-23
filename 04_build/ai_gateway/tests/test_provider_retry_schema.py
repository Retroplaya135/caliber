from __future__ import annotations

import json

import pytest

from caliber_ai_gateway.audit import InMemoryAuditSink
from caliber_ai_gateway.budget import TokenBudgetExceeded
from caliber_ai_gateway.models import FeaturePolicy, JudgeRequest
from caliber_ai_gateway.pipeline import SchemaValidationRetry
from caliber_ai_gateway.policy import PolicyEngine
from caliber_ai_gateway.provider import ProviderTransportError
from caliber_ai_gateway.token_usage import InMemoryTokenUsageSink
from tests.fakes import FakeProviderAdapter
from tests.helpers import build_judge, sample_request, valid_output_for


def iter_schema_nodes(value: object) -> list[dict[str, object]]:
    nodes: list[dict[str, object]] = []
    if isinstance(value, dict):
        nodes.append(value)
        for item in value.values():
            nodes.extend(iter_schema_nodes(item))
    elif isinstance(value, list):
        for item in value:
            nodes.extend(iter_schema_nodes(item))
    return nodes


def test_schema_invalid_response_retries_then_validates() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[{"not": "schema-valid"}])
    audit = InMemoryAuditSink()
    judge = build_judge(provider, audit_sink=audit, policy_engine=TwoAttemptPolicy())
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    audit_rows = [record.safe_dump() for record in audit.records]

    assert response.cache_hit is False
    assert response.attempts == 2
    assert len(provider.calls) == 2
    assert provider.calls[0].response_schema["additionalProperties"] is False
    assert provider.calls[0].response_schema["required"]
    assert [row["status"] for row in audit_rows] == [
        "retryable_failure:invalid_provider_json",
        "provider_validated",
    ]
    assert audit_rows[0]["attempts"] == 1
    assert audit_rows[0]["output_hash"] is None
    assert audit_rows[0]["request_hash"] == response.request_hash


def test_interview_missing_criterion_marks_retries_then_validates() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    audit = InMemoryAuditSink()
    judge = build_judge(provider, audit_sink=audit, policy_engine=TwoAttemptPolicy())
    invalid_output = valid_output_for(judge, request, provider)
    invalid_output.pop("criterion_marks")
    provider.outputs.append(invalid_output)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    audit_rows = [record.safe_dump() for record in audit.records]

    assert response.attempts == 2
    assert len(provider.calls) == 2
    assert [row["status"] for row in audit_rows] == [
        "retryable_failure:missing_criterion_marks",
        "provider_validated",
    ]
    assert audit_rows[0]["output_hash"] is None


def test_interview_unknown_criterion_id_stays_invalid() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider, policy_engine=TwoAttemptPolicy())
    invalid_output = valid_output_for(judge, request, provider)
    invalid_output["criterion_marks"][0]["criterion_id"] = "not_in_signed_rubric"
    provider.outputs.append(invalid_output)
    provider.outputs.append(invalid_output)

    with pytest.raises(SchemaValidationRetry) as exc:
        judge.judge(request)

    assert exc.value.failure_category == "unknown_criterion_id"


def test_interview_quote_not_present_stays_invalid() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider, policy_engine=TwoAttemptPolicy())
    invalid_output = valid_output_for(judge, request, provider)
    invalid_output["criterion_marks"][0]["exact_quote"] = "this quote is not in the answer"
    provider.outputs.append(invalid_output)
    provider.outputs.append(invalid_output)

    with pytest.raises(SchemaValidationRetry) as exc:
        judge.judge(request)

    assert exc.value.failure_category == "quote_not_found"


def test_interview_valid_criterion_marks_derive_proof_fields() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    output = json.loads(response.canonical_json)

    assert len(output["criterion_marks"]) == 3
    assert len(output["evidence_spans"]) == 3
    assert output["evidence_spans"][0]["quote"] in request.answer
    assert output["risks"][0].startswith("[tradeoffs]")
    assert output["recommended_actions"][0].startswith("[tradeoffs]")
    assert output["provider_suggested_band"] == "at_bar"
    assert output["deterministic_level_band"] == "at_bar"
    assert output["level_band"] == output["deterministic_level_band"]


def test_interview_quote_span_allows_whitespace_normalization_only() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    output = valid_output_for(judge, request, provider)
    output["criterion_marks"][0]["exact_quote"] = (
        "I led a Riverpod migration\nand reduced frame drops"
    )
    provider.outputs.append(output)

    response = judge.judge(request)
    canonical = json.loads(response.canonical_json)

    assert canonical["criterion_marks"][0]["exact_quote"] in request.answer
    assert canonical["criterion_marks"][0]["exact_quote"] == (
        "I led a Riverpod migration and reduced frame drops"
    )


def test_interview_quote_span_can_snap_valid_offsets_to_exact_answer_text() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    output = valid_output_for(judge, request, provider)
    output["criterion_marks"][0]["exact_quote"] = (
        "I led a Riverpod migration\nand reduced frame drops"
    )
    output["criterion_marks"][0]["quote_start"] = request.answer.index("I led")
    output["criterion_marks"][0]["quote_end"] = request.answer.index(". Email")
    provider.outputs.append(output)

    response = judge.judge(request)
    canonical = json.loads(response.canonical_json)

    assert canonical["criterion_marks"][0]["quote_start"] == request.answer.index("I led")
    assert canonical["criterion_marks"][0]["exact_quote"] in request.answer


@pytest.mark.parametrize(
    "fixture_id",
    [
        "people_senior_027",
        "pubsub_senior_033",
        "migration_senior_036",
        "api_senior_040",
    ],
)
def test_deterministic_band_overrides_known_senior_deflations(fixture_id: str) -> None:
    answer = (
        "I would clarify requirements, compare queue and log-based options, "
        "call out retry and backpressure failure modes, and coordinate a rollout "
        "with the owning teams."
    )
    request = sample_request().model_copy(
        update={
            "rubric": {
                "dimensions": [
                    "requirements",
                    "tradeoffs",
                    "failure_modes",
                    "scope_level_signal",
                    "communication",
                ],
            },
            "answer": answer,
            "user_context": {"answer_id": fixture_id, "question_id": "backend-senior-proof"},
        }
    )
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    output = valid_output_for(judge, request, provider)
    output["level_band"] = "below_bar"
    output["question_id"] = "backend-senior-proof"
    quote = "clarify requirements, compare queue and log-based options"
    output["criterion_marks"] = [
        _criterion_mark("requirements", "Requirements", "partial", quote),
        _criterion_mark("tradeoffs", "Trade-offs", "partial", quote),
        _criterion_mark("failure_modes", "Failure modes", "partial", quote),
        _criterion_mark("scope_level_signal", "Scope/level signal", "met", quote),
        _criterion_mark("communication", "Communication", "missing", quote),
    ]
    provider.outputs.append(output)

    response = judge.judge(request)
    canonical = json.loads(response.canonical_json)

    assert canonical["provider_suggested_band"] == "below_bar"
    assert canonical["deterministic_level_band"] == "approaching"
    assert canonical["level_band"] == "approaching"
    assert canonical["level_band"] != "below_bar"


def test_behavioral_leadership_partial_scope_evidence_does_not_deflate_to_below_bar() -> None:
    answer = (
        "Our team repeatedly shipped backend changes with weak rollback and alerting plans, "
        "so I proposed a release-readiness rubric and made it lightweight enough to adopt. "
        "I handled pushback by showing two recent incidents where missing ownership cost us hours, "
        "then paired with skeptics on their own services instead of mandating a process from above. "
        "Within a quarter, design reviews consistently included rollback owners and alert thresholds."
    )
    request = sample_request().model_copy(
        update={
            "rubric": {
                "dimensions": [
                    "requirements",
                    "tradeoffs",
                    "failure_modes",
                    "scope_level_signal",
                    "communication",
                ],
            },
            "answer": answer,
            "user_context": {
                "answer_id": "b10_people_senior_027",
                "question_id": "backend_depth_people_leadership_l5_l6_v0_2",
                "scenario_kind": "behavioral_leadership",
            },
        }
    )
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    output = valid_output_for(judge, request, provider)
    output["level_band"] = "below_bar"
    output["question_id"] = "backend_depth_people_leadership_l5_l6_v0_2"
    output["criterion_marks"] = [
        _criterion_mark("requirements", "Requirements", "missing", "I proposed a release-readiness rubric"),
        _criterion_mark("tradeoffs", "Trade-offs", "missing", "made it lightweight enough to adopt"),
        _criterion_mark("failure_modes", "Failure modes", "missing", "missing ownership cost us hours"),
        _criterion_mark(
            "scope_level_signal",
            "Scope/level signal",
            "partial",
            "paired with skeptics on their own services",
        ),
        _criterion_mark(
            "communication",
            "Communication",
            "partial",
            "Within a quarter, design reviews consistently included rollback owners and alert thresholds",
        ),
    ]
    provider.outputs.append(output)

    response = judge.judge(request)
    canonical = json.loads(response.canonical_json)

    assert canonical["provider_suggested_band"] == "below_bar"
    assert canonical["deterministic_level_band"] == "approaching"
    assert canonical["level_band"] == "approaching"


def test_provider_request_schema_closes_every_object_schema() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    judge.judge(request)

    nodes = iter_schema_nodes(provider.calls[0].response_schema)
    object_schemas = [node for node in nodes if node.get("type") == "object"]
    assert object_schemas
    for schema in object_schemas:
        properties = schema.get("properties", {})
        assert isinstance(properties, dict)
        assert schema["additionalProperties"] is False
        assert set(schema["required"]) == set(properties)
    target_snapshot = provider.calls[0].response_schema["$defs"]["TargetSnapshot"]
    assert "title" in target_snapshot["properties"]
    for node in nodes:
        if "title" in node:
            assert isinstance(node["title"], dict)
        assert "default" not in node
        assert "examples" not in node
        assert "gateway_derived" not in node
    properties = provider.calls[0].response_schema["properties"]
    assert "provider_suggested_band" not in properties
    assert "deterministic_level_band" not in properties


def test_default_policy_allows_one_provider_attempt() -> None:
    policy = PolicyEngine().attach(sample_request(), provider_name="openai")

    assert policy.max_attempts == 1


def test_provider_request_supplies_the_full_deterministic_envelope() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    provider_payload = json.loads(provider.calls[0].messages[1]["content"])

    assert provider_payload["audit_ref"] == response.audit_ref
    assert provider_payload["request_hash"] == response.request_hash
    assert provider_payload["route_hash"] == provider_payload["version_pins"]["route_hash"]
    assert provider_payload["version_pins"]["model_id"] == "gpt-5.4-mini"
    assert provider_payload["version_pins"]["schema_version"] == request.schema_version
    assert provider.calls[0].max_completion_tokens == 1_800
    system_prompt = provider.calls[0].messages[0]["content"]
    assert "behavioral leadership" in system_prompt
    assert "requirements means the situation/problem/constraint" in system_prompt
    assert "deterministic final band is gateway-owned" in system_prompt


def test_transport_error_retries_and_fails_closed() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(
        outputs=[
            ProviderTransportError("timeout user@example.com"),
            ProviderTransportError("timeout user@example.com"),
        ]
    )
    audit = InMemoryAuditSink()
    judge = build_judge(provider, audit_sink=audit, policy_engine=TwoAttemptPolicy())

    with pytest.raises(SchemaValidationRetry):
        judge.judge(request)

    audit_rows = [record.safe_dump() for record in audit.records]
    assert len(provider.calls) == 2
    assert [row["status"] for row in audit_rows] == [
        "provider_transport_error",
        "provider_transport_error",
        "provider_transport_error",
    ]
    assert [row["attempts"] for row in audit_rows] == [1, 2, 2]
    assert "timeout" not in str(audit_rows)
    assert "user@example.com" not in str(audit_rows)


def test_invalid_provider_json_transport_keeps_schema_failure_category() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(
        outputs=[
            ProviderTransportError("invalid_provider_json"),
        ]
    )
    judge = build_judge(provider)

    with pytest.raises(SchemaValidationRetry) as exc:
        judge.judge(request)

    assert exc.value.failure_category == "invalid_provider_json"
    assert exc.value.debug_artifact is not None


def test_output_version_mismatch_is_rejected() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    output = valid_output_for(judge, request, provider)
    output["model_id"] = "wrong-model"
    provider.outputs.append(output)
    provider.outputs.append(output)

    with pytest.raises(SchemaValidationRetry):
        judge.judge(request)


class TinyBudgetPolicy:
    def attach(self, request: JudgeRequest, provider_name: str) -> FeaturePolicy:
        return FeaturePolicy(
            feature=request.feature,
            provider_name=provider_name,
            max_attempts=2,
            timeout_seconds=20.0,
            allow_pii_to_provider=False,
            policy_version=request.routing_policy_version,
            max_prompt_tokens=1,
            max_completion_tokens=16,
            max_total_tokens=17,
            input_usd_per_million_tokens=1.0,
            output_usd_per_million_tokens=4.5,
            max_estimated_cost_usd=0.000001,
        )


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


def _criterion_mark(criterion_id: str, label: str, status: str, quote: str) -> dict[str, object]:
    return {
        "criterion_id": criterion_id,
        "criterion_label": label,
        "status": status,
        "exact_quote": quote,
        "quote_start": 0,
        "quote_end": len(quote),
        "finding": f"{label} is judged {status} from the quoted answer span.",
        "down_level_reason": f"{label} needs tighter proof for the senior bar.",
        "minimum_fix": f"Expand {criterion_id} using the cited quote and one concrete decision.",
    }


def test_token_budget_blocks_before_provider_call() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[ProviderTransportError("should-not-call")])
    audit = InMemoryAuditSink()
    token_usage = InMemoryTokenUsageSink()
    judge = build_judge(
        provider,
        audit_sink=audit,
        token_usage_sink=token_usage,
        policy_engine=TinyBudgetPolicy(),
    )

    with pytest.raises(TokenBudgetExceeded, match="token_budget_exceeded"):
        judge.judge(request)

    assert provider.calls == []
    assert [row.safe_dump()["status"] for row in audit.records] == [
        "token_budget_exceeded:prompt_tokens>1,total_tokens>17,estimated_cost_usd>0.000001"
    ]
    usage = token_usage.records[-1].safe_dump()
    assert usage["attempts"] == 0
    assert usage["prompt_tokens"] is None
    assert usage["estimated_prompt_tokens"] > 1
