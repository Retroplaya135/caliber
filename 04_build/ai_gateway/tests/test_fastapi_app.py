from __future__ import annotations

from typing import Any

import pytest
from fastapi.testclient import TestClient

from caliber_ai_gateway.app import build_default_judge, create_app
from caliber_ai_gateway.audit import FileAuditSink
from caliber_ai_gateway.benchmark import BenchmarkFeedbackService
from caliber_ai_gateway.budget import TokenBudgetExceeded
from caliber_ai_gateway.cache import FileExactCache
from caliber_ai_gateway.funnel import JsonlFunnelStore
from caliber_ai_gateway.models import TokenUsage
from caliber_ai_gateway.pipeline import SchemaValidationRetry
from caliber_ai_gateway.provider import ProviderTransportError
from caliber_ai_gateway.token_usage import FileTokenUsageSink
from tests.fakes import FakeProviderAdapter
from tests.helpers import build_judge, sample_request, valid_output_for


def test_fastapi_judge_endpoint_returns_canonical_gateway_response() -> None:
    request = sample_request()
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    provider.outputs.append(valid_output_for(judge, request, provider))
    client = TestClient(create_app(judge))

    response = client.post("/v1/judge/interview", json=request.model_dump(mode="json"))

    assert response.status_code == 200
    payload = response.json()
    assert payload["request_hash"]
    assert payload["canonical_json"].startswith("{")
    assert payload["cache_hit"] is False


def test_fastapi_generic_resume_and_ats_endpoints_route_structured_outputs() -> None:
    provider = FakeProviderAdapter(outputs=[])
    judge = build_judge(provider)
    resume_request = sample_request("resume_bullet")
    ats_request = sample_request("ats_report")
    provider.outputs.append(valid_output_for(judge, resume_request, provider))
    provider.outputs.append(valid_output_for(judge, ats_request, provider))
    client = TestClient(create_app(judge))

    resume_response = client.post("/v1/judge/resume-bullet", json=resume_request.model_dump(mode="json"))
    ats_response = client.post("/v1/judge", json=ats_request.model_dump(mode="json"))

    assert resume_response.status_code == 200
    assert ats_response.status_code == 200
    assert provider.calls[0].schema_name == "resume_bullet"
    assert provider.calls[1].schema_name == "ats_report"


def test_fastapi_feature_specific_endpoint_rejects_mismatched_feature() -> None:
    provider = FakeProviderAdapter(outputs=[])
    client = TestClient(create_app(build_judge(provider)))

    response = client.post("/v1/judge/ats", json=sample_request("resume_bullet").model_dump(mode="json"))

    assert response.status_code == 422
    assert response.json()["detail"] == "feature_path_mismatch"
    assert provider.calls == []


def test_fastapi_endpoint_maps_schema_failure_to_bad_gateway() -> None:
    class FailingJudge:
        def judge(self, request: Any) -> None:
            raise SchemaValidationRetry(
                "schema-invalid",
                failure_category="missing_criterion_marks",
                debug_artifact="/tmp/caliber-safe-debug.json",
            )

    client = TestClient(create_app(FailingJudge()))

    response = client.post("/v1/judge/interview", json=sample_request().model_dump(mode="json"))

    assert response.status_code == 502
    assert response.json()["detail"] == {
        "error": "provider_schema_validation_failed",
        "failure_category": "missing_criterion_marks",
        "debug_artifact": "/tmp/caliber-safe-debug.json",
    }


def test_fastapi_endpoint_maps_token_budget_failure_to_payload_too_large() -> None:
    class BudgetFailingJudge:
        def judge(self, request: Any) -> None:
            raise TokenBudgetExceeded("token_budget_exceeded:prompt_tokens>1")

    client = TestClient(create_app(BudgetFailingJudge()))

    response = client.post("/v1/judge/interview", json=sample_request().model_dump(mode="json"))

    assert response.status_code == 413
    assert response.json()["detail"] == "token_budget_exceeded:prompt_tokens>1"


