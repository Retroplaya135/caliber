from __future__ import annotations

from typing import Any

from caliber_ai_gateway.audit import AuditRecord, AuditSink
from caliber_ai_gateway.models import PreparedRequest, ProviderRequest, ProviderResult
from caliber_ai_gateway.provider import ProviderAdapter
from caliber_ai_gateway.token_usage import TokenUsageSink, build_token_usage_record


def audit_ref(request_hash: str) -> str:
    return f"audit:{request_hash[:24]}"


def record_audit(
    sink: AuditSink,
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    *,
    output_hash: str | None,
    cache_hit: bool,
    attempts: int,
    status: str,
) -> str:
    ref = audit_ref(prepared.request_hash)
    sink.record(
        AuditRecord(
            audit_ref=ref,
            request_hash=prepared.request_hash,
            output_hash=output_hash,
            cache_hit=cache_hit,
            provider_name=adapter.name,
            model_id=adapter.model_id,
            attempts=attempts,
            status=status,
            redaction_counts=prepared.redaction_report.counts,
            version_pins=prepared.version_pins,
        )
    )
    return ref


def record_token_usage(
    sink: TokenUsageSink,
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    provider_request: ProviderRequest,
    *,
    audit_ref: str,
    status: str,
    cache_hit: bool,
    attempts: int,
    provider_result: ProviderResult | None,
    output_json: dict[str, Any] | None,
) -> None:
    sink.record(
        build_token_usage_record(
            prepared,
            adapter,
            provider_request,
            audit_ref=audit_ref,
            cache_hit=cache_hit,
            attempts=attempts,
            status=status,
            provider_result=provider_result,
            output_json=output_json,
        )
    )
