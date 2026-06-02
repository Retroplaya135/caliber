from __future__ import annotations

import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path

from resume_worker.tools import upstream_contracts

_BLOCKED_SNAKE_SCORE_FIELD = "overall" + "_score"
_BLOCKED_CAMEL_SCORE_FIELD = "overall" + "Score"


class UpstreamContractProbeTests(unittest.TestCase):
    def test_default_roots_prefer_current_integrated_worktree(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo_root = Path(tmp) / "integration"
            worker_root = repo_root / "04_build/workers/resume"
            (repo_root / "04_build/shared").mkdir(parents=True)
            (repo_root / "04_build/ai_gateway").mkdir(parents=True)
            worker_root.mkdir(parents=True)

            self.assertEqual(repo_root, upstream_contracts.default_schema_root(worker_root))
            self.assertEqual(repo_root, upstream_contracts.default_gateway_root(worker_root))

    def test_default_roots_fallback_to_sibling_forks_for_isolated_lane(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            worktrees = Path(tmp) / ".worktrees"
            worker_root = worktrees / "fork-07-resume-evidence/04_build/workers/resume"
            worker_root.mkdir(parents=True)

            self.assertEqual(
                worktrees / "fork-02-schemas-ds",
                upstream_contracts.default_schema_root(worker_root),
            )
            self.assertEqual(
                worktrees / "fork-03-ai-gateway",
                upstream_contracts.default_gateway_root(worker_root),
            )

    def test_schema_probe_rejects_score_based_ats_report(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema_root, gateway_root = _write_upstreams(root)
            _write_schema(
                schema_root,
                ats_contract=_score_bearing_ats_contract(),
            )
            _write_gateway(gateway_root, resume_ready=True)

            result = upstream_contracts.audit_upstreams(schema_root, gateway_root)

            self.assertIn("CALIBER-SCHEMA-ATS-001 score-field", _codes(result))

    def test_gateway_probe_rejects_interview_only_judge(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema_root, gateway_root = _write_upstreams(root)
            _write_schema(schema_root, ats_contract="class ATSReport { List<String> risks; }")
            _write_gateway(gateway_root, resume_ready=False)

            result = upstream_contracts.audit_upstreams(schema_root, gateway_root)

            self.assertIn("CALIBER-GATEWAY-RESUME-001 missing-resume-ats-path", _codes(result))

    def test_probe_accepts_score_free_schema_and_resume_gateway(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema_root, gateway_root = _write_upstreams(root)
            _write_schema(schema_root, ats_contract="class ATSReport { List<String> risks; }")
            _write_gateway(gateway_root, resume_ready=True)

            result = upstream_contracts.audit_upstreams(schema_root, gateway_root)

            self.assertTrue(result.ready)
            self.assertEqual([], _codes(result))

    def test_cli_strict_mode_fails_on_upstream_blockers(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema_root, gateway_root = _write_upstreams(root)
            _write_schema(
                schema_root,
                ats_contract=_score_bearing_ats_contract(),
            )
            _write_gateway(gateway_root, resume_ready=False)

            with redirect_stdout(StringIO()):
                code = upstream_contracts.main(
                    [
                        "--schema-root",
                        str(schema_root),
                        "--gateway-root",
                        str(gateway_root),
                        "--fail-on-blocker",
                    ]
                )

            self.assertEqual(1, code)

    def test_cli_report_mode_does_not_fail_on_upstream_blockers(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            schema_root, gateway_root = _write_upstreams(root)
            _write_schema(
                schema_root,
                ats_contract=_score_bearing_ats_contract(),
            )
            _write_gateway(gateway_root, resume_ready=False)

            with redirect_stdout(StringIO()):
                code = upstream_contracts.main(
                    ["--schema-root", str(schema_root), "--gateway-root", str(gateway_root)]
                )

            self.assertEqual(0, code)


def _write_upstreams(root: Path) -> tuple[Path, Path]:
    return root / "fork-02-schemas-ds", root / "fork-03-ai-gateway"


def _score_bearing_ats_contract() -> str:
    return f"class ATSReport {{ double {_BLOCKED_CAMEL_SCORE_FIELD}; /* {_BLOCKED_SNAKE_SCORE_FIELD} */ }}"


def _write_schema(schema_root: Path, *, ats_contract: str) -> None:
    schema_path = schema_root / "04_build/shared/lib/src/schemas"
    interface_path = schema_root / "04_build/shared/lib/src/interfaces"
    schema_path.mkdir(parents=True)
    interface_path.mkdir(parents=True)
    (schema_path / "ai_output_contracts.dart").write_text(ats_contract, encoding="utf-8")
    (interface_path / "schema_interfaces.dart").write_text(
        "abstract interface class StructuredJudge {\n"
        "  Future<ResumeBullet> rewriteResumeBullet();\n"
        "  Future<ATSReport> analyzeAts();\n"
        "}\n",
        encoding="utf-8",
    )


def _write_gateway(gateway_root: Path, *, resume_ready: bool) -> None:
    gateway_path = gateway_root / "04_build/ai_gateway/src/caliber_ai_gateway"
    gateway_path.mkdir(parents=True)
    if resume_ready:
        pipeline = (
            "class StructuredJudge:\n"
            "    def rewrite_resume(self) -> 'ResumeBullet': pass\n"
            "    def analyze_ats(self) -> 'ATSReport': pass\n"
        )
        models = "feature = 'resume_rewrite'\nschema_name = 'ats_report'\n"
    else:
        pipeline = "class StructuredJudge:\n    def judge(self): pass\n"
        models = "feature: Literal['interview_content']\n"
    (gateway_path / "pipeline.py").write_text(pipeline, encoding="utf-8")
    (gateway_path / "models.py").write_text(models, encoding="utf-8")


def _codes(result: upstream_contracts.ContractProbeResult) -> list[str]:
    return [finding.code for finding in result.findings]


if __name__ == "__main__":
    unittest.main()
