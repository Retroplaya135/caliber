from __future__ import annotations

import json
import runpy
import sys
from pathlib import Path
from types import ModuleType, SimpleNamespace

import pytest
from pydantic import BaseModel

from caliber_ai_gateway.cache import FileExactCache, MemoryExactCache
from caliber_ai_gateway.models import ATSReport, InterviewContentJudgment, ResumeBullet
from caliber_ai_gateway.provider import ProviderRegistry
from caliber_ai_gateway.schema_core import LOCAL_FALLBACK_ORIGIN, load_output_schemas
from caliber_ai_gateway.token_usage import FileTokenUsageSink, TokenUsageRecord
from tests.fakes import FakeProviderAdapter


def load_melos_shim() -> dict[str, object]:
    repo_root = Path(__file__).resolve().parents[1]
    return runpy.run_path(str(repo_root / "bin" / "melos"))


def load_gateway_guardrails() -> dict[str, object]:
    repo_root = Path(__file__).resolve().parents[1]
    return runpy.run_path(str(repo_root / "tool" / "gateway_guardrails.py"))


def test_file_exact_cache_round_trips_atomically(tmp_path) -> None:
    cache = FileExactCache(tmp_path)
    request_hash = "a" * 64

    assert cache.get(request_hash) is None
    cache.set(request_hash, '{"ok":true}')

    assert cache.get(request_hash) == '{"ok":true}'
    assert not list(tmp_path.glob("*.tmp"))


@pytest.mark.parametrize(
    "unsafe_hash",
    [
        "../not-a-hash",
        "abc123",
        "A" * 64,
        "g" * 64,
    ],
)
def test_file_exact_cache_rejects_unsafe_hashes(tmp_path, unsafe_hash: str) -> None:
    cache = FileExactCache(tmp_path)

    with pytest.raises(ValueError):
        cache.get(unsafe_hash)
    with pytest.raises(ValueError):
        cache.set(unsafe_hash, '{"ok":true}')


@pytest.mark.parametrize(
    "unsafe_hash",
    [
        "../not-a-hash",
        "abc123",
        "A" * 64,
        "g" * 64,
    ],
)
def test_memory_exact_cache_rejects_unsafe_hashes(unsafe_hash: str) -> None:
    cache = MemoryExactCache()

    with pytest.raises(ValueError):
        cache.get(unsafe_hash)
    with pytest.raises(ValueError):
        cache.set(unsafe_hash, '{"ok":true}')


def test_file_token_usage_sink_writes_jsonl_and_summary(tmp_path) -> None:
    sink = FileTokenUsageSink(
        tmp_path / "token_usage.jsonl",
        tmp_path / "token_usage_summary.json",
    )
    sink.record(
        TokenUsageRecord(
            audit_ref="audit:abc",
            request_hash="a" * 64,
            route_hash="b" * 64,
            feature="interview_content",
            schema_name="interview_content_judgment",
            provider_name="openai",
            model_id="gpt-5.4-mini",
            cache_hit=False,
            attempts=1,
            status="provider_validated",
            estimated_prompt_tokens=100,
            estimated_completion_tokens=20,
            estimated_total_tokens=120,
            prompt_tokens=90,
            completion_tokens=18,
            total_tokens=108,
            input_characters=400,
            output_characters=80,
            cache_saved_estimated_tokens=0,
        )
    )

    rows = (tmp_path / "token_usage.jsonl").read_text(encoding="utf-8").splitlines()
    summary = json.loads((tmp_path / "token_usage_summary.json").read_text(encoding="utf-8"))

    assert len(rows) == 1
    assert json.loads(rows[0])["total_tokens"] == 108
    assert summary["records"] == 1
    assert summary["totals"]["total_tokens"] == 108
    assert summary["by_model"]["gpt-5.4-mini"]["provider_calls"] == 1
    assert summary["by_feature"]["interview_content"]["estimated_total_tokens"] == 120


def test_provider_registry_lists_and_reports_missing_adapters() -> None:
    registry = ProviderRegistry()
    registry.register(FakeProviderAdapter(outputs=[]))

    assert tuple(registry.names()) == ("fake",)
    with pytest.raises(KeyError, match="available: fake"):
        registry.get("missing")


def test_schema_core_fallback_is_strict_local_model_until_fork_02_lands() -> None:
    schemas = load_output_schemas()

    assert schemas["interview_content"].model is InterviewContentJudgment
    assert schemas["resume_bullet"].model is ResumeBullet
    assert schemas["ats_report"].model is ATSReport
    assert schemas["interview_content"].origin == f"{LOCAL_FALLBACK_ORIGIN}:interview_content_judgment"


def test_schema_core_import_seam_prefers_published_fork_02_schema(monkeypatch) -> None:
    module = ModuleType("caliber_shared.ai_output_schemas")
    module.InterviewContentJudgment = InterviewContentJudgment
    module.ResumeBullet = ResumeBullet
    module.ATSReport = ATSReport
    monkeypatch.setitem(sys.modules, "caliber_shared.ai_output_schemas", module)

    schemas = load_output_schemas()

    assert schemas["interview_content"].model is InterviewContentJudgment
    assert schemas["resume_bullet"].model is ResumeBullet
    assert schemas["ats_report"].model is ATSReport
    assert schemas["ats_report"].origin == "caliber_shared.ai_output_schemas:ats_report"