def test_default_judge_uses_file_cache_file_audit_and_product_model(tmp_path) -> None:
    config_dir = tmp_path / "config" / "ai"
    config_dir.mkdir(parents=True)
    (config_dir / "provider_adapter.yaml").write_text(
        "\n".join(
            [
                "provider_adapter:",
                "  default_model: gpt-5.4-mini",
                "  strict_structured_outputs: true",
                "  gateway_only: true",
                "  notes: []",
            ]
        ),
        encoding="utf-8",
    )

    judge = build_default_judge(repo_root=tmp_path)

    assert isinstance(judge.cache, FileExactCache)
    assert isinstance(judge.audit_sink, FileAuditSink)
    assert isinstance(judge.token_usage_sink, FileTokenUsageSink)
    assert judge.cache.root == tmp_path / ".cache" / "ai_gateway" / "responses"
    assert judge.audit_sink.path == tmp_path / ".cache" / "ai_gateway" / "audit.jsonl"
    assert judge.token_usage_sink.jsonl_path == tmp_path / ".cache" / "ai_gateway" / "token_usage.jsonl"
    assert judge.token_usage_sink.summary_path == tmp_path / ".cache" / "ai_gateway" / "token_usage_summary.json"
    assert judge.registry.get("openai").model_id == "gpt-5.4-mini"


def test_default_judge_honors_cache_root_override(tmp_path, monkeypatch: pytest.MonkeyPatch) -> None:
    config_dir = tmp_path / "config" / "ai"
    config_dir.mkdir(parents=True)
    (config_dir / "provider_adapter.yaml").write_text(
        "\n".join(
            [
                "provider_adapter:",
                "  default_model: gpt-5.4-mini",
                "  strict_structured_outputs: true",
                "  gateway_only: true",
                "  notes: []",
            ]
        ),
        encoding="utf-8",
    )
    cache_root = tmp_path / "cold-proof-cache"
    monkeypatch.setenv("CALIBER_AI_GATEWAY_CACHE_ROOT", str(cache_root))

    judge = build_default_judge(repo_root=tmp_path)

    assert isinstance(judge.cache, FileExactCache)
    assert isinstance(judge.audit_sink, FileAuditSink)
    assert isinstance(judge.token_usage_sink, FileTokenUsageSink)
    assert judge.cache.root == cache_root / "responses"
    assert judge.audit_sink.path == cache_root / "audit.jsonl"
    assert judge.token_usage_sink.jsonl_path == cache_root / "token_usage.jsonl"
    assert judge.token_usage_sink.summary_path == cache_root / "token_usage_summary.json"


