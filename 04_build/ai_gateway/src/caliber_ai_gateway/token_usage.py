from __future__ import annotations

import json
import math
import os
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from caliber_ai_gateway.canonical_json import canonical_json
from caliber_ai_gateway.models import PreparedRequest, ProviderRequest, ProviderResult, TokenUsage
from caliber_ai_gateway.provider import ProviderAdapter


TOKEN_USAGE_SCHEMA_VERSION = "token-usage.v1"
TOKEN_USAGE_SUMMARY_SCHEMA_VERSION = "token-usage-summary.v1"


def estimate_text_tokens(text: str) -> int:
    if not text:
        return 0
    return max(1, math.ceil(len(text) / 4))


def estimate_provider_request_tokens(request: ProviderRequest) -> int:
    message_tokens = 0
    for message in request.messages:
        message_tokens += 4
        message_tokens += estimate_text_tokens(message.get("role", ""))
        message_tokens += estimate_text_tokens(message.get("content", ""))
    schema_tokens = estimate_text_tokens(canonical_json(request.response_schema))
    return message_tokens + schema_tokens + estimate_text_tokens(request.schema_name)


@dataclass(frozen=True)
class TokenUsageRecord:
    audit_ref: str
    request_hash: str
    route_hash: str
    feature: str
    schema_name: str
    provider_name: str
    model_id: str
    cache_hit: bool
    attempts: int
    status: str
    estimated_prompt_tokens: int
    estimated_completion_tokens: int
    estimated_total_tokens: int
    prompt_tokens: int | None
    completion_tokens: int | None
    total_tokens: int | None
    input_characters: int
    output_characters: int
    cache_saved_estimated_tokens: int
    schema_version: str = TOKEN_USAGE_SCHEMA_VERSION
    created_at: str = field(default_factory=lambda: datetime.now(UTC).isoformat())

    def safe_dump(self) -> dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "created_at": self.created_at,
            "audit_ref": self.audit_ref,
            "request_hash": self.request_hash,
            "route_hash": self.route_hash,
            "feature": self.feature,
            "schema_name": self.schema_name,
            "provider_name": self.provider_name,
            "model_id": self.model_id,
            "cache_hit": self.cache_hit,
            "attempts": self.attempts,
            "status": self.status,
            "estimated_prompt_tokens": self.estimated_prompt_tokens,
            "estimated_completion_tokens": self.estimated_completion_tokens,
            "estimated_total_tokens": self.estimated_total_tokens,
            "prompt_tokens": self.prompt_tokens,
            "completion_tokens": self.completion_tokens,
            "total_tokens": self.total_tokens,
            "input_characters": self.input_characters,
            "output_characters": self.output_characters,
            "cache_saved_estimated_tokens": self.cache_saved_estimated_tokens,
        }


class TokenUsageSink:
    def record(self, record: TokenUsageRecord) -> None:
        raise NotImplementedError


class InMemoryTokenUsageSink(TokenUsageSink):
    def __init__(self) -> None:
        self.records: list[TokenUsageRecord] = []

    def record(self, record: TokenUsageRecord) -> None:
        self.records.append(record)


