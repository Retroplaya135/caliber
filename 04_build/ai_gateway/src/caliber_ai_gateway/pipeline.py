from __future__ import annotations

import json
from pathlib import Path
import re
from typing import Any, Protocol

from pydantic import BaseModel, ValidationError

from caliber_ai_gateway.audit import AuditSink, InMemoryAuditSink
from caliber_ai_gateway.budget import TokenBudgetExceeded, enforce_token_budget
from caliber_ai_gateway.cache import ExactCache, MemoryExactCache
from caliber_ai_gateway.canonical_json import canonical_hash, canonical_json
from caliber_ai_gateway.models import JudgeRequest, JudgeResponse, PreparedRequest, ProviderRequest, ProviderResult
from caliber_ai_gateway.policy import PolicyEngine
from caliber_ai_gateway.provider import ProviderAdapter, ProviderRegistry, ProviderTransportError
from caliber_ai_gateway.provider_payload import build_provider_request
from caliber_ai_gateway.pipeline_outcomes import record_retry_failure, response_from_cache, response_from_provider
from caliber_ai_gateway.pipeline_recording import record_audit
from caliber_ai_gateway.redaction import Redactor
from caliber_ai_gateway.schema_core import load_output_schemas
from caliber_ai_gateway.token_usage import (
    InMemoryTokenUsageSink,
    TokenUsageSink,
)


class StructuredJudge(Protocol):
    def judge(self, request: JudgeRequest | dict[str, Any]) -> JudgeResponse:
        """Evaluate structured input and return canonical, validated JSON."""


class SchemaValidationRetry(RuntimeError):
    def __init__(
        self,
        message: str,
        *,
        failure_category: str = "invalid_provider_json",
        debug_artifact: str | None = None,
    ) -> None:
        super().__init__(message)
        self.failure_category = failure_category
        self.debug_artifact = debug_artifact