def test_fastapi_benchmark_endpoint_returns_generic_feedback_metadata() -> None:
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            benchmark_service=BenchmarkFeedbackService(
                providers={
                    "chatgpt": _FakeBenchmarkProvider("chatgpt", "gpt-5.4-mini"),
                    "claude": _FakeBenchmarkProvider(
                        "claude", "claude-haiku-4-5-20251001"
                    ),
                    "openrouter_baseline1": _FakeBenchmarkProvider(
                        "openrouter_baseline1",
                        "test/openrouter-gpt",
                    ),
                    "openrouter_baseline2": _FakeBenchmarkProvider(
                        "openrouter_baseline2",
                        "test/openrouter-alt",
                    ),
                }
            ),
        )
    )

    response = client.post(
        "/v1/benchmark/generic-feedback",
        json={
            "provider": "chatgpt",
            "answer_id": "answer-1",
            "question_id": "question-1",
            "role": "Backend Engineer",
            "question": "Design a rate limiter.",
            "answer": "I would start by defining quotas, then compare token bucket and sliding windows.",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["provider"] == "chatgpt"
    assert payload["model_id"] == "gpt-5.4-mini"
    assert payload["attempts"] == 1
    assert payload["total_tokens"] == 15
    assert payload["estimated_cost_usd"] > 0


def test_fastapi_benchmark_endpoint_accepts_openrouter_baseline_lanes() -> None:
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            benchmark_service=BenchmarkFeedbackService(
                providers={
                    "chatgpt": _FakeBenchmarkProvider("chatgpt", "gpt-5.4-mini"),
                    "claude": _FakeBenchmarkProvider(
                        "claude", "claude-haiku-4-5-20251001"
                    ),
                    "openrouter_baseline1": _FakeBenchmarkProvider(
                        "openrouter_baseline1",
                        "test/openrouter-gpt",
                    ),
                    "openrouter_baseline2": _FakeBenchmarkProvider(
                        "openrouter_baseline2",
                        "test/openrouter-alt",
                    ),
                }
            ),
        )
    )

    response = client.post(
        "/v1/benchmark/generic-feedback",
        json={
            "provider": "openrouter_baseline2",
            "answer_id": "answer-1",
            "question_id": "question-1",
            "role": "Backend Engineer",
            "question": "Design a rate limiter.",
            "answer": "I would start by defining quotas, then compare token bucket and sliding windows.",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["provider"] == "openrouter_baseline2"
    assert payload["model_id"] == "test/openrouter-alt"
    assert payload["attempts"] == 1


def test_fastapi_benchmark_endpoint_hides_raw_provider_errors() -> None:
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            benchmark_service=BenchmarkFeedbackService(
                providers={
                    "chatgpt": _FakeBenchmarkProvider(
                        "chatgpt",
                        "gpt-5.4-mini",
                        error=ProviderTransportError("raw timeout user@example.com"),
                    ),
                    "claude": _FakeBenchmarkProvider(
                        "claude", "claude-haiku-4-5-20251001"
                    ),
                    "openrouter_baseline1": _FakeBenchmarkProvider(
                        "openrouter_baseline1",
                        "test/openrouter-gpt",
                    ),
                    "openrouter_baseline2": _FakeBenchmarkProvider(
                        "openrouter_baseline2",
                        "test/openrouter-alt",
                    ),
                }
            ),
        )
    )

    response = client.post(
        "/v1/benchmark/generic-feedback",
        json={
            "provider": "chatgpt",
            "answer_id": "answer-1",
            "question_id": "question-1",
            "role": "Backend Engineer",
            "question": "Design a rate limiter.",
            "answer": "I would use Redis.",
        },
    )

    assert response.status_code == 502
    assert response.json()["detail"] == "provider_transport_error"


