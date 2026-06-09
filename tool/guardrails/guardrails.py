#!/usr/bin/env python3
"""Deterministic Guardrail CI gates for the caliber pre-product scaffold."""

from __future__ import annotations

import argparse
import ast
import difflib
import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import trace
import unittest
from dataclasses import dataclass
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", ".dart_tool", ".mypy_cache", ".pytest_cache", ".worktrees", "build", "node_modules", "__pycache__"}
SCAN_SUFFIXES = {".dart", ".py", ".md", ".yaml", ".yml", ".json", ".txt"}
SECRET_SCAN_FIXTURES = {"tool/guardrails/seeded_violations.py"}


@dataclass(frozen=True)
class Finding:
    code: str
    path: Path
    detail: str

    def render(self, root: Path) -> str:
        try:
            rel = self.path.relative_to(root)
        except ValueError:
            rel = self.path
        return f"{self.code} | {rel}: {self.detail}"


class GateFailure(Exception):
    def __init__(self, findings: list[Finding]):
        self.findings = findings
        super().__init__("\n".join(f.code for f in findings))


def iter_files(root: Path, suffixes: set[str] = SCAN_SUFFIXES) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.is_file() and path.suffix in suffixes:
            files.append(path)
    return sorted(files)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def matches(path: Path, root: Path, patterns: list[str]) -> bool:
    rel = path.relative_to(root).as_posix()
    return any(fnmatch.fnmatch(rel, pattern) for pattern in patterns)


def require_no_findings(root: Path, findings: list[Finding], pass_message: str) -> None:
    if findings:
        for finding in findings:
            print(finding.render(root), file=sys.stderr)
        raise GateFailure(findings)
    print(pass_message)


def check_secrets(root: Path) -> None:
    patterns_path = root / "config/guardrails/secret_patterns.txt"
    lines = [line.strip() for line in read_text(patterns_path).splitlines() if line.strip()]
    message = lines[1] if lines[0].startswith("# version:") else lines[0]
    regexes = [re.compile(line) for line in lines if not line.startswith("#") and not line.startswith("CALIBER-")]
    findings: list[Finding] = []
    for path in iter_files(root):
        rel = path.relative_to(root).as_posix()
        if rel == "config/guardrails/secret_patterns.txt" or rel in SECRET_SCAN_FIXTURES:
            continue
        text = read_text(path)
        if any(regex.search(text) for regex in regexes):
            findings.append(Finding(message, path, "remove the secret-like value or move it to a vault-backed runtime secret"))
    require_no_findings(root, findings, "CALIBER-SECRET-CLEAN: no secret-like values found")


def check_version_tags(root: Path) -> None:
    code = "CALIBER-VERSION-001 version-tag: artifact missing version tag"
    targets = list((root / "config/guardrails").glob("*")) if (root / "config/guardrails").exists() else []
    targets += list((root / "goldens").glob("**/expected/*"))
    findings: list[Finding] = []
    for path in sorted(target for target in targets if target.is_file()):
        text = read_text(path)
        if '"version"' not in text and "# version:" not in text and "Stamp:" not in text:
            findings.append(Finding(code, path, "add a machine-readable version tag before the artifact can merge"))
    require_no_findings(root, findings, "CALIBER-VERSION-CLEAN: version tags present on guardrail artifacts")


def check_domain_purity(root: Path) -> list[Finding]:
    code = "CALIBER-LINT-001 domain-purity: domain code must not import Flutter or data-layer packages"
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        if matches(path, root, ["packages/**/domain/**/*.dart"]):
            text = read_text(path)
            if "package:flutter/" in text or "/data/" in text or "package:caliber_data/" in text:
                findings.append(Finding(code, path, "move Flutter/data dependencies behind a domain interface"))
    return findings


def check_repository_boundary(root: Path) -> list[Finding]:
    code = "CALIBER-LINT-002 repository-boundary: UI may depend on repository interfaces only, never concrete repositories/services"
    patterns = ["apps/**/*.dart", "packages/**/presentation/**/*.dart", "packages/**/ui/**/*.dart"]
    tokens = ["ConcreteRepository", "HttpService(", "SqliteRepository(", "implements Repository"]
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        if matches(path, root, patterns) and any(token in read_text(path) for token in tokens):
            findings.append(Finding(code, path, "inject an interface instead of reaching into concrete data/service classes"))
    return findings


