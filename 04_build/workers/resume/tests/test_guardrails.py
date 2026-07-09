from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from resume_worker.tools import guardrails


class ResumeGuardrailTests(unittest.TestCase):
    def test_handoff_shape_requires_canonical_fields(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "docs/handoff_status.md").write_text("CALIBER HANDOFF STATUS BLOCK\n", encoding="utf-8")

            with self.assertRaises(guardrails.GuardrailFailure):
                guardrails.check_handoff(root)

    def test_profile_artifact_requires_all_timing_paths(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "docs").mkdir()
            (root / "docs/profiling_artifact.md").write_text(
                "resume-profile-2026-05-31.v1\nsingle_document_parse_rewrite_ats\n",
                encoding="utf-8",
            )

            with self.assertRaises(guardrails.GuardrailFailure):
                guardrails.check_profile(root)

    def test_secret_scan_rejects_secret_like_values(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "bad.py"
            secret_shape = "api_" + "key = '" + "abcd1234abcd1234" + "'\n"
            target.write_text(secret_shape, encoding="utf-8")

            with self.assertRaises(guardrails.GuardrailFailure):
                guardrails.check_secret_tls_scan(root)


if __name__ == "__main__":
    unittest.main()