class GatewayStructuredJudge:
    def __init__(
        self,
        registry: ProviderRegistry,
        provider_name: str = "openai",
        cache: ExactCache | None = None,
        audit_sink: AuditSink | None = None,
        token_usage_sink: TokenUsageSink | None = None,
        policy_engine: PolicyEngine | None = None,
        redactor: Redactor | None = None,
    ) -> None:
        self.registry = registry
        self.provider_name = provider_name
        self.cache = cache or MemoryExactCache()
        self.audit_sink = audit_sink or InMemoryAuditSink()
        self.token_usage_sink = token_usage_sink or InMemoryTokenUsageSink()
        self.policy_engine = policy_engine or PolicyEngine()
        self.redactor = redactor or Redactor()
        self.output_schemas = load_output_schemas()
        self.schema_origin = self.output_schemas["interview_content"].origin

    def judge(self, request: JudgeRequest | dict[str, Any]) -> JudgeResponse:
        parsed_request = request if isinstance(request, JudgeRequest) else JudgeRequest.model_validate(request)
        adapter = self.registry.get(self.provider_name)
        prepared = self.prepare(parsed_request, adapter)
        cached = self.cache.get(prepared.request_hash)
        if cached is not None:
            cached_output = self._validate_cached_output(cached, prepared, adapter)
            if cached_output is not None:
                return response_from_cache(
                    cached_output,
                    prepared,
                    adapter,
                    self._provider_request(prepared, adapter),
                    self.audit_sink,
                    self.token_usage_sink,
                )

        provider_request = self._provider_request(prepared, adapter)
        try:
            enforce_token_budget(provider_request, prepared.policy)
        except TokenBudgetExceeded as exc:
            record_retry_failure(
                prepared,
                adapter,
                provider_request,
                self.audit_sink,
                self.token_usage_sink,
                0,
                str(exc),
                None,
            )
            raise

        attempts = 0
        last_error: Exception | None = None
        for attempt in range(1, prepared.policy.max_attempts + 1):
            attempts = attempt
            provider_result: ProviderResult | None = None
            try:
                provider_result = adapter.complete(provider_request)
                output = self._validate_output(provider_result.output, prepared, adapter)
                output_json = canonical_json(output.model_dump(mode="json"))
                self.cache.set(prepared.request_hash, output_json)
                return response_from_provider(
                    output,
                    provider_result,
                    prepared,
                    adapter,
                    provider_request,
                    self.audit_sink,
                    self.token_usage_sink,
                    attempts,
                )
            except (ProviderTransportError, ValidationError, SchemaValidationRetry) as exc:
                last_error = exc
                failure_status = (
                    exc.safe_status
                    if isinstance(exc, ProviderTransportError)
                    else f"retryable_failure:{_failure_category(exc)}"
                )
                record_retry_failure(
                    prepared,
                    adapter,
                    provider_request,
                    self.audit_sink,
                    self.token_usage_sink,
                    attempt,
                    failure_status,
                    provider_result,
                )
                continue

        final_category = _failure_category(last_error)
        final_status = (
            last_error.safe_status
            if isinstance(last_error, ProviderTransportError)
            else f"failed:{final_category}"
        )
        record_audit(
            self.audit_sink,
            prepared,
            adapter,
            output_hash=None,
            cache_hit=False,
            attempts=attempts,
            status=final_status,
        )
        debug_artifact = _write_schema_failure_debug_artifact(
            prepared,
            adapter,
            failure_category=final_category,
            message=str(last_error) if last_error is not None else "unknown",
        )
        raise SchemaValidationRetry(
            "provider failed to return a schema-valid judgment",
            failure_category=final_category,
            debug_artifact=debug_artifact,
        ) from last_error

    def prepare(self, request: JudgeRequest, adapter: ProviderAdapter) -> PreparedRequest:
        canonical_input = json.loads(canonical_json(request.model_dump(mode="json")))
        output_schema = self.output_schemas[request.feature]
        policy = self.policy_engine.attach(request, provider_name=adapter.name)
        redacted_input, report = self.redactor.redact(canonical_input)
        policy_material = policy.model_dump(mode="json")
        route_hash = canonical_hash(
            {
                "adapter_name": adapter.name,
                "adapter_version": adapter.adapter_version,
                "model_id": adapter.model_id,
                "provider_policy": policy_material,
                "provider_policy_version": policy.policy_version,
                "schema_name": output_schema.schema_name,
                "schema_origin": output_schema.origin,
            }
        )
        version_pins = {
            "schema_version": request.schema_version,
            "prompt_version": request.prompt_version,
            "corpus_bundle_version": request.corpus_bundle_version,
            "routing_policy_version": request.routing_policy_version,
            "model_id": adapter.model_id,
            "route_hash": route_hash,
        }
        request_hash = canonical_hash(
            {
                "redacted_input": redacted_input,
                "version_pins": version_pins,
            }
        )
        return PreparedRequest(
            feature=request.feature,
            schema_name=output_schema.schema_name,
            schema_origin=output_schema.origin,
            canonical_input=canonical_input,
            policy=policy,
            redacted_input=redacted_input,
            redaction_report=report,
            route_hash=route_hash,
            request_hash=request_hash,
            version_pins=version_pins,
        )

    def _provider_request(self, prepared: PreparedRequest, adapter: ProviderAdapter) -> ProviderRequest:
        output_schema = self.output_schemas[prepared.feature]
        return build_provider_request(prepared, adapter, output_schema.model)

    def _validate_output(
        self,
        raw_output: dict[str, Any],
        prepared: PreparedRequest,
        adapter: ProviderAdapter,
    ) -> BaseModel:
        if prepared.feature == "interview_content":
            raw_output = _prefill_interview_gateway_derived_fields(raw_output)
        try:
            output = self.output_schemas[prepared.feature].model.model_validate(raw_output)
        except ValidationError as exc:
            raise SchemaValidationRetry(
                "provider output did not match strict schema",
                failure_category=_schema_validation_category(exc),
            ) from exc
        output_data = output.model_dump(mode="json")
        expected = {
            "schema_version": prepared.version_pins["schema_version"],
            "prompt_version": prepared.version_pins["prompt_version"],
            "model_id": adapter.model_id,
        }
        for key, expected_value in expected.items():
            if key in output_data and output_data[key] != expected_value:
                raise SchemaValidationRetry(
                    f"provider output {key} does not match pinned route material"
                )
        if prepared.feature == "interview_content":
            output_data = _canonicalize_interview_proof(output_data, prepared)
            output = self.output_schemas[prepared.feature].model.model_validate(output_data)
        return output

    def _validate_cached_output(
        self,
        cached: str,
        prepared: PreparedRequest,
        adapter: ProviderAdapter,
    ) -> BaseModel | None:
        try:
            cached_json = json.loads(cached)
            output = self._validate_output(cached_json, prepared, adapter)
        except (json.JSONDecodeError, TypeError, ValidationError, SchemaValidationRetry):
            return None
        if canonical_json(output.model_dump(mode="json")) != cached:
            return None
        return output