def check_raw_style(root: Path) -> list[Finding]:
    code = "CALIBER-LINT-003 raw-style-ban: use design tokens instead of raw Color/size literals"
    patterns = ["apps/**/*.dart", "packages/**/presentation/**/*.dart", "packages/design_system/lib/**/*.dart"]
    regexes = [re.compile(r"Color\(0x[0-9A-Fa-f]{8}\)"), re.compile(r"SizedBox\((?:width|height):\s*[0-9]"), re.compile(r"EdgeInsets\.all\([0-9]")]
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        if matches(path, root, patterns) and any(regex.search(read_text(path)) for regex in regexes):
            findings.append(Finding(code, path, "replace literal style values with glass/design-system tokens"))
    return findings


def check_disposal(root: Path) -> list[Finding]:
    code = "CALIBER-LINT-004 disposal: classes creating controllers/subscriptions must implement dispose"
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        text = read_text(path)
        owns_controller = any(token in text for token in ["TextEditingController(", "AnimationController("])
        owns_stream = "StreamController(" in text
        owns_subscription = ".listen(" in text
        controller_is_released = "dispose(" in text
        stream_is_released = controller_is_released or ".close(" in text
        subscription_is_released = controller_is_released or ".cancel" in text or "addTearDown(" in text
        if (
            (owns_controller and not controller_is_released)
            or (owns_stream and not stream_is_released)
            or (owns_subscription and not subscription_is_released)
        ):
            findings.append(Finding(code, path, "add deterministic dispose/cancel handling for allocated resources"))
    return findings


def check_banned_imports(root: Path) -> list[Finding]:
    code = "CALIBER-LINT-005 banned-import: package boundary violation"
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        text = read_text(path)
        if matches(path, root, ["packages/**/domain/**/*.dart"]) and "package:flutter/" in text:
            findings.append(Finding(code, path, "domain cannot import Flutter"))
        if matches(path, root, ["packages/**/presentation/**/*.dart"]) and "package:caliber_app/gateway" in text:
            findings.append(Finding(code, path, "presentation cannot import gateway internals"))
    return findings


def check_lints(root: Path) -> None:
    findings = check_domain_purity(root)
    findings += check_repository_boundary(root)
    findings += check_raw_style(root)
    findings += check_disposal(root)
    findings += check_banned_imports(root)
    require_no_findings(root, findings, "CALIBER-LINT-CLEAN: boundary, style, and disposal lints passed")


def nesting_depth(text: str) -> int:
    depth = maximum = 0
    for char in text:
        if char == "{":
            depth += 1
            maximum = max(maximum, depth)
        elif char == "}":
            depth = max(0, depth - 1)
    return maximum


def check_complexity(root: Path) -> None:
    code = "CALIBER-COMPLEXITY-001 complexity-budget: file exceeds configured budget"
    findings: list[Finding] = []
    roots = [root / name for name in ["apps", "packages", "gateway", "workers"]]
    for base in roots:
        if not base.exists():
            continue
        for path in iter_files(base, {".dart", ".py"}):
            text = read_text(path)
            lines = [line for line in text.splitlines() if line.strip() and not line.strip().startswith("//")]
            imports = sum(1 for line in text.splitlines() if line.strip().startswith("import "))
            if len(lines) > 400 or imports > 12 or nesting_depth(text) > 4:
                findings.append(Finding(code, path, "split the file or lower imports/nesting before merge"))
    require_no_findings(root, findings, "CALIBER-COMPLEXITY-CLEAN: package files are within budget")


def check_codegen(root: Path) -> None:
    code = "CALIBER-CODEGEN-001 build_runner: generated part missing or stale"
    part_re = re.compile(r"part\s+['\"]([^'\"]+\.(?:g|freezed)\.dart)['\"]\s*;")
    findings: list[Finding] = []
    for path in iter_files(root, {".dart"}):
        text = read_text(path)
        for match in part_re.finditer(text):
            generated = path.parent / match.group(1)
            if not generated.exists() or "CALIBER_STALE_CODEGEN" in read_text(generated):
                findings.append(Finding(code, path, f"run build_runner for `{match.group(1)}`"))
    require_no_findings(root, findings, "CALIBER-CODEGEN-CLEAN: build_runner generated parts are present")


def normalized_json(path: Path) -> str:
    return json.dumps(json.loads(read_text(path)), indent=2, sort_keys=True) + "\n"


