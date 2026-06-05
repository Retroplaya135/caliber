#!/usr/bin/env python3
from __future__ import annotations

import argparse
import ast
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
TESTS = ROOT / "tests"
SECRET_PATTERNS = [
    re.compile(r"sk-[A-Za-z0-9]{20,}"),
    re.compile(r"(?i)\b(api[_-]?key|password|secret|token)\s*=\s*['\"][^'\"]+['\"]"),
]
REQUIRED_PIPELINE_TERMS = [
    "canonicalize",
    "policy",
    "redact",
    "hash",
    "cache",
    "ProviderAdapter",
    "validate",
    "retry",
    "audit",
    "canonical JSON",
]
REQUIRED_PROFILE_TERMS = [
    "CALIBER-PROFILE-CLEAN",
    "gateway-profile-v1",
    "provider_calls",
    "cache_hit_p95_ms",
    "gpt-5.4-mini",
]
REQUIRED_HANDOFF_TERMS = [
    "CALIBER HANDOFF STATUS BLOCK",
    "Stamp:",
    "Lane / Worker:",
    "Phase / Stage / Step / Iteration:",
    "COMPLETED THIS OUTPUT",
    "FILES CREATED / MODIFIED",
    "BUILD / DEPENDENCY STATUS",
    "VALIDATION STATUS",
    "BRANCH STATUS",
    "MERGE STATUS",
    "BRANCH-HANDOFF FINDINGS",
    "DECISIONS / DEVIATIONS",
    "NEXT STEPS",
    "BLOCKERS",
    "melos analyze:",
    "melos test:",
    "npm status:",
    "guardrail CI:",
    "branch:",
    "merge decision:",
]
ALLOWED_SCOPE_PREFIX = "04_build/ai_gateway/"
FORK_BRANCH = "fork/03-ai-gateway"


def run(command: list[str], env: dict[str, str] | None = None) -> None:
    subprocess.run(command, cwd=ROOT, env=env, check=True)


def iter_text_files() -> list[Path]:
    suffixes = {".py", ".md", ".toml", ".yaml", ".yml", ".json", ".txt"}
    ignored = {".pytest_cache", "__pycache__"}
    return sorted(
        path
        for path in ROOT.rglob("*")
        if path.is_file()
        and path.suffix in suffixes
        and not any(part in ignored for part in path.parts)
        and path.name != ".coverage"
    )


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def check_secrets() -> None:
    findings: list[str] = []
    for path in iter_text_files():
        text = read(path)
        if any(pattern.search(text) for pattern in SECRET_PATTERNS):
            findings.append(f"CALIBER-SECRET-001 | {path.relative_to(ROOT)}: secret-like value detected")
    if findings:
        raise SystemExit("\n".join(findings))
    print("CALIBER-SECRET-CLEAN: gateway contains no secret-like values")


def check_complexity() -> None:
    findings: list[str] = []
    for path in sorted(SRC.rglob("*.py")):
        text = read(path)
        line_count = sum(1 for line in text.splitlines() if line.strip())
        tree = ast.parse(text)
        functions = [node for node in ast.walk(tree) if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))]
        max_function_lines = max(
            (getattr(node, "end_lineno", node.lineno) - node.lineno + 1 for node in functions),
            default=0,
        )
        if line_count > 260:
            findings.append(f"CALIBER-COMPLEXITY-001 | {path.relative_to(ROOT)}: file has {line_count} nonblank lines")
        if max_function_lines > 90:
            findings.append(
                f"CALIBER-COMPLEXITY-002 | {path.relative_to(ROOT)}: function exceeds 90 lines"
            )
    if findings:
        raise SystemExit("\n".join(findings))
    print("CALIBER-COMPLEXITY-CLEAN: gateway package is within local complexity budget")


def check_pipeline_log() -> None:
    checkpoint = ROOT / "docs/checkpoint_log.md"
    text = read(checkpoint)
    missing = [term for term in REQUIRED_PIPELINE_TERMS if term not in text]
    if missing:
        raise SystemExit(f"CALIBER-CHECKPOINT-001: checkpoint log missing {', '.join(missing)}")
    print("CALIBER-CHECKPOINT-CLEAN: checkpoint log covers every gateway pipeline stage")


def check_profile_artifact() -> None:
    profile = ROOT / "docs/profiling_artifact.md"
    text = read(profile)
    missing = [term for term in REQUIRED_PROFILE_TERMS if term not in text]
    if missing:
        raise SystemExit(f"CALIBER-PROFILE-001: profiling artifact missing {', '.join(missing)}")
    print("CALIBER-PROFILE-CLEAN: profiling artifact records gateway cache-hit proof")