_DIMENSION_PATTERN = re.compile(r"^Dimension:\s*([a-z0-9_]+)\s*-\s*(.+)$", re.MULTILINE)
_GENERIC_FIX_FRAGMENTS = (
    "highest-risk rubric miss",
    "first uncovered rubric gap",
    "preserve the strongest content",
    "tighten one weak spot",
    "one weak spot",
)

_SCHEMA_FAILURE_CATEGORIES = {
    "invalid_provider_json",
    "missing_criterion_marks",
    "unknown_criterion_id",
    "quote_not_found",
}


_LEVEL_BANDS = {"below_bar", "approaching", "at_bar", "above_bar"}
_KEY_DIMENSION_IDS = ("requirements", "tradeoffs", "failure_modes")
_BROADER_OWNERSHIP_TERMS = (
    "cross-team",
    "cross team",
    "multi-team",
    "multi team",
    "platform-wide",
    "platform wide",
    "organization",
    "org-wide",
    "roadmap",
    "strategy",
    "ownership",
    "migration plan",
    "rollout plan",
)
_BEHAVIORAL_LEADERSHIP_CONTEXT_TERMS = (
    "people_leadership",
    "technical_leadership",
    "behavioral_leadership",
)


def _prefill_interview_gateway_derived_fields(raw_output: dict[str, Any]) -> dict[str, Any]:
    output_data = dict(raw_output)
    provider_band = str(
        output_data.get("provider_suggested_band")
        or output_data.get("level_band")
        or "below_bar"
    ).strip()
    output_data.setdefault("provider_suggested_band", provider_band)
    output_data.setdefault("deterministic_level_band", provider_band)
    return output_data


