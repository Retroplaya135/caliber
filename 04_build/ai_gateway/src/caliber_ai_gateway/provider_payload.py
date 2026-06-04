from __future__ import annotations

from typing import Any

from caliber_ai_gateway.canonical_json import canonical_json
from caliber_ai_gateway.models import PreparedRequest, ProviderRequest
from caliber_ai_gateway.provider import ProviderAdapter
from caliber_ai_gateway.schema_json import strict_json_schema


def build_provider_request(
    prepared: PreparedRequest,
    adapter: ProviderAdapter,
    output_model: type[Any],
) -> ProviderRequest:
    return ProviderRequest(
        request_hash=prepared.request_hash,
        model_id=adapter.model_id,
        route_hash=prepared.route_hash,
        schema_name=prepared.schema_name,
        response_schema=strict_json_schema(output_model),
        messages=[
            {
                "role": "system",
                "content": _system_prompt(prepared),
            },
            {
                "role": "user",
                "content": canonical_json(
                    {
                        "audit_ref": f"audit:{prepared.request_hash[:24]}",
                        "request_hash": prepared.request_hash,
                        "route_hash": prepared.route_hash,
                        "model_id": adapter.model_id,
                        "version_pins": prepared.version_pins,
                        "input": prepared.redacted_input,
                    }
                ),
            },
        ],
        timeout_seconds=prepared.policy.timeout_seconds,
        max_completion_tokens=prepared.policy.max_completion_tokens,
    )


def _system_prompt(prepared: PreparedRequest) -> str:
    base = (
        f"Return only a schema-valid caliber {prepared.schema_name}. "
        "Use the supplied deterministic envelope fields exactly."
    )
    if prepared.feature != "interview_content":
        return base
    return (
        f"{base}\n"
        "Interview verdict contract:\n"
        "- Judge only the candidate answer against the supplied rubric_slice body. Do not infer emotion, confidence, camera behavior, or hiring outcome.\n"
        "- level_band must be exactly one of: below_bar, approaching, at_bar, above_bar, but it is only your non-authoritative provider suggestion. The gateway computes the final product band deterministically from criterion_marks and may override level_band.\n"
        "- First return criterion_marks with one item for every rubric Dimension in rubric_slice. Copy criterion_id exactly from the Dimension line; never invent, rename, or omit it.\n"
        "- Each criterion_marks item must include criterion_id, criterion_label, status, exact_quote, quote_start, quote_end, finding, down_level_reason, and minimum_fix.\n"
        "- exact_quote must be an exact substring from input.answer. quote_start/quote_end must point to that span in input.answer.\n"
        "- For behavioral leadership, project deep-dive, incident, or AI-verification questions, interpret the shared Dimension lines in that scenario context: requirements means the situation/problem/constraint, tradeoffs means intervention choices and rejected alternatives, failure_modes means risk/conflict/regression and recovery, scope_level_signal means durable team/system leverage, and communication means clear reflective narrative.\n"
        "- evidence_spans may mirror criterion_marks, but criterion_marks are the source of truth. The gateway will reject missing criterion_marks even if evidence_spans look useful.\n"
        "- Each risk must name the mapped criterion_id in square brackets, e.g. [failure_modes], and must be supported by one evidence quote.\n"
        "- Spend judgment effort on criterion_marks, evidence quotes, mapped risks, and the single fix. Do not add prose explaining level_band; the deterministic final band is gateway-owned.\n"
        "- Anti-inflation: a component list, tool name list, or answer with no explicit trade-off and no failure-mode behavior is below_bar, even if it names Redis, Kafka, queues, or NGINX.\n"
        "- Weak anchor: 'use NGINX because it already exists, add Redis so servers do not crash' is below_bar because requirements, algorithm trade-off, and failure modes are missing.\n"
        "- Senior anchor: an answer that defines requirements, compares at least two options, names failure behavior, gives rollout/metrics, and states a recommendation is at_bar unless it also shows platform-wide ownership.\n"
        "- recommended_actions must contain exactly one highest-leverage next fix. It must name one missing/partial criterion_id in square brackets and include a short exact quote from that criterion mark. Do not use generic wording such as 'preserve the strongest content and tighten one weak spot'.\n"
        "- strengths and risks must be concise, evidence-cited text. content_score is schema compatibility only; do not render it as a user-facing score."
    )
