from __future__ import annotations

from pydantic import BaseModel

from caliber_ai_gateway.audit import AuditSink
from caliber_ai_gateway.canonical_json import canonical_hash, canonical_json
from caliber_ai_gateway.models import JudgeResponse, PreparedRequest, ProviderRequest, ProviderResult
from caliber_ai_gateway.provider import ProviderAdapter
from caliber_ai_gateway.pipeline_recording import audit_ref, record_audit, record_token_usage
from caliber_ai_gateway.token_usage import TokenUsageSink, zero_usage


def response_from_cache(
    output: BaseModel,
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    provider_request: ProviderRequest,
    audit_sink: AuditSink,
    token_usage_sink: TokenUsageSink,
) -> JudgeResponse:
    output_data = output.model_dump(mode="json")
    output_hash = canonical_hash(output_data)
    audit_reference = record_audit(
        audit_sink,
        prepared,
        adapter,
        output_hash=output_hash,
        cache_hit=True,
        attempts=0,
        status="cache_hit",
    )
    record_token_usage(
        token_usage_sink,
        prepared,
        adapter,
        provider_request,
        audit_ref=audit_reference,
        status="cache_hit",
        cache_hit=True,
        attempts=0,
        provider_result=ProviderResult(output=output_data, usage=zero_usage()),
        output_json=output_data,
    )
    return JudgeResponse(
        request_hash=prepared.request_hash,
        canonical_json=canonical_json(output_data),
        output_hash=output_hash,
        cache_hit=True,
        attempts=0,
        audit_ref=audit_reference,
    )


def response_from_provider(
    output: BaseModel,
    provider_result: ProviderResult,
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    provider_request: ProviderRequest,
    audit_sink: AuditSink,
    token_usage_sink: TokenUsageSink,
    attempts: int,
) -> JudgeResponse:
    output_data = output.model_dump(mode="json")
    output_json = canonical_json(output_data)
    output_hash = canonical_hash(output_data)
    audit_reference = record_audit(
        audit_sink,
        prepared,
        adapter,
        output_hash=output_hash,
        cache_hit=False,
        attempts=attempts,
        status="provider_validated",
    )
    record_token_usage(
        token_usage_sink,
        prepared,
        adapter,
        provider_request,
        audit_ref=audit_reference,
        status="provider_validated",
        cache_hit=False,
        attempts=attempts,
        provider_result=provider_result,
        output_json=output_data,
    )
    return JudgeResponse(
        request_hash=prepared.request_hash,
        canonical_json=output_json,
        output_hash=output_hash,
        cache_hit=False,
        attempts=attempts,
        audit_ref=audit_reference,
    )


def record_retry_failure(
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    provider_request: ProviderRequest,
    audit_sink: AuditSink,
    token_usage_sink: TokenUsageSink,
    attempts: int,
    status: str,
    provider_result: ProviderResult | None,
) -> None:
    record_audit(
        audit_sink,
        prepared,
        adapter,
        output_hash=None,
        cache_hit=False,
        attempts=attempts,
        status=status,
    )
    record_token_usage(
        token_usage_sink,
        prepared,
        adapter,
        provider_request,
        audit_ref=audit_ref(prepared.request_hash),
        status=status,
        cache_hit=False,
        attempts=attempts,
        provider_result=provider_result,
        output_json=None,
    )