def _canonicalize_interview_proof(
    output_data: dict[str, Any],
    prepared: PreparedRequest,
) -> dict[str, Any]:
    marks = output_data.get("criterion_marks")
    if not isinstance(marks, list) or not marks:
        raise SchemaValidationRetry(
            "interview output must include criterion_marks",
            failure_category="missing_criterion_marks",
        )

    dimensions = _rubric_dimensions(prepared.canonical_input)
    if not dimensions:
        raise SchemaValidationRetry(
            "interview request did not include rubric dimensions",
            failure_category="missing_criterion_marks",
        )
    expected_ids = set(dimensions)
    seen_ids: set[str] = set()
    answer = str(prepared.canonical_input.get("answer", ""))
    canonical_marks: list[dict[str, Any]] = []
    for index, raw_mark in enumerate(marks):
        if not isinstance(raw_mark, dict):
            raise SchemaValidationRetry(
                f"criterion mark {index} is malformed",
                failure_category="missing_criterion_marks",
            )
        criterion_id = str(raw_mark.get("criterion_id", "")).strip()
        if not criterion_id:
            raise SchemaValidationRetry(
                f"criterion mark {index} missing criterion_id",
                failure_category="missing_criterion_marks",
            )
        if criterion_id not in dimensions:
            raise SchemaValidationRetry(
                f"criterion mark {index} unknown criterion_id {criterion_id}",
                failure_category="unknown_criterion_id",
            )
        if criterion_id in seen_ids:
            raise SchemaValidationRetry(
                f"criterion mark {index} duplicated criterion_id {criterion_id}",
                failure_category="invalid_provider_json",
            )
        seen_ids.add(criterion_id)
        quote = str(raw_mark.get("exact_quote", "")).strip()
        resolved_quote = _resolve_quote_span(
            answer,
            quote,
            raw_mark.get("quote_start"),
            raw_mark.get("quote_end"),
        )
        if resolved_quote is None:
            raise SchemaValidationRetry(
                f"criterion mark {index} quote is not in answer",
                failure_category="quote_not_found",
            )
        quote, quote_start, quote_end = resolved_quote
        status = str(raw_mark.get("status", "")).strip()
        if status not in {"met", "partial", "missing"}:
            raise SchemaValidationRetry(
                f"criterion mark {index} status is invalid",
                failure_category="invalid_provider_json",
            )
        mark = dict(raw_mark)
        mark["criterion_id"] = criterion_id
        mark["criterion_label"] = str(mark.get("criterion_label") or dimensions[criterion_id]).strip()
        mark["status"] = status
        mark["exact_quote"] = quote
        mark["quote_start"] = quote_start
        mark["quote_end"] = quote_end
        for field in ("finding", "down_level_reason", "minimum_fix"):
            if not str(mark.get(field, "")).strip():
                raise SchemaValidationRetry(
                    f"criterion mark {index} missing {field}",
                    failure_category="invalid_provider_json",
                )
            mark[field] = str(mark[field]).strip()
        canonical_marks.append(mark)

    missing_ids = expected_ids.difference(seen_ids)
    if missing_ids:
        raise SchemaValidationRetry(
            f"criterion_marks missing rubric dimensions: {', '.join(sorted(missing_ids))}",
            failure_category="missing_criterion_marks",
        )

    partial_or_missing = [
        mark for mark in canonical_marks if mark["status"] in {"partial", "missing"}
    ]
    if not partial_or_missing:
        raise SchemaValidationRetry(
            "recommended fix requires one partial or missing criterion",
            failure_category="invalid_provider_json",
        )

    provider_actions = [
        str(action).strip()
        for action in output_data.get("recommended_actions", [])
        if str(action).strip()
    ]
    if len(provider_actions) > 1:
        raise SchemaValidationRetry(
            "interview output must include at most one recommended action",
            failure_category="invalid_provider_json",
        )

    fix_mark = partial_or_missing[0]
    recommended_action = (
        f"[{fix_mark['criterion_id']}] {fix_mark['minimum_fix']} "
        f'Evidence: "{fix_mark["exact_quote"]}"'
    )
    if _is_generic_fix(recommended_action):
        raise SchemaValidationRetry(
            "interview recommended action is generic",
            failure_category="invalid_provider_json",
        )

    provider_suggested_band = str(
        output_data.get("provider_suggested_band")
        or output_data.get("level_band")
        or "below_bar"
    ).strip()
    if provider_suggested_band not in _LEVEL_BANDS:
        provider_suggested_band = "below_bar"
    deterministic_level_band = _deterministic_level_band(
        canonical_marks,
        prepared.canonical_input,
    )

    output_data = dict(output_data)
    output_data["provider_suggested_band"] = provider_suggested_band
    output_data["deterministic_level_band"] = deterministic_level_band
    output_data["level_band"] = deterministic_level_band
    output_data["criterion_marks"] = canonical_marks
    output_data["evidence_spans"] = [
        _evidence_span_from_mark(mark, output_data)
        for mark in canonical_marks
    ]
    output_data["risks"] = [
        f"[{mark['criterion_id']}] {mark['down_level_reason']} "
        f'Evidence: "{_short_quote(mark["exact_quote"])}"'
        for mark in partial_or_missing
    ]
    output_data["recommended_actions"] = [recommended_action]
    return output_data


def _deterministic_level_band(
    canonical_marks: list[dict[str, Any]],
    canonical_input: dict[str, Any],
) -> str:
    statuses = {
        str(mark["criterion_id"]): str(mark["status"])
        for mark in canonical_marks
    }
    missing_count = sum(1 for status in statuses.values() if status == "missing")
    partial_count = sum(1 for status in statuses.values() if status == "partial")
    partial_or_met_count = sum(
        1 for status in statuses.values() if status in {"partial", "met"}
    )
    if (
        _is_behavioral_leadership_context(canonical_input)
        and partial_or_met_count >= 2
        and statuses.get("scope_level_signal") in {"partial", "met"}
        and statuses.get("communication") in {"partial", "met"}
        and _has_broader_ownership_signal(canonical_marks)
    ):
        return "approaching"
    if missing_count >= 3:
        return "below_bar"
    if all(statuses.get(key) == "missing" for key in _KEY_DIMENSION_IDS):
        return "below_bar"
    if missing_count == 2:
        return "approaching"
    if partial_count > len(statuses) / 2:
        return "approaching"
    key_dimensions_present = all(
        statuses.get(key) in {"met", "partial"}
        for key in _KEY_DIMENSION_IDS
        if key in statuses
    )
    if missing_count <= 1 and key_dimensions_present:
        if all(status == "met" for status in statuses.values()) and _has_broader_ownership_signal(canonical_marks):
            return "above_bar"
        return "at_bar"
    return "approaching"


