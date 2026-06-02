"""Read-only upstream contract probe for Resume Evidence integration."""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FORBIDDEN_ATS_SCORE_TOKENS = ("overall" + "_score", "overall" + "Score")


@dataclass(frozen=True)
class ContractFinding:
    code: str
    path: Path
    detail: str

    def to_dict(self) -> dict[str, str]:
        return {
            "code": self.code,
            "path": str(self.path),
            "detail": self.detail,
        }


@dataclass(frozen=True)
class ContractProbeResult:
    findings: tuple[ContractFinding, ...]

    @property
    def ready(self) -> bool:
        return not self.findings

    def to_dict(self) -> dict[str, object]:
        return {
            "probe": "resume-upstream-contracts",
            "ready": self.ready,
            "finding_count": len(self.findings),
            "findings": [finding.to_dict() for finding in self.findings],
        }


def default_worktree(name: str, root: Path = ROOT) -> Path:
    for parent in root.parents:
        if parent.name == ".worktrees":
            return parent / name
    return root.parents[2] / ".worktrees" / name


def current_repo_root(root: Path = ROOT) -> Path:
    return root.parents[2]


def default_schema_root(root: Path = ROOT) -> Path:
    repo_root = current_repo_root(root)
    if (repo_root / "04_build/shared").exists():
        return repo_root
    return default_worktree("fork-02-schemas-ds", root)


def default_gateway_root(root: Path = ROOT) -> Path:
    repo_root = current_repo_root(root)
    if (repo_root / "04_build/ai_gateway").exists():
        return repo_root
    return default_worktree("fork-03-ai-gateway", root)


def audit_upstreams(schema_root: Path, gateway_root: Path) -> ContractProbeResult:
    findings = [*audit_schema_core(schema_root), *audit_gateway_core(gateway_root)]
    return ContractProbeResult(tuple(findings))


def audit_schema_core(schema_root: Path) -> list[ContractFinding]:
    findings: list[ContractFinding] = []
    ats_path = schema_root / "04_build/shared/lib/src/schemas/ai_output_contracts.dart"
    interface_path = schema_root / "04_build/shared/lib/src/interfaces/schema_interfaces.dart"

    ats_text = _read_or_missing(ats_path, findings, "CALIBER-UPSTREAM-001 missing-schema-core")
    interface_text = _read_or_missing(
        interface_path,
        findings,
        "CALIBER-UPSTREAM-002 missing-schema-interface",
    )

    if ats_text:
        if "ATSReport" not in ats_text:
            findings.append(
                ContractFinding(
                    "CALIBER-SCHEMA-ATS-002 missing-ats-report",
                    ats_path,
                    "Schema Core must expose an ATSReport contract for Resume Evidence.",
                )
            )
        if any(token in ats_text for token in FORBIDDEN_ATS_SCORE_TOKENS):
            findings.append(
                ContractFinding(
                    "CALIBER-SCHEMA-ATS-001 score-field",
                    ats_path,
                    "Resume Evidence requires a score-free ATS report; remove score-bearing ATS fields.",
                )
            )

    if interface_text:
        for method in ("rewriteResumeBullet", "analyzeAts"):
            if method not in interface_text:
                findings.append(
                    ContractFinding(
                        "CALIBER-SCHEMA-JUDGE-001 missing-method",
                        interface_path,
                        f"StructuredJudge must expose {method}(...) for Resume Evidence.",
                    )
                )

    return findings


def audit_gateway_core(gateway_root: Path) -> list[ContractFinding]:
    findings: list[ContractFinding] = []
    pipeline_path = gateway_root / "04_build/ai_gateway/src/caliber_ai_gateway/pipeline.py"
    models_path = gateway_root / "04_build/ai_gateway/src/caliber_ai_gateway/models.py"

    pipeline_text = _read_or_missing(
        pipeline_path,
        findings,
        "CALIBER-UPSTREAM-003 missing-gateway-pipeline",
    )
    models_text = _read_or_missing(
        models_path,
        findings,
        "CALIBER-UPSTREAM-004 missing-gateway-models",
    )
    combined = "\n".join(text for text in (pipeline_text, models_text) if text)

    if pipeline_text and "StructuredJudge" not in pipeline_text:
        findings.append(
            ContractFinding(
                "CALIBER-GATEWAY-JUDGE-001 missing-structured-judge",
                pipeline_path,
                "Gateway Core must expose a StructuredJudge boundary.",
            )
        )

    resume_tokens = ("rewrite_resume", "resume_rewrite", "rewriteResume", "ResumeBullet")
    ats_tokens = ("analyze_ats", "ats_report", "analyzeAts", "ATSReport")
    if combined:
        if not any(token in combined for token in resume_tokens) or not any(
            token in combined for token in ats_tokens
        ):
            findings.append(
                ContractFinding(
                    "CALIBER-GATEWAY-RESUME-001 missing-resume-ats-path",
                    gateway_root,
                    "Gateway Core must expose resume rewrite and ATS analysis paths, not interview-only judging.",
                )
            )

    return findings


def _read_or_missing(path: Path, findings: list[ContractFinding], code: str) -> str:
    if not path.exists():
        findings.append(ContractFinding(code, path, "expected upstream contract file is missing"))
        return ""
    return path.read_text(encoding="utf-8", errors="ignore")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--schema-root", type=Path, default=default_schema_root())
    parser.add_argument("--gateway-root", type=Path, default=default_gateway_root())
    parser.add_argument("--fail-on-blocker", action="store_true")
    args = parser.parse_args(argv)

    result = audit_upstreams(args.schema_root, args.gateway_root)
    print(json.dumps(result.to_dict(), indent=2, sort_keys=True))
    return 1 if args.fail_on_blocker and not result.ready else 0


if __name__ == "__main__":
    raise SystemExit(main())
