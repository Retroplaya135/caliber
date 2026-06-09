"""Resume Evidence worker-local guardrail checks."""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCAN_SUFFIXES = {".md", ".py", ".yaml", ".yml", ".toml", ".json"}
SKIP_DIRS = {"__pycache__", ".dart_tool", ".pytest_cache"}

REQUIRED_HANDOFF_FIELDS = (
    "CALIBER HANDOFF STATUS BLOCK",
    "Stamp:",
    "Lane / Worker:",
    "Phase / Stage / Step / Iteration:",
    "── COMPLETED THIS OUTPUT ──────────────────────",
    "── FILES CREATED / MODIFIED ───────────────────",
    "── BUILD / DEPENDENCY STATUS ──────────────────",
    "melos analyze:",
    "melos test:",
    "pub get:",
    "npm status:",
    "codegen:",
    "── VALIDATION STATUS ──────────────────────────",
    "guardrail CI:",
    "golden tests:",
    "contract tests:",
    "de-risk spike:",
    "── BRANCH STATUS ──────────────────────────────",
    "branch:",
    "base:",
    "rebased onto main:",
    "ahead/behind:",
    "mergeable:",
    "── MERGE STATUS ───────────────────────────────",
    "target:",
    "gates passed:",
    "merge decision:",
    "── BRANCH-HANDOFF FINDINGS (important) ─────────",
    "── DECISIONS / DEVIATIONS ──────────────────────",
    "── NEXT STEPS ──────────────────────────────────",
    "── BLOCKERS ────────────────────────────────────",
)

SECRET_PATTERNS = (
    re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"(?i)\b(api[_-]?key|secret|token|password)\s*[:=]\s*['\"][^'\"]{8,}"),
)
TLS_BYPASS_PATTERNS = (
    re.compile("bad" + "Certificate" + "Callback"),
    re.compile("Http" + r"Overrides\.global"),
    re.compile(r"verify\s*=\s*False"),
)


@dataclass(frozen=True)
class Finding:
    code: str
    path: Path
    detail: str

    def render(self) -> str:
        rel = self.path.relative_to(ROOT) if self.path.is_relative_to(ROOT) else self.path
        return f"{self.code} | {rel}: {self.detail}"


class GuardrailFailure(Exception):
    def __init__(self, findings: list[Finding]) -> None:
        self.findings = findings
        super().__init__("\n".join(finding.render() for finding in findings))


def iter_files(root: Path = ROOT) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.is_file() and path.suffix in SCAN_SUFFIXES:
            files.append(path)
    return sorted(files)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def check_handoff(root: Path = ROOT) -> None:
    path = root / "docs/handoff_status.md"
    text = read_text(path) if path.exists() else ""
    missing = [field for field in REQUIRED_HANDOFF_FIELDS if field not in text]
    if missing:
        raise GuardrailFailure([
            Finding(
                "CALIBER-HANDOFF-001 handoff-shape",
                path,
                "missing " + ", ".join(missing[:3]),
            )
        ])
    print("CALIBER-HANDOFF-CLEAN: resume handoff block shape is complete")


def check_profile(root: Path = ROOT) -> None:
    path = root / "docs/profiling_artifact.md"
    text = read_text(path) if path.exists() else ""
    required = (
        "resume-profile-2026-05-31.v1",
        "single_document_parse_rewrite_ats",
        "rewrite_review_harness",
        "ats_black_box_harness",
    )
    missing = [item for item in required if item not in text]
    if missing:
        raise GuardrailFailure([
            Finding(
                "CALIBER-PROFILE-001 missing-profile-artifact",
                path,
                "missing " + ", ".join(missing),
            )
        ])
    print("CALIBER-PROFILE-CLEAN: resume profiling artifact is present")


def check_secret_tls_scan(root: Path = ROOT) -> None:
    findings: list[Finding] = []
    for path in iter_files(root):
        text = read_text(path)
        if any(pattern.search(text) for pattern in SECRET_PATTERNS):
            findings.append(
                Finding(
                    "CALIBER-SECRET-001 secret-scan",
                    path,
                    "remove secret-like value or keep only inert fixture labels",
                )
            )
        if any(pattern.search(text) for pattern in TLS_BYPASS_PATTERNS):
            findings.append(
                Finding(
                    "CALIBER-TLS-001 tls-bypass",
                    path,
                    "remove TLS bypass or unsafe certificate override",
                )
            )
    if findings:
        raise GuardrailFailure(findings)
    print("CALIBER-SECRET-CLEAN: no secret-like values or TLS bypasses found")


def run_all(root: Path = ROOT) -> None:
    check_handoff(root)
    check_profile(root)
    check_secret_tls_scan(root)
    print("CALIBER-RESUME-GUARDRAILS-CLEAN: worker-local guardrails passed")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs="?", choices=["all", "handoff", "profile", "secret"], default="all")
    args = parser.parse_args(argv)
    try:
        {
            "all": run_all,
            "handoff": check_handoff,
            "profile": check_profile,
            "secret": check_secret_tls_scan,
        }[args.command]()
    except GuardrailFailure as error:
        for finding in error.findings:
            print(finding.render(), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