def check_handoff_artifact() -> None:
    handoff = ROOT / "docs/handoff_status.md"
    text = read(handoff)
    missing = [term for term in REQUIRED_HANDOFF_TERMS if term not in text]
    if missing:
        raise SystemExit(f"CALIBER-HANDOFF-001: handoff artifact missing {', '.join(missing)}")
    print("CALIBER-HANDOFF-CLEAN: handoff artifact follows canonical Part B shape")


def check_product_model_pin() -> None:
    provider = ROOT.parents[1] / "config/ai/provider_adapter.yaml"
    text = read(provider)
    if 'default_model: "gpt-5.4-mini"' not in text:
        raise SystemExit("CALIBER-PROVIDER-001: product ProviderAdapter model must stay gpt-5.4-mini")
    print("CALIBER-PROVIDER-CLEAN: product model pin remains gpt-5.4-mini")


def git_changed_paths(args: list[str]) -> set[str]:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT.parents[1],
        check=True,
        text=True,
        capture_output=True,
    )
    return {line.strip() for line in result.stdout.splitlines() if line.strip()}


def current_branch() -> str:
    result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        cwd=ROOT.parents[1],
        check=False,
        text=True,
        capture_output=True,
    )
    return result.stdout.strip() if result.returncode == 0 else ""


def committed_scope_paths(base: str) -> set[str]:
    if "CALIBER_SCOPE_BASE" in os.environ or current_branch() == FORK_BRANCH:
        return git_changed_paths(["diff", "--name-only", f"{base}...HEAD"])
    return set()


def check_scope() -> None:
    base = os.environ.get("CALIBER_SCOPE_BASE", "main")
    changed: set[str] = set()
    changed.update(committed_scope_paths(base))
    changed.update(git_changed_paths(["diff", "--name-only"]))
    changed.update(git_changed_paths(["diff", "--name-only", "--cached"]))
    outside = sorted(path for path in changed if not path.startswith(ALLOWED_SCOPE_PREFIX))
    if outside:
        raise SystemExit(
            "CALIBER-SCOPE-001: Fork 03 may edit only "
            f"{ALLOWED_SCOPE_PREFIX}; outside paths: {', '.join(outside)}"
        )
    print("CALIBER-SCOPE-CLEAN: branch changes stay inside 04_build/ai_gateway")


def check_golden() -> None:
    golden_files = [
        ROOT / "tests/golden/interview_content_judgment.json",
        ROOT / "tests/golden/resume_bullet.json",
        ROOT / "tests/golden/ats_report.json",
    ]
    required = {
        "schema_version",
    }
    forbidden = {
        "corpus_bundle_version",
        "routing_policy_version",
        "route_hash",
        "request_hash",
        "audit_ref",
    }
    for golden in golden_files:
        payload = json.loads(read(golden))
        missing = sorted(required.difference(payload))
        if missing:
            raise SystemExit(f"CALIBER-GOLDEN-001: {golden.name} missing {', '.join(missing)}")
        leaked = sorted(forbidden.intersection(payload))
        if leaked:
            raise SystemExit(f"CALIBER-GOLDEN-002: {golden.name} leaks gateway envelope fields: {', '.join(leaked)}")
        if payload.get("model_id", "gpt-5.4-mini") != "gpt-5.4-mini":
            raise SystemExit(f"CALIBER-GOLDEN-002: {golden.name} must use product model gpt-5.4-mini")
    print("CALIBER-GOLDEN-CLEAN: gateway golden outputs match strict Schema Core surfaces")


def check_codegen() -> None:
    print("CALIBER-CODEGEN-CLEAN: gateway Python package has no generated code requirement")


def check_analyze() -> None:
    check_secrets()
    check_complexity()
    check_scope()
    check_pipeline_log()
    check_profile_artifact()
    check_handoff_artifact()
    check_product_model_pin()
    check_golden()
    check_codegen()
    print("CALIBER-ANALYZE-CLEAN: gateway static guardrails passed")


def check_tests() -> None:
    with tempfile.TemporaryDirectory(prefix="caliber-gateway-coverage-") as tmp_dir:
        env = os.environ.copy()
        env["COVERAGE_FILE"] = str(Path(tmp_dir) / ".coverage")
        run([sys.executable, "-m", "coverage", "erase"], env=env)
        run([sys.executable, "-m", "coverage", "run", "-m", "pytest"], env=env)
        run([sys.executable, "-m", "coverage", "report"], env=env)
    print("CALIBER-TEST-CLEAN: gateway tests and coverage passed")


def check_all() -> None:
    check_analyze()
    check_tests()
    print("CALIBER-GATEWAY-GUARDRAILS-CLEAN: every Gateway Core guardrail passed")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["all", "analyze", "test", "golden", "codegen"])
    args = parser.parse_args(argv)
    {
        "all": check_all,
        "analyze": check_analyze,
        "test": check_tests,
        "golden": check_golden,
        "codegen": check_codegen,
    }[args.command]()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