def check_golden_suite(root: Path, suite: str, approve: bool) -> list[Finding]:
    code = f"CALIBER-GOLDEN-001 {suite} golden diff"
    expected_dir = root / f"goldens/{suite}/expected"
    actual_dir = root / f"goldens/{suite}/actual"
    findings: list[Finding] = []
    for actual in sorted(actual_dir.glob("*")):
        expected = expected_dir / actual.name
        if not expected.exists() or normalized_json(expected) != normalized_json(actual):
            if approve:
                expected.write_text(normalized_json(actual), encoding="utf-8")
                print(f"CALIBER-GOLDEN-APPROVED: {suite}/{actual.name}")
            else:
                diff = "\n".join(difflib.unified_diff(
                    normalized_json(expected).splitlines() if expected.exists() else [],
                    normalized_json(actual).splitlines(),
                    fromfile=f"expected/{actual.name}",
                    tofile=f"actual/{actual.name}",
                    lineterm="",
                ))
                findings.append(Finding(code, actual, f"{actual.name} differs; run CALIBER_APPROVE_GOLDENS=1 melos run golden to approve intentional diff\n{diff}"))
    return findings


def check_goldens(root: Path, approve: bool = False) -> None:
    findings = check_golden_suite(root, "gateway", approve)
    findings += check_golden_suite(root, "design_system", approve)
    require_no_findings(root, findings, "CALIBER-GOLDEN-CLEAN: gateway and design-system goldens match")


def check_handoff(root: Path) -> None:
    code = "CALIBER-HANDOFF-001 handoff-shape: missing required CALIBER HANDOFF STATUS BLOCK field"
    required = [line for line in read_text(root / "config/guardrails/handoff_required_fields.txt").splitlines() if line]
    files = sorted((root / "handoff").glob("**/*.md")) if (root / "handoff").exists() else []
    findings: list[Finding] = []
    if not files:
        findings.append(Finding(code, root / "handoff", "add at least one handoff block fixture"))
    for path in files:
        text = read_text(path)
        missing = [field for field in required if field not in text]
        if "CALIBER HANDOFF STATUS BLOCK" not in text or missing:
            findings.append(Finding(code, path, "missing " + ", ".join(missing[:3])))
    require_no_findings(root, findings, "CALIBER-HANDOFF-CLEAN: handoff block shape is complete")


def check_analyze(root: Path) -> None:
    check_secrets(root)
    check_version_tags(root)
    check_lints(root)
    check_complexity(root)
    check_handoff(root)
    print("CALIBER-ANALYZE-CLEAN: all static guardrails passed")


def run_tests_with_coverage(root: Path) -> None:
    test_dir = root / "tool/guardrails"
    loader = unittest.defaultTestLoader
    suite = loader.discover(str(test_dir), pattern="test_*.py")
    runner = unittest.TextTestRunner(verbosity=2)
    tracer = trace.Trace(count=True, trace=False, ignoredirs=[sys.base_prefix, sys.base_exec_prefix])
    result = tracer.runfunc(runner.run, suite)
    if not result.wasSuccessful():
        raise SystemExit(1)
    counts = tracer.results().counts
    covered = {lineno for (filename, lineno), count in counts.items() if filename.endswith("guardrails.py") and count > 0}
    executable = executable_lines(root / "tool/guardrails/guardrails.py")
    percent = int((len(covered & executable) / max(1, len(executable))) * 100)
    if percent < 30:
        print(f"CALIBER-COVERAGE-001 new-code-coverage: guardrail coverage {percent}% below 30%", file=sys.stderr)
        raise SystemExit(1)
    print(f"CALIBER-TEST-CLEAN: guardrail unit tests passed; coverage {percent}% on tool/guardrails/guardrails.py")


def executable_lines(path: Path) -> set[int]:
    tree = ast.parse(read_text(path))
    return {getattr(node, "lineno") for node in ast.walk(tree) if hasattr(node, "lineno")}


def run_all(root: Path, approve: bool = False) -> None:
    check_analyze(root)
    check_codegen(root)
    check_goldens(root, approve)
    run_tests_with_coverage(root)
    print("CALIBER-GUARDRAILS-CLEAN: every Guardrail CI gate passed")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["all", "analyze", "test", "codegen", "secret", "version", "lint", "complexity", "golden", "handoff"])
    parser.add_argument("--root", default=os.environ.get("CALIBER_GUARDRAIL_ROOT", str(DEFAULT_ROOT)))
    parser.add_argument("--approve", action="store_true", default=os.environ.get("CALIBER_APPROVE_GOLDENS") == "1")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    try:
        {
            "all": lambda: run_all(root, args.approve),
            "analyze": lambda: check_analyze(root),
            "test": lambda: run_tests_with_coverage(root),
            "codegen": lambda: check_codegen(root),
            "secret": lambda: check_secrets(root),
            "version": lambda: check_version_tags(root),
            "lint": lambda: check_lints(root),
            "complexity": lambda: check_complexity(root),
            "golden": lambda: check_goldens(root, args.approve),
            "handoff": lambda: check_handoff(root),
        }[args.command]()
    except GateFailure:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
