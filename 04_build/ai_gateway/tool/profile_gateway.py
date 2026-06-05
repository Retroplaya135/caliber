#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import time
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from caliber_ai_gateway.cache import MemoryExactCache
from caliber_ai_gateway.models import JudgeRequest, ProviderRequest
from caliber_ai_gateway.pipeline import GatewayStructuredJudge
from caliber_ai_gateway.provider import ProviderRegistry


ITERATIONS = 25
CACHE_HIT_P95_LIMIT_MS = 100.0


class ProfileProviderAdapter:
    name = "profile"
    model_id = "gpt-5.4-mini"
    adapter_version = "profile-provider-v1"

    def __init__(self) -> None:
        self.calls: list[ProviderRequest] = []

    def complete(self, request: ProviderRequest) -> dict[str, Any]:
        self.calls.append(request)
        return {
            "schema_version": "ai-output-v1",
            "judgment_id": "judgment:profile-1",
            "profile_id": "profile-1",
            "target": {
                "schema_version": "target-role-company-v1",
                "role_id": "senior-flutter-engineer",
                "domain": "mobile",
                "level_band": "senior",
                "company_archetype": "growth-stage-product-company",
                "title": "Senior Flutter Engineer",
                "market": "US",
                "seniority_order": 5,
                "metadata": {},
            },
            "question_id": "question-1",
            "answer_transcript_id": "transcript-1",
            "rubric_version": "rubric-v1",
            "prompt_version": "interview-content-prompt-v1",
            "model_id": request.model_id,
            "content_score": 0.78,
            "level_band": "senior",
            "strengths": ["Specific ownership is present."],
            "risks": ["Needs deeper metrics."],
            "recommended_actions": ["Add quantified before/after evidence."],
            "evidence_spans": [
                {
                    "schema_version": "evidence-span-v1",
                    "source_id": "answer-1",
                    "source_type": "transcript",
                    "start_offset": 0,
                    "end_offset": 65,
                    "quote": None,
                    "metadata": {"quote_hash": "a" * 64},
                }
            ],
            "created_at": "2026-05-31T20:00:00Z",
        }


def sample_request() -> JudgeRequest:
    return JudgeRequest(
        schema_version="ai-output-v1",
        prompt_version="interview-content-prompt-v1",
        corpus_bundle_version="corpus-2026-05-31",
        routing_policy_version="route-policy-v1",
        feature="interview_content",
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


def elapsed_ms(start_ns: int, end_ns: int) -> float:
    return round((end_ns - start_ns) / 1_000_000, 3)


def percentile(values: list[float], percentile_value: float) -> float:
    ordered = sorted(values)
    index = max(0, min(len(ordered) - 1, int((len(ordered) - 1) * percentile_value)))
    return ordered[index]


def run_profile() -> dict[str, Any]:
    provider = ProfileProviderAdapter()
    registry = ProviderRegistry()
    registry.register(provider)
    judge = GatewayStructuredJudge(registry=registry, provider_name="profile", cache=MemoryExactCache())
    request = sample_request()

    start_ns = time.perf_counter_ns()
    cold = judge.judge(request)
    cold_miss_ms = elapsed_ms(start_ns, time.perf_counter_ns())

    hit_ms: list[float] = []
    canonical_outputs = {cold.canonical_json}
    cache_hit_flags: list[bool] = []
    for _ in range(ITERATIONS):
        start_ns = time.perf_counter_ns()
        hit = judge.judge(request)
        hit_ms.append(elapsed_ms(start_ns, time.perf_counter_ns()))
        canonical_outputs.add(hit.canonical_json)
        cache_hit_flags.append(hit.cache_hit)

    cache_hit_p95_ms = percentile(hit_ms, 0.95)
    pass_checks = {
        "provider_calls_once": len(provider.calls) == 1,
        "all_replays_cache_hits": all(cache_hit_flags),
        "canonical_json_stable": len(canonical_outputs) == 1,
        "cache_hit_p95_under_limit": cache_hit_p95_ms <= CACHE_HIT_P95_LIMIT_MS,
        "product_model_pin": provider.model_id == "gpt-5.4-mini",
    }
    return {
        "marker": "CALIBER-PROFILE-CLEAN",
        "version": "gateway-profile-v1",
        "iterations": ITERATIONS,
        "schema_origin": judge.schema_origin,
        "product_model": provider.model_id,
        "cold_miss_ms": cold_miss_ms,
        "cache_hit_min_ms": min(hit_ms),
        "cache_hit_median_ms": percentile(hit_ms, 0.50),
        "cache_hit_p95_ms": cache_hit_p95_ms,
        "cache_hit_limit_ms": CACHE_HIT_P95_LIMIT_MS,
        "provider_calls": len(provider.calls),
        "request_hash": cold.request_hash,
        "output_hash": cold.output_hash,
        "audit_ref": cold.audit_ref,
        "checks": pass_checks,
        "status": "pass" if all(pass_checks.values()) else "fail",
    }


def main() -> int:
    result = run_profile()
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
