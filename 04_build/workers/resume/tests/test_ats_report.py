from __future__ import annotations

import json
import unittest
from pathlib import Path

from resume_worker.ats import build_ats_report
from resume_worker.parsing import parse_resume_document


class ATSReportTests(unittest.TestCase):
    def test_ats_report_matches_golden_and_has_no_score(self) -> None:
        document = parse_resume_document(
            (
                "alex@example.com      (415) 555-0100\n"
                "Experience\tSkills\n"
                "- Built Python FastAPI service that reduced latency by 18%.\n"
                "- Delivered Flutter dashboard for interview preparation.\n"
            ).encode(),
            "resume.txt",
            "session-ats",
        )

        report = build_ats_report(document, ["Python", "FastAPI", "Flutter", "Kubernetes"])
        payload = report.to_dict()
        golden = json.loads(
            (Path(__file__).parent / "fixtures/golden/ats_report.json").read_text()
        )

        self.assertEqual(payload, golden)
        self.assertFalse(_contains_score_like_key(payload))

    def test_score_free_guard_rejects_score_like_fields(self) -> None:
        self.assertTrue(_contains_score_like_key({"score": 82}))
        self.assertTrue(_contains_score_like_key({"overall" + "_score": 0.82}))
        self.assertTrue(_contains_score_like_key({"nested": [{"atsScore": 80}]}))
        self.assertFalse(_contains_score_like_key({"parser_risk_summary": ["ok"]}))

    def test_layout_matrix_flags_contact_embedded_and_header_footer_risks(self) -> None:
        document = parse_resume_document(
            (
                "Header: Alex Candidate\n"
                "Experience\n"
                "- Built Python service that reduced latency by 18%.\n"
                "- Delivered Flutter dashboard with image based skill badges.\n"
                "Page 1\n"
            ).encode(),
            "resume.txt",
            "session-ats",
        )

        report = build_ats_report(document, ["Kubernets"])
        flag_ids = {flag.id for flag in report.layout_risk_flags}

        self.assertIn("embedded_objects", flag_ids)
        self.assertIn("missing_email", flag_ids)
        self.assertIn("missing_phone", flag_ids)
        self.assertIn("header_footer_content", flag_ids)
        self.assertEqual(report.keyword_findings[0].match_type, "missing")


def _contains_score_like_key(value) -> bool:
    if isinstance(value, dict):
        return any(
            _is_score_like_key(key) or _contains_score_like_key(item)
            for key, item in value.items()
        )
    if isinstance(value, list):
        return any(_contains_score_like_key(item) for item in value)
    return False


def _is_score_like_key(key: str) -> bool:
    normalized = key.replace("-", "_").lower()
    return (
        normalized == "score"
        or normalized.startswith("score_")
        or normalized.endswith("_score")
        or normalized.endswith("score")
        or "_score_" in normalized
    )


if __name__ == "__main__":
    unittest.main()
