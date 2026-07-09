from __future__ import annotations

import unittest

from resume_worker.ats import build_ats_report
from resume_worker.ats_black_box_harness import run_black_box_harness
from resume_worker.harness_100_doc import run_review_set
from resume_worker.parsing import parse_resume_document
from resume_worker.rewrite_pipeline import ResumeRewritePipeline, persist_rewrite_payload
from resume_worker.structured_judge import DeterministicFixtureJudge
from resume_worker.tools.profile import run_profile


class HarnessTests(unittest.TestCase):
    def test_100_doc_review_set_is_built_and_grounded(self) -> None:
        result = run_review_set(100)

        self.assertEqual(result["case_count"], 100)
        self.assertEqual(result["unsupported_rewrite_count"], 0)
        self.assertTrue(result["lane_au_validation_required"])

    def test_ats_black_box_harness_is_runnable(self) -> None:
        result = run_black_box_harness()

        self.assertEqual(result["case_count"], 2)
        self.assertEqual(result["harness"], "ATS black-box baseline")
        self.assertTrue(result["lane_au_validation_required"])

    def test_e2e_resume_to_rewrite_and_ats_report_slice(self) -> None:
        document = parse_resume_document(
            (
                "alex@example.com (415) 555-0100\n"
                "Experience\n"
                "- Built Python FastAPI worker that reduced parse latency by 31%.\n"
                "- Delivered Flutter review dashboard for 900 weekly users.\n"
            ).encode(),
            "resume.txt",
            "session-e2e",
        )

        rewrite = ResumeRewritePipeline(DeterministicFixtureJudge()).run(
            document,
            "backend platform engineer",
        )
        ats_report = build_ats_report(document, ["Python", "FastAPI", "Flutter"])

        self.assertGreater(len(persist_rewrite_payload(rewrite, document)["bullets"]), 0)
        self.assertEqual(ats_report.layout_risk_flags, ())
        self.assertEqual({item.match_type for item in ats_report.keyword_findings}, {"exact"})

    def test_profile_artifact_is_runnable(self) -> None:
        result = run_profile(review_count=3)

        self.assertEqual(result["profile_version"], "resume-profile-2026-05-31.v1")
        self.assertEqual(result["review_count"], 3)
        self.assertEqual({entry["name"] for entry in result["timings"]}, {
            "single_document_parse_rewrite_ats",
            "rewrite_review_harness",
            "ats_black_box_harness",
        })


if __name__ == "__main__":
    unittest.main()