def _is_behavioral_leadership_context(canonical_input: dict[str, Any]) -> bool:
    user_context = canonical_input.get("user_context")
    values: list[str] = []
    for key in ("question_id", "archetype_id", "scenario_kind"):
        value = canonical_input.get(key)
        if value is not None:
            values.append(str(value))
    if isinstance(user_context, dict):
        for key in ("question_id", "archetype_id", "scenario_kind", "answer_id"):
            value = user_context.get(key)
            if value is not None:
                values.append(str(value))
    rubric = canonical_input.get("rubric")
    if isinstance(rubric, dict):
        for key in ("question_id", "archetype_id", "scenario_kind"):
            value = rubric.get(key)
            if value is not None:
                values.append(str(value))
    haystack = " ".join(values).lower()
    return any(term in haystack for term in _BEHAVIORAL_LEADERSHIP_CONTEXT_TERMS)


def _has_broader_ownership_signal(canonical_marks: list[dict[str, Any]]) -> bool:
    text = " ".join(
        str(mark.get(field, ""))
        for mark in canonical_marks
        for field in ("exact_quote", "finding", "down_level_reason", "minimum_fix")
    ).lower()
    return any(term in text for term in _BROADER_OWNERSHIP_TERMS)


def _resolve_quote_span(
    answer: str,
    quote: str,
    raw_start: object | None = None,
    raw_end: object | None = None,
) -> tuple[str, int, int] | None:
    if not quote:
        return None
    if quote in answer:
        start = answer.index(quote)
        return quote, start, start + len(quote)

    offset_quote = _resolve_quote_span_from_offsets(answer, quote, raw_start, raw_end)
    if offset_quote is not None:
        return offset_quote

    normalized_answer, answer_map = _normalized_with_offsets(answer)
    normalized_quote, _ = _normalized_with_offsets(quote)
    if not normalized_quote:
        return None
    start = normalized_answer.find(normalized_quote)
    if start < 0:
        return None
    end = start + len(normalized_quote) - 1
    if start >= len(answer_map) or end >= len(answer_map):
        return None
    original_start = answer_map[start]
    original_end = answer_map[end] + 1
    exact = answer[original_start:original_end].strip()
    if not exact or exact not in answer:
        return None
    exact_start = answer.index(exact)
    return exact, exact_start, exact_start + len(exact)


def _resolve_quote_span_from_offsets(
    answer: str,
    quote: str,
    raw_start: object | None,
    raw_end: object | None,
) -> tuple[str, int, int] | None:
    if not isinstance(raw_start, int) or not isinstance(raw_end, int):
        return None
    if raw_start < 0 or raw_end <= raw_start or raw_end > len(answer):
        return None
    exact = answer[raw_start:raw_end].strip()
    if not exact:
        return None
    normalized_exact, _ = _normalized_with_offsets(exact)
    normalized_quote, _ = _normalized_with_offsets(quote)
    if normalized_exact != normalized_quote:
        return None
    exact_start = answer.index(exact)
    return exact, exact_start, exact_start + len(exact)


def _normalized_with_offsets(value: str) -> tuple[str, list[int]]:
    chars: list[str] = []
    offsets: list[int] = []
    previous_space = False
    for index, raw_char in enumerate(value):
        char = _normalize_quote_char(raw_char)
        if char.isspace():
            if previous_space:
                continue
            chars.append(" ")
            offsets.append(index)
            previous_space = True
            continue
        chars.append(char)
        offsets.append(index)
        previous_space = False
    normalized = "".join(chars).strip()
    if len(normalized) == len(chars):
        return normalized, offsets
    leading = len("".join(chars)) - len("".join(chars).lstrip())
    trailing_trimmed = len("".join(chars).rstrip())
    return normalized, offsets[leading:trailing_trimmed]


