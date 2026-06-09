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


