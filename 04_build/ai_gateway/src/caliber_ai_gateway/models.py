from __future__ import annotations

from typing import Any, Literal, TypeAlias

from pydantic import BaseModel, ConfigDict, Field


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True, strict=True)


class EvidenceInput(StrictModel):
    source_id: str = Field(min_length=1)
    start: int = Field(ge=0)
    end: int = Field(ge=0)
    text: str = Field(min_length=1)


FeatureName: TypeAlias = Literal["interview_content", "resume_bullet", "ats_report"]
FunnelEventName: TypeAlias = Literal[
    "packet_created",
    "brief_completed",
    "email_capture",
    "practice_start_click",
    "first_paid_eval_started",
    "verdict_completed",
    "inspect_opened",
    "retest_started",
]


class JudgeRequest(StrictModel):
    schema_version: str = Field(min_length=1)
    prompt_version: str = Field(min_length=1)
    corpus_bundle_version: str = Field(min_length=1)
    routing_policy_version: str = Field(min_length=1)
    feature: FeatureName
    role: str = Field(min_length=1)
    rubric: dict[str, Any]
    answer: str = Field(min_length=1)
    evidence: list[EvidenceInput]
    user_context: dict[str, Any] = Field(default_factory=dict)


class FeaturePolicy(StrictModel):
    feature: FeatureName
    provider_name: str = Field(min_length=1)
    max_attempts: int = Field(ge=1, le=5)
    timeout_seconds: float = Field(gt=0, le=60)
    allow_pii_to_provider: bool
    policy_version: str = Field(min_length=1)
    max_prompt_tokens: int = Field(ge=1)
    max_completion_tokens: int = Field(ge=1)
    max_total_tokens: int = Field(ge=1)
    input_usd_per_million_tokens: float = Field(gt=0)
    output_usd_per_million_tokens: float = Field(gt=0)
    max_estimated_cost_usd: float = Field(gt=0)


class RedactionReport(StrictModel):
    counts: dict[str, int]
    redacted_fields: list[str]


class PreparedRequest(StrictModel):
    feature: FeatureName
    schema_name: str = Field(min_length=1)
    schema_origin: str = Field(min_length=1)
    canonical_input: dict[str, Any]
    policy: FeaturePolicy
    redacted_input: dict[str, Any]
    redaction_report: RedactionReport
    route_hash: str
    request_hash: str
    version_pins: dict[str, str]


class ProviderRequest(StrictModel):
    request_hash: str
    model_id: str
    route_hash: str
    schema_name: str
    response_schema: dict[str, Any]
    messages: list[dict[str, str]]
    timeout_seconds: float
    max_completion_tokens: int = Field(ge=1)


class TokenUsage(StrictModel):
    prompt_tokens: int | None = Field(default=None, ge=0)
    completion_tokens: int | None = Field(default=None, ge=0)
    total_tokens: int | None = Field(default=None, ge=0)


class ProviderResult(StrictModel):
    output: dict[str, Any]
    usage: TokenUsage | None = None


class EvidenceSpan(StrictModel):
    schema_version: str = Field(min_length=1)
    source_id: str = Field(min_length=1)
    source_type: str = Field(min_length=1)
    start_offset: int = Field(ge=0)
    end_offset: int = Field(ge=0)
    quote: str | None
    metadata: dict[str, Any]


class CriterionMark(StrictModel):
    criterion_id: str = Field(min_length=1)
    criterion_label: str = Field(min_length=1)
    status: Literal["met", "partial", "missing"]
    exact_quote: str = Field(min_length=1)
    quote_start: int = Field(ge=0)
    quote_end: int = Field(ge=0)
    finding: str = Field(min_length=1)
    down_level_reason: str = Field(min_length=1)
    minimum_fix: str = Field(min_length=1)


class TargetSnapshot(StrictModel):
    schema_version: str = Field(min_length=1)
    role_id: str = Field(min_length=1)
    domain: str = Field(min_length=1)
    level_band: Literal["below_bar", "approaching", "at_bar", "above_bar"]
    company_archetype: str = Field(min_length=1)
    title: str | None
    market: str | None
    seniority_order: int | None
    metadata: dict[str, Any]


