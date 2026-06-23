from __future__ import annotations

import json

from caliber_ai_gateway.audit import FileAuditSink, InMemoryAuditSink
from caliber_ai_gateway.cache import MemoryExactCache
from caliber_ai_gateway.pipeline import GatewayStructuredJudge
from caliber_ai_gateway.provider import ProviderRegistry
from tests.fakes import FakeProviderAdapter
from tests.helpers import sample_request, valid_output_for


def test_pii_is_redacted_before_hash_and_provider_call() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    registry = ProviderRegistry()
    registry.register(provider)
    audit = InMemoryAuditSink()
    judge = GatewayStructuredJudge(registry=registry, provider_name="fake", cache=MemoryExactCache(), audit_sink=audit)
    provider.outputs.append(valid_output_for(judge, request, provider))

    response = judge.judge(request)
    provider_payload = provider.calls[0].messages[1]["content"]

    assert "user@example.com" not in provider_payload
    assert "415-555-2671" not in provider_payload
    assert "Sensitive Person" not in provider_payload
    assert "[REDACTED_EMAIL]" in provider_payload
    assert "[REDACTED_PHONE]" in provider_payload
    assert "[REDACTED_FIELD]" in provider_payload
    assert audit.records[-1].safe_dump()["request_hash"] == response.request_hash
    assert audit.records[-1].safe_dump()["redaction_counts"]["email"] == 1
    assert audit.records[-1].safe_dump()["redaction_counts"]["phone"] == 1
    assert audit.records[-1].safe_dump()["redaction_counts"]["field"] == 1


def test_audit_records_cache_hits_without_payload_or_secrets() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    registry = ProviderRegistry()
    registry.register(provider)
    audit = InMemoryAuditSink()
    judge = GatewayStructuredJudge(registry=registry, provider_name="fake", cache=MemoryExactCache(), audit_sink=audit)
    provider.outputs.append(valid_output_for(judge, request, provider))

    judge.judge(request)
    judge.judge(request)

    first, second = [record.safe_dump() for record in audit.records]
    assert first["status"] == "provider_validated"
    assert second["status"] == "cache_hit"
    assert second["cache_hit"] is True
    assert "user@example.com" not in str(second)
    assert "OPENAI_API_KEY" not in str(second)


def test_file_audit_sink_persists_safe_jsonl_without_payload_or_secrets(tmp_path) -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    registry = ProviderRegistry()
    registry.register(provider)
    audit_path = tmp_path / "audit" / "gateway.jsonl"
    audit = FileAuditSink(audit_path)
    judge = GatewayStructuredJudge(registry=registry, provider_name="fake", cache=MemoryExactCache(), audit_sink=audit)
    provider.outputs.append(valid_output_for(judge, request, provider))

    first_response = judge.judge(request)
    second_response = judge.judge(request)

    lines = audit_path.read_text(encoding="utf-8").splitlines()
    persisted = [json.loads(line) for line in lines]

    assert len(persisted) == 2
    assert persisted[0]["request_hash"] == first_response.request_hash
    assert persisted[0]["status"] == "provider_validated"
    assert persisted[1]["status"] == "cache_hit"
    assert persisted[1]["request_hash"] == second_response.request_hash
    assert "canonical_json" not in persisted[0]
    assert "user@example.com" not in audit_path.read_text(encoding="utf-8")
    assert "Sensitive Person" not in audit_path.read_text(encoding="utf-8")