class FileTokenUsageSink(TokenUsageSink):
    def __init__(self, jsonl_path: Path, summary_path: Path) -> None:
        self.jsonl_path = jsonl_path
        self.summary_path = summary_path
        self.jsonl_path.parent.mkdir(parents=True, exist_ok=True)
        self.summary_path.parent.mkdir(parents=True, exist_ok=True)

    def record(self, record: TokenUsageRecord) -> None:
        row = record.safe_dump()
        with self.jsonl_path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(row, sort_keys=True, separators=(",", ":")))
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        self._write_summary(row)

    def _write_summary(self, row: dict[str, Any]) -> None:
        summary = self._load_summary()
        summary["updated_at"] = datetime.now(UTC).isoformat()
        summary["records"] += 1
        _accumulate(summary["totals"], row)
        _accumulate(_bucket(summary["by_model"], row["model_id"]), row)
        _accumulate(_bucket(summary["by_feature"], row["feature"]), row)
        tmp_path = self.summary_path.with_suffix(f"{self.summary_path.suffix}.tmp")
        tmp_path.write_text(
            json.dumps(summary, sort_keys=True, separators=(",", ":")),
            encoding="utf-8",
        )
        tmp_path.replace(self.summary_path)

    def _load_summary(self) -> dict[str, Any]:
        if not self.summary_path.exists():
            return _empty_summary()
        try:
            loaded = json.loads(self.summary_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return _empty_summary()
        if loaded.get("schema_version") != TOKEN_USAGE_SUMMARY_SCHEMA_VERSION:
            return _empty_summary()
        loaded.setdefault("records", 0)
        loaded.setdefault("totals", _empty_bucket())
        loaded.setdefault("by_model", {})
        loaded.setdefault("by_feature", {})
        return loaded


def zero_usage() -> TokenUsage:
    return TokenUsage(prompt_tokens=0, completion_tokens=0, total_tokens=0)


def build_token_usage_record(
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    provider_request: ProviderRequest,
    *,
    audit_ref: str,
    cache_hit: bool,
    attempts: int,
    status: str,
    provider_result: ProviderResult | None,
    output_json: dict[str, Any] | None,
) -> TokenUsageRecord:
    estimated_prompt_tokens = estimate_provider_request_tokens(provider_request)
    estimated_completion_tokens = estimate_text_tokens(canonical_json(output_json or {}))
    usage = provider_result.usage if provider_result is not None else None
    estimated_total_tokens = estimated_prompt_tokens + estimated_completion_tokens
    return TokenUsageRecord(
        audit_ref=audit_ref,
        request_hash=prepared.request_hash,
        route_hash=prepared.route_hash,
        feature=prepared.feature,
        schema_name=prepared.schema_name,
        provider_name=adapter.name,
        model_id=adapter.model_id,
        cache_hit=cache_hit,
        attempts=attempts,
        status=status,
        estimated_prompt_tokens=estimated_prompt_tokens,
        estimated_completion_tokens=estimated_completion_tokens,
        estimated_total_tokens=estimated_total_tokens,
        prompt_tokens=usage.prompt_tokens if usage is not None else None,
        completion_tokens=usage.completion_tokens if usage is not None else None,
        total_tokens=usage.total_tokens if usage is not None else None,
        input_characters=len(canonical_json(provider_request.messages)),
        output_characters=len(canonical_json(output_json or {})),
        cache_saved_estimated_tokens=estimated_total_tokens if cache_hit else 0,
    )


def _empty_summary() -> dict[str, Any]:
    return {
        "schema_version": TOKEN_USAGE_SUMMARY_SCHEMA_VERSION,
        "updated_at": datetime.now(UTC).isoformat(),
        "records": 0,
        "totals": _empty_bucket(),
        "by_model": {},
        "by_feature": {},
    }


def _empty_bucket() -> dict[str, int]:
    return {
        "cache_hits": 0,
        "provider_calls": 0,
        "estimated_prompt_tokens": 0,
        "estimated_completion_tokens": 0,
        "estimated_total_tokens": 0,
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "total_tokens": 0,
        "cache_saved_estimated_tokens": 0,
    }


def _bucket(parent: dict[str, Any], key: str) -> dict[str, int]:
    if key not in parent:
        parent[key] = _empty_bucket()
    return parent[key]


def _accumulate(bucket: dict[str, int], row: dict[str, Any]) -> None:
    if row["cache_hit"]:
        bucket["cache_hits"] += 1
    else:
        bucket["provider_calls"] += 1
    for key in (
        "estimated_prompt_tokens",
        "estimated_completion_tokens",
        "estimated_total_tokens",
        "cache_saved_estimated_tokens",
    ):
        bucket[key] += int(row.get(key) or 0)
    for key in ("prompt_tokens", "completion_tokens", "total_tokens"):
        if row.get(key) is not None:
            bucket[key] += int(row[key])