class InterviewContentJudgment(StrictModel):
    schema_version: str = Field(min_length=1)
    judgment_id: str = Field(min_length=1)
    profile_id: str = Field(min_length=1)
    target: TargetSnapshot
    question_id: str = Field(min_length=1)
    answer_transcript_id: str = Field(min_length=1)
    rubric_version: str = Field(min_length=1)
    prompt_version: str = Field(min_length=1)
    model_id: str = Field(min_length=1)
    content_score: float = Field(ge=0, le=1)
    level_band: str = Field(min_length=1)
    provider_suggested_band: str = Field(
        min_length=1,
        json_schema_extra={"gateway_derived": True},
    )
    deterministic_level_band: str = Field(
        min_length=1,
        json_schema_extra={"gateway_derived": True},
    )
    strengths: list[str]
    risks: list[str]
    recommended_actions: list[str]
    criterion_marks: list[CriterionMark] = Field(min_length=1)
    evidence_spans: list[EvidenceSpan] = Field(min_length=1)
    created_at: str = Field(min_length=1)


class ResumeBullet(StrictModel):
    schema_version: str = Field(min_length=1)
    bullet_id: str = Field(min_length=1)
    document_id: str = Field(min_length=1)
    text: str = Field(min_length=1)
    evidence_atom_ids: list[str] = Field(min_length=1)
    evidence_spans: list[EvidenceSpan] = Field(min_length=1)
    rewrite_policy_version: str = Field(min_length=1)
    prompt_version: str = Field(min_length=1)
    model_id: str = Field(min_length=1)
    source_bullet_id: str | None
    confidence: float = Field(ge=0, le=1)


class ATSExtractableField(StrictModel):
    schema_version: str = Field(min_length=1)
    field_key: str = Field(min_length=1)
    label: str = Field(min_length=1)
    value: str = Field(min_length=1)
    evidence_spans: list[EvidenceSpan] = Field(min_length=1)


class ATSCoverageGap(StrictModel):
    schema_version: str = Field(min_length=1)
    gap_id: str = Field(min_length=1)
    keyword: str = Field(min_length=1)
    reason: str = Field(min_length=1)
    severity: str = Field(min_length=1)
    evidence_spans: list[EvidenceSpan] = Field(min_length=1)


class ATSReport(StrictModel):
    schema_version: str = Field(min_length=1)
    report_id: str = Field(min_length=1)
    document_id: str = Field(min_length=1)
    target: TargetSnapshot
    ats_test_matrix_version: str = Field(min_length=1)
    keyword_match_version: str = Field(min_length=1)
    extractable_fields: list[ATSExtractableField] = Field(min_length=1)
    matched_keywords: list[str]
    coverage_gaps: list[ATSCoverageGap] = Field(min_length=1)
    reasoning: str = Field(min_length=1)
    evidence_spans: list[EvidenceSpan] = Field(min_length=1)
    created_at: str = Field(min_length=1)


class JudgeResponse(StrictModel):
    request_hash: str = Field(min_length=64, max_length=64)
    canonical_json: str = Field(min_length=2)
    output_hash: str = Field(min_length=64, max_length=64)
    cache_hit: bool
    attempts: int = Field(ge=0)
    audit_ref: str = Field(min_length=1)


class FunnelEventRequest(StrictModel):
    event_type: FunnelEventName
    anon_profile_id: str = Field(min_length=1)
    ts: str = Field(min_length=1)
    source_hash: str = Field(min_length=1)
    question_id: str | None = None
    corpus_bundle_version: str = Field(min_length=1)


class FunnelIngestResponse(StrictModel):
    accepted: bool
    stored_events: int = Field(ge=0)


class FunnelConversionStep(StrictModel):
    from_event: FunnelEventName
    to_event: FunnelEventName
    from_profiles: int = Field(ge=0)
    to_profiles: int = Field(ge=0)
    rate: float = Field(ge=0, le=1)


class FunnelReadoutResponse(StrictModel):
    schema_version: str = Field(min_length=1)
    total_events: int = Field(ge=0)
    unique_profiles: int = Field(ge=0)
    counts: dict[FunnelEventName, int]
    unique_profile_counts: dict[FunnelEventName, int]
    conversion: list[FunnelConversionStep]
