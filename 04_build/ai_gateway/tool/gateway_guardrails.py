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


def check_codegen() -> None:
    print("CALIBER-CODEGEN-CLEAN: gateway Python package has no generated code requirement")


