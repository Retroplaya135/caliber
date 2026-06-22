from __future__ import annotations

import json
from typing import Any

from caliber_ai_gateway.audit import AuditSink
from caliber_ai_gateway.cache import ExactCache, MemoryExactCache
from caliber_ai_gateway.models import FeatureName, JudgeRequest
from caliber_ai_gateway.policy import PolicyEngine
from caliber_ai_gateway.pipeline import GatewayStructuredJudge
from caliber_ai_gateway.provider import ProviderRegistry
from caliber_ai_gateway.token_usage import TokenUsageSink

from tests.fakes import FakeProviderAdapter


PROMPT_VERSIONS: dict[FeatureName, str] = {
    "interview_content": "interview-content-prompt-v1",
    "resume_bullet": "resume-bullet-prompt-v1",
    "ats_report": "ats-report-prompt-v1",
}


def sample_request(feature: FeatureName = "interview_content") -> JudgeRequest:
    return JudgeRequest(
        schema_version="ai-output-v1",
        prompt_version=PROMPT_VERSIONS[feature],
        corpus_bundle_version="corpus-2026-05-31",
        routing_policy_version="route-policy-v1",
        feature=feature,
        role="Senior Flutter Engineer",
        rubric={"dimensions": ["specificity", "ownership", "tradeoffs"]},
        answer="I led a Riverpod migration and reduced frame drops. Email me at user@example.com.",
        evidence=[
            {
                "source_id": "answer-1",
                "start": 0,
                "end": 65,
                "text": "Call 415-555-2671. I led a Riverpod migration and reduced frame drops.",
            }
        ],
        user_context={"name": "Sensitive Person", "timezone": "America/Los_Angeles"},
    )


def valid_output_for(judge: GatewayStructuredJudge, request: JudgeRequest, provider: FakeProviderAdapter) -> dict[str, Any]:
    prepared = judge.prepare(request, provider)
    del prepared
    base = {"schema_version": request.schema_version}
    target = {
        "schema_version": "target-role-company-v1",
        "role_id": "senior-flutter-engineer",
        "domain": "mobile",
        "level_band": "at_bar",
        "company_archetype": "growth-stage-product-company",
        "title": "Senior Flutter Engineer",
        "market": "US",
        "seniority_order": 5,
        "metadata": {},
    }
    evidence_span = {
        "schema_version": "evidence-span-v1",
        "source_id": "answer-1",
        "source_type": "transcript",
        "start_offset": 0,
        "end_offset": 65,
        "quote": None,
        "metadata": {
            "quote_hash": "a" * 64,
            "criterion_id": "tradeoffs",
            "criterion_label": "Trade-offs",
            "criterion_status": "partial",
            "finding": "Mentions the migration outcome but does not compare the trade-off against alternatives.",
            "down_level_reason": "The answer lacks enough trade-off framing to prove senior-level judgment.",
            "minimum_fix": "Add one before/after trade-off comparison using the cited Riverpod migration evidence.",
        },
    }
    criterion_marks = [
        {
            "criterion_id": "specificity",
            "criterion_label": "Specificity",
            "status": "met",
            "exact_quote": "I led a Riverpod migration and reduced frame drops",
            "quote_start": 0,
            "quote_end": 49,
            "finding": "Names a concrete migration and outcome.",
            "down_level_reason": "Specificity is present enough for this fixture.",
            "minimum_fix": "Keep the concrete migration evidence.",
        },
        {
            "criterion_id": "ownership",
            "criterion_label": "Ownership",
            "status": "met",
            "exact_quote": "I led a Riverpod migration and reduced frame drops",
            "quote_start": 0,
            "quote_end": 49,
            "finding": "Uses first-person ownership language.",
            "down_level_reason": "Ownership is present enough for this fixture.",
            "minimum_fix": "Keep the ownership signal.",
        },
        {
            "criterion_id": "tradeoffs",
            "criterion_label": "Trade-offs",
            "status": "partial",
            "exact_quote": "I led a Riverpod migration and reduced frame drops",
            "quote_start": 0,
            "quote_end": 49,
            "finding": "Mentions the migration outcome but does not compare the trade-off against alternatives.",
            "down_level_reason": "The answer lacks enough trade-off framing to prove senior-level judgment.",
            "minimum_fix": "Add one before/after trade-off comparison using the cited Riverpod migration evidence.",
        },
    ]
    if request.feature == "resume_bullet":
        return {
            **base,
            "bullet_id": "bullet:sample-1",
            "document_id": "resume-doc-1",
            "text": "Reduced Flutter frame drops by leading a measured Riverpod migration.",
            "evidence_atom_ids": ["evidence-atom-1"],
            "evidence_spans": [{**evidence_span, "metadata": {"quote_hash": "b" * 64}}],
            "rewrite_policy_version": "rewrite-policy-v1",
            "prompt_version": request.prompt_version,
            "model_id": provider.model_id,
            "source_bullet_id": None,
            "confidence": 0.82,
        }
    if request.feature == "ats_report":
        ats_evidence_span = {**evidence_span, "metadata": {"quote_hash": "c" * 64}}
        return {
            **base,
            "report_id": "ats:sample-1",
            "document_id": "resume-doc-1",
            "target": target,
            "ats_test_matrix_version": "ats-matrix-v1",
            "keyword_match_version": "keyword-match-v1",
            "extractable_fields": [
                {
                    "schema_version": "ats_extractable_field.v1",
                    "field_key": "mobile_delivery_evidence",
                    "label": "Mobile delivery evidence",
                    "value": "Riverpod migration and reduced frame drops.",
                    "evidence_spans": [ats_evidence_span],
                }
            ],
            "matched_keywords": ["Flutter", "Riverpod"],
            "coverage_gaps": [
                {
                    "schema_version": "ats_coverage_gap.v1",
                    "gap_id": "gap-ci-cd",
                    "keyword": "CI/CD",
                    "reason": "The answer does not include explicit release automation wording.",
                    "severity": "medium",
                    "evidence_spans": [ats_evidence_span],
                }
            ],
            "reasoning": "ATS-tested, text-extractable evidence includes Flutter and Riverpod, while CI/CD remains uncovered.",
            "evidence_spans": [ats_evidence_span],
            "created_at": "2026-05-31T20:00:00Z",
        }
    return {
        **base,
        "judgment_id": "judgment:sample-1",
        "profile_id": "profile-1",
        "target": target,
        "question_id": "question-1",
        "answer_transcript_id": "transcript-1",
        "rubric_version": "rubric-v1",
        "prompt_version": request.prompt_version,
        "model_id": provider.model_id,
        "content_score": 0.78,
        "level_band": "at_bar",
        "strengths": ["Specific ownership is present."],
        "risks": ["Needs deeper metrics."],
        "recommended_actions": ["Add quantified before/after evidence."],
        "criterion_marks": criterion_marks,
        "evidence_spans": [evidence_span],
        "created_at": "2026-05-31T20:00:00Z",
    }


def build_judge(
    provider: FakeProviderAdapter,
    cache: ExactCache | None = None,
    audit_sink: AuditSink | None = None,
    token_usage_sink: TokenUsageSink | None = None,
    policy_engine: PolicyEngine | None = None,
) -> GatewayStructuredJudge:
    registry = ProviderRegistry()
    registry.register(provider)
    return GatewayStructuredJudge(
        registry=registry,
        provider_name="fake",
        cache=cache or MemoryExactCache(),
        audit_sink=audit_sink,
        token_usage_sink=token_usage_sink,
        policy_engine=policy_engine,
    )


def parsed_response_json(canonical: str) -> dict[str, Any]:
    return json.loads(canonical)
