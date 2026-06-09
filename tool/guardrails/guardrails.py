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


def nesting_depth(text: str) -> int:
    depth = maximum = 0
    for char in text:
        if char == "{":
            depth += 1
            maximum = max(maximum, depth)
        elif char == "}":
            depth = max(0, depth - 1)
    return maximum


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


def executable_lines(path: Path) -> set[int]:
    tree = ast.parse(read_text(path))
    return {getattr(node, "lineno") for node in ast.walk(tree) if hasattr(node, "lineno")}