def test_schema_core_import_seam_supports_configured_bridge_module(monkeypatch) -> None:
    module = ModuleType("custom_schema_bridge")
    module.InterviewContentJudgment = InterviewContentJudgment
    module.ResumeBullet = ResumeBullet
    module.ATSReport = ATSReport
    monkeypatch.setenv("CALIBER_SCHEMA_CORE_MODULE", "custom_schema_bridge")
    monkeypatch.setitem(sys.modules, "custom_schema_bridge", module)

    schemas = load_output_schemas()

    assert schemas["interview_content"].model is InterviewContentJudgment
    assert schemas["resume_bullet"].origin == "custom_schema_bridge:resume_bullet"


def test_schema_core_configured_bridge_fails_closed_when_invalid(monkeypatch) -> None:
    monkeypatch.setenv("CALIBER_SCHEMA_CORE_MODULE", "missing_schema_bridge")

    with pytest.raises(RuntimeError, match="configured Schema Core module"):
        load_output_schemas()


def test_schema_core_configured_bridge_requires_pydantic_model(monkeypatch) -> None:
    module = ModuleType("invalid_schema_bridge")
    module.InterviewContentJudgment = object
    module.ResumeBullet = ResumeBullet
    module.ATSReport = ATSReport
    monkeypatch.setenv("CALIBER_SCHEMA_CORE_MODULE", "invalid_schema_bridge")
    monkeypatch.setitem(sys.modules, "invalid_schema_bridge", module)

    with pytest.raises(RuntimeError, match="must export a Pydantic InterviewContentJudgment"):
        load_output_schemas()


def test_schema_core_bridge_rejects_schema_without_required_output_fields(monkeypatch) -> None:
    class IncompleteResumeBullet(BaseModel):
        schema_version: str
        bullet_id: str

    module = ModuleType("incomplete_schema_bridge")
    module.InterviewContentJudgment = InterviewContentJudgment
    module.ResumeBullet = IncompleteResumeBullet
    module.ATSReport = ATSReport
    monkeypatch.setenv("CALIBER_SCHEMA_CORE_MODULE", "incomplete_schema_bridge")
    monkeypatch.setitem(sys.modules, "incomplete_schema_bridge", module)

    with pytest.raises(RuntimeError, match="missing required strict AI-output fields"):
        load_output_schemas()


def test_schema_core_bridge_rejects_schema_with_gateway_envelope_fields(monkeypatch) -> None:
    class EnvelopeLeakingResumeBullet(ResumeBullet):
        request_hash: str

    module = ModuleType("envelope_leaking_schema_bridge")
    module.InterviewContentJudgment = InterviewContentJudgment
    module.ResumeBullet = EnvelopeLeakingResumeBullet
    module.ATSReport = ATSReport
    monkeypatch.setenv("CALIBER_SCHEMA_CORE_MODULE", "envelope_leaking_schema_bridge")
    monkeypatch.setitem(sys.modules, "envelope_leaking_schema_bridge", module)

    with pytest.raises(RuntimeError, match="hash/audit, not output"):
        load_output_schemas()


def test_melos_shim_honors_explicit_python_override(monkeypatch: pytest.MonkeyPatch) -> None:
    melos = load_melos_shim()
    monkeypatch.setenv("PYTHON", "/custom/python")

    assert melos["resolve_python"]() == "/custom/python"


def test_melos_shim_falls_back_to_dependency_capable_python(monkeypatch: pytest.MonkeyPatch) -> None:
    melos = load_melos_shim()
    checked: list[str] = []

    def fake_run(command: list[str], **_kwargs: object) -> SimpleNamespace:
        checked.append(command[0])
        return SimpleNamespace(returncode=0 if command[0] == "/opt/anaconda3/bin/python" else 1)

    monkeypatch.delenv("PYTHON", raising=False)
    monkeypatch.setattr(melos["subprocess"], "run", fake_run)
    monkeypatch.setattr(melos["shutil"], "which", lambda name: "/usr/bin/python3" if name == "python3" else "")

    assert melos["resolve_python"]() == "/opt/anaconda3/bin/python"
    assert checked[0] == sys.executable


def test_scope_guard_enforces_committed_history_on_gateway_fork() -> None:
    guardrails = load_gateway_guardrails()

    def fake_git_changed_paths(args: list[str]) -> set[str]:
        if args == ["diff", "--name-only", "main...HEAD"]:
            return {"04_build/integrations/speech_stack/lib/speech_stack.dart"}
        return set()

    globals_map = guardrails["check_scope"].__globals__
    globals_map["current_branch"] = lambda: "fork/03-ai-gateway"
    globals_map["git_changed_paths"] = fake_git_changed_paths

    with pytest.raises(SystemExit, match="CALIBER-SCOPE-001"):
        guardrails["check_scope"]()


def test_scope_guard_allows_merged_history_on_integration_branch() -> None:
    guardrails = load_gateway_guardrails()
    calls: list[list[str]] = []

    def fake_git_changed_paths(args: list[str]) -> set[str]:
        calls.append(args)
        return set()

    globals_map = guardrails["check_scope"].__globals__
    globals_map["current_branch"] = lambda: "integration"
    globals_map["git_changed_paths"] = fake_git_changed_paths

    guardrails["check_scope"]()

    assert ["diff", "--name-only", "main...HEAD"] not in calls


def test_scope_guard_still_rejects_uncommitted_outside_paths_on_integration() -> None:
    guardrails = load_gateway_guardrails()

    def fake_git_changed_paths(args: list[str]) -> set[str]:
        if args == ["diff", "--name-only"]:
            return {"04_build/integrations/speech_stack/lib/speech_stack.dart"}
        return set()

    globals_map = guardrails["check_scope"].__globals__
    globals_map["current_branch"] = lambda: "integration"
    globals_map["git_changed_paths"] = fake_git_changed_paths

    with pytest.raises(SystemExit, match="CALIBER-SCOPE-001"):
        guardrails["check_scope"]()
