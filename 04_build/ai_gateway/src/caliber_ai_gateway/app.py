from __future__ import annotations

import os
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from caliber_ai_gateway.audit import FileAuditSink
from caliber_ai_gateway.benchmark import (
    BenchmarkFeedbackRequest,
    BenchmarkFeedbackResponse,
    BenchmarkFeedbackService,
    build_default_benchmark_service,
)
from caliber_ai_gateway.budget import TokenBudgetExceeded
from caliber_ai_gateway.cache import FileExactCache
from caliber_ai_gateway.config import load_gateway_config
from caliber_ai_gateway.funnel import FunnelStore, JsonlFunnelStore
from caliber_ai_gateway.models import (
    FeatureName,
    FunnelEventRequest,
    FunnelIngestResponse,
    FunnelReadoutResponse,
    JudgeRequest,
    JudgeResponse,
)
from caliber_ai_gateway.pipeline import GatewayStructuredJudge, SchemaValidationRetry
from caliber_ai_gateway.provider import OpenAIProviderAdapter, ProviderRegistry, ProviderTransportError
from caliber_ai_gateway.token_usage import FileTokenUsageSink


def create_app(
    judge: GatewayStructuredJudge | None = None,
    benchmark_service: BenchmarkFeedbackService | None = None,
    funnel_store: FunnelStore | None = None,
    web_bundle_dir: Path | None = None,
) -> FastAPI:
    app = FastAPI(title="caliber AI Gateway", version="0.1.0")
    _configure_local_cors(app)
    active_judge = judge or build_default_judge()
    active_benchmark_service = benchmark_service or build_default_benchmark_service(
        _judge_model_id(active_judge)
    )
    active_funnel_store = funnel_store or _default_funnel_store()

    def run_judge(request: JudgeRequest, expected_feature: FeatureName | None = None) -> JudgeResponse:
        if expected_feature is not None and request.feature != expected_feature:
            raise HTTPException(status_code=422, detail="feature_path_mismatch")
        try:
            return active_judge.judge(request)
        except TokenBudgetExceeded as exc:
            raise HTTPException(status_code=413, detail=str(exc)) from exc
        except SchemaValidationRetry as exc:
            raise HTTPException(
                status_code=502,
                detail={
                    "error": "provider_schema_validation_failed",
                    "failure_category": exc.failure_category,
                    "debug_artifact": exc.debug_artifact,
                },
            ) from exc

    @app.post("/v1/judge", response_model=JudgeResponse)
    def judge_any(request: JudgeRequest) -> JudgeResponse:
        return run_judge(request)

    @app.post("/v1/judge/interview", response_model=JudgeResponse)
    def judge_interview(request: JudgeRequest) -> JudgeResponse:
        return run_judge(request, "interview_content")

    @app.post("/v1/judge/resume-bullet", response_model=JudgeResponse)
    def judge_resume_bullet(request: JudgeRequest) -> JudgeResponse:
        return run_judge(request, "resume_bullet")

    @app.post("/v1/judge/ats", response_model=JudgeResponse)
    def judge_ats(request: JudgeRequest) -> JudgeResponse:
        return run_judge(request, "ats_report")

    @app.post("/v1/benchmark/generic-feedback", response_model=BenchmarkFeedbackResponse)
    def benchmark_generic_feedback(request: BenchmarkFeedbackRequest) -> BenchmarkFeedbackResponse:
        try:
            return active_benchmark_service.complete(request)
        except ProviderTransportError as exc:
            raise HTTPException(status_code=502, detail=exc.safe_status) from exc

    @app.post("/funnel", response_model=FunnelIngestResponse)
    def ingest_funnel_event(request: FunnelEventRequest) -> FunnelIngestResponse:
        return FunnelIngestResponse(
            accepted=True,
            stored_events=active_funnel_store.append(request),
        )

    @app.get("/funnel/readout", response_model=FunnelReadoutResponse)
    def funnel_readout() -> FunnelReadoutResponse:
        return active_funnel_store.readout()

    active_web_bundle = web_bundle_dir or _configured_web_bundle_dir()
    if active_web_bundle is not None:
        app.mount(
            "/",
            StaticFiles(directory=active_web_bundle, html=True),
            name="caliber-web",
        )

    return app


def _configure_local_cors(app: FastAPI) -> None:
    if os.environ.get("CALIBER_AI_GATEWAY_DISABLE_LOCAL_CORS") == "1":
        return
    configured_origins = [
        origin.strip()
        for origin in os.environ.get("CALIBER_AI_GATEWAY_CORS_ORIGINS", "").split(",")
        if origin.strip()
    ]
    app.add_middleware(
        CORSMiddleware,
        allow_origins=configured_origins,
        allow_origin_regex=r"^https?://(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$",
        allow_credentials=False,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["accept", "authorization", "content-type"],
    )


def build_default_judge(repo_root: Path | None = None) -> GatewayStructuredJudge:
    repo_root = repo_root or Path(__file__).resolve().parents[4]
    config = load_gateway_config(repo_root / "config" / "ai" / "provider_adapter.yaml")
    configured_cache_root = os.environ.get("CALIBER_AI_GATEWAY_CACHE_ROOT", "").strip()
    gateway_cache_root = Path(configured_cache_root) if configured_cache_root else repo_root / ".cache" / "ai_gateway"
    registry = ProviderRegistry()
    registry.register(OpenAIProviderAdapter(model_id=config.provider_adapter.default_model))
    return GatewayStructuredJudge(
        registry=registry,
        provider_name="openai",
        cache=FileExactCache(gateway_cache_root / "responses"),
        audit_sink=FileAuditSink(gateway_cache_root / "audit.jsonl"),
        token_usage_sink=FileTokenUsageSink(
            gateway_cache_root / "token_usage.jsonl",
            gateway_cache_root / "token_usage_summary.json",
        ),
    )


def _default_funnel_store(repo_root: Path | None = None) -> JsonlFunnelStore:
    repo_root = repo_root or Path(__file__).resolve().parents[4]
    configured_path = os.environ.get("CALIBER_FUNNEL_STORE_PATH", "").strip()
    if configured_path:
        return JsonlFunnelStore(Path(configured_path))
    return JsonlFunnelStore(repo_root / ".cache" / "ai_gateway" / "funnel_events.jsonl")


def _configured_web_bundle_dir() -> Path | None:
    configured_path = os.environ.get("CALIBER_WEB_BUNDLE_DIR", "").strip()
    return Path(configured_path) if configured_path else None


def _judge_model_id(judge: object) -> str:
    try:
        return judge.registry.get(judge.provider_name).model_id  # type: ignore[attr-defined]
    except AttributeError:
        return "gpt-5.4-mini"


app = create_app()