def _normalize_quote_char(value: str) -> str:
    return {
        "\u2018": "'",
        "\u2019": "'",
        "\u201c": '"',
        "\u201d": '"',
        "\u2013": "-",
        "\u2014": "-",
    }.get(value, value)


def _rubric_dimensions(canonical_input: dict[str, Any]) -> dict[str, str]:
    rubric = canonical_input.get("rubric")
    if not isinstance(rubric, dict):
        return {}
    dimensions: dict[str, str] = {}
    raw_dimensions = rubric.get("dimensions")
    if isinstance(raw_dimensions, list):
        for item in raw_dimensions:
            criterion_id = str(item).strip()
            if criterion_id:
                dimensions[criterion_id] = criterion_id
    for key in ("rubric_slices", "records"):
        records = rubric.get(key)
        if not isinstance(records, list):
            continue
        for record in records:
            if not isinstance(record, dict):
                continue
            body = str(record.get("body", ""))
            for match in _DIMENSION_PATTERN.finditer(body):
                dimensions[match.group(1).strip()] = match.group(2).strip()
    return dimensions


def _evidence_span_from_mark(mark: dict[str, Any], output_data: dict[str, Any]) -> dict[str, Any]:
    metadata = {
        "criterion_id": mark["criterion_id"],
        "criterion_label": mark["criterion_label"],
        "criterion_status": mark["status"],
        "provider_suggested_band": output_data["provider_suggested_band"],
        "deterministic_level_band": output_data["deterministic_level_band"],
        "exact_quote": mark["exact_quote"],
        "finding": mark["finding"],
        "down_level_reason": mark["down_level_reason"],
        "minimum_fix": mark["minimum_fix"],
    }
    return {
        "schema_version": "evidence-span-v1",
        "source_id": str(output_data.get("answer_transcript_id", "answer")),
        "source_type": "answer_transcript",
        "start_offset": mark["quote_start"],
        "end_offset": mark["quote_end"],
        "quote": mark["exact_quote"],
        "metadata": metadata,
    }


def _short_quote(value: str) -> str:
    normalized = " ".join(value.split())
    if len(normalized) <= 96:
        return normalized
    return f"{normalized[:93]}..."


def _is_generic_fix(value: str) -> bool:
    lower = value.lower()
    return any(fragment in lower for fragment in _GENERIC_FIX_FRAGMENTS)


def _schema_validation_category(exc: ValidationError) -> str:
    errors = exc.errors(include_url=False)
    if len(errors) == 1 and "criterion_marks" in errors[0].get("loc", ()):
        return "missing_criterion_marks"
    return "invalid_provider_json"


def _failure_category(error: Exception | None) -> str:
    if isinstance(error, SchemaValidationRetry):
        return error.failure_category
    if isinstance(error, ProviderTransportError):
        if error.safe_status in _SCHEMA_FAILURE_CATEGORIES:
            return error.safe_status
        return "provider_error"
    if isinstance(error, ValidationError):
        return _schema_validation_category(error)
    return "invalid_provider_json"


def _write_schema_failure_debug_artifact(
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    *,
    failure_category: str,
    message: str,
) -> str:
    root = Path(__file__).resolve().parents[4]
    debug_dir = root / ".cache" / "ai_gateway" / "schema_failures"
    debug_dir.mkdir(parents=True, exist_ok=True)
    file = debug_dir / f"{prepared.request_hash}.json"
    canonical_input = prepared.canonical_input
    rubric = canonical_input.get("rubric")
    user_context = canonical_input.get("user_context")
    safe_rubric = rubric if isinstance(rubric, dict) else {}
    safe_context = user_context if isinstance(user_context, dict) else {}
    file.write_text(
        json.dumps(
            {
                "schema_version": "caliber_gateway_schema_failure_debug.v0.1",
                "request_hash": prepared.request_hash,
                "prompt_version": prepared.version_pins.get("prompt_version"),
                "model_id": adapter.model_id,
                "failure_category": failure_category,
                "fixture_id": safe_context.get("answer_id") or safe_rubric.get("answer_id"),
                "selected_archetype_id": safe_context.get("question_id")
                or safe_rubric.get("question_id"),
                "message": message[:240],
            },
            indent=2,
            sort_keys=True,
        ),
        encoding="utf-8",
    )
    return str(file)