def test_funnel_endpoint_persists_events_from_multiple_profiles(tmp_path) -> None:
    store = JsonlFunnelStore(tmp_path / "funnel_events.jsonl")
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            funnel_store=store,
        )
    )
    events = [
        {
            "event_type": "packet_created",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T11:59:00.000Z",
            "source_hash": "jd-a",
            "question_id": None,
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "brief_completed",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:00:00.000Z",
            "source_hash": "jd-a",
            "question_id": None,
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "practice_start_click",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:01:00.000Z",
            "source_hash": "jd-a",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "first_paid_eval_started",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:02:00.000Z",
            "source_hash": "jd-a",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "verdict_completed",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:03:00.000Z",
            "source_hash": "jd-a",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "inspect_opened",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:04:00.000Z",
            "source_hash": "jd-a",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "retest_started",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:05:00.000Z",
            "source_hash": "jd-a",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "packet_created",
            "anon_profile_id": "anon-b",
            "ts": "2026-06-06T12:06:00.000Z",
            "source_hash": "jd-b",
            "question_id": None,
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "brief_completed",
            "anon_profile_id": "anon-b",
            "ts": "2026-06-06T12:07:00.000Z",
            "source_hash": "jd-b",
            "question_id": None,
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
        {
            "event_type": "practice_start_click",
            "anon_profile_id": "anon-c",
            "ts": "2026-06-06T12:08:00.000Z",
            "source_hash": "jd-c",
            "question_id": "backend-rate-limiter-v0-2",
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
        },
    ]

    responses = [client.post("/funnel", json=event) for event in events]
    readout = client.get("/funnel/readout")

    assert [response.status_code for response in responses] == [200] * 10
    assert responses[-1].json()["stored_events"] == 10
    assert readout.status_code == 200
    payload = readout.json()
    assert payload["total_events"] == 10
    assert payload["unique_profiles"] == 3
    assert payload["counts"] == {
        "packet_created": 2,
        "brief_completed": 2,
        "email_capture": 0,
        "practice_start_click": 2,
        "first_paid_eval_started": 1,
        "verdict_completed": 1,
        "inspect_opened": 1,
        "retest_started": 1,
    }
    assert payload["unique_profile_counts"]["packet_created"] == 2
    assert payload["unique_profile_counts"]["brief_completed"] == 2
    assert payload["unique_profile_counts"]["practice_start_click"] == 2
    assert payload["conversion"][0] == {
        "from_event": "packet_created",
        "to_event": "brief_completed",
        "from_profiles": 2,
        "to_profiles": 2,
        "rate": 1.0,
    }
    assert payload["conversion"][1] == {
        "from_event": "brief_completed",
        "to_event": "practice_start_click",
        "from_profiles": 2,
        "to_profiles": 1,
        "rate": 0.5,
    }
    reopened = JsonlFunnelStore(tmp_path / "funnel_events.jsonl").readout()
    assert reopened.total_events == 10
    assert reopened.unique_profiles == 3


def test_funnel_endpoint_rejects_unapproved_pii_fields(tmp_path) -> None:
    store = JsonlFunnelStore(tmp_path / "funnel_events.jsonl")
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            funnel_store=store,
        )
    )

    response = client.post(
        "/funnel",
        json={
            "event_type": "email_capture",
            "anon_profile_id": "anon-a",
            "ts": "2026-06-06T12:00:00.000Z",
            "source_hash": "jd-a",
            "question_id": None,
            "corpus_bundle_version": "backend_depth_corpus_seed.v0.2",
            "email": "founder@example.com",
        },
    )

    assert response.status_code == 422


def test_gateway_can_serve_web_bundle_without_shadowing_funnel_routes(tmp_path) -> None:
    web_bundle = tmp_path / "web"
    web_bundle.mkdir()
    (web_bundle / "index.html").write_text(
        "<html><body>Caliber public flow</body></html>", encoding="utf-8"
    )
    (web_bundle / "caliber_runtime_config.json").write_text(
        '{"interview_judge":"gateway"}', encoding="utf-8"
    )
    client = TestClient(
        create_app(
            build_judge(FakeProviderAdapter(outputs=[])),
            funnel_store=JsonlFunnelStore(tmp_path / "funnel_events.jsonl"),
            web_bundle_dir=web_bundle,
        )
    )

    home = client.get("/")
    runtime_config = client.get("/caliber_runtime_config.json")
    readout = client.get("/funnel/readout")

    assert home.status_code == 200
    assert "Caliber public flow" in home.text
    assert runtime_config.json() == {"interview_judge": "gateway"}
    assert readout.status_code == 200
    assert readout.json()["total_events"] == 0


class _FakeBenchmarkProvider:
    def __init__(
        self,
        provider: str,
        model_id: str,
        *,
        error: Exception | None = None,
    ) -> None:
        self.provider = provider
        self.model_id = model_id
        self.input_usd_per_million_tokens = 1.0
        self.output_usd_per_million_tokens = 4.5
        self.error = error

    def complete(self, request: Any) -> tuple[str, TokenUsage | None]:
        if self.error is not None:
            raise self.error
        return (
            "Neutral feedback: clarify requirements and compare trade-offs.",
            TokenUsage(prompt_tokens=10, completion_tokens=5, total_tokens=15),
        )
