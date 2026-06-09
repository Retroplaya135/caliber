"""ATS black-box harness scaffold.

The default provider is a deterministic fixture so the harness is runnable in CI
without credentials. Lane AU can swap in a legal hosted parser adapter later.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from typing import Protocol

from .ats import build_ats_report
from .parsing import parse_resume_document


class BlackBoxATSParser(Protocol):
    def parse(self, resume_text: str) -> dict[str, object]:
        """Return parser observations from a black-box ATS target."""


@dataclass(frozen=True)
class FixtureBlackBoxATSParser:
    def parse(self, resume_text: str) -> dict[str, object]:
        risks = []
        if "\t" in resume_text or "      " in resume_text:
            risks.append("order_scramble")
        if "image" in resume_text.lower() or "textbox" in resume_text.lower():
            risks.append("object_drop")
        return {"provider": "fixture-greenhouse-baseline", "risks": risks}


def sanitized_cases() -> list[dict[str, object]]:
    return [
        {
            "case_id": "ats_clean_001",
            "target_keywords": ["Python", "FastAPI", "Flutter"],
            "resume_text": (
                "alex@example.com (415) 555-0100\n"
                "Experience\n"
                "- Built Python FastAPI gateway that reduced request latency by 18%.\n"
                "- Delivered Flutter dashboard for technical interview prep.\n"
            ),
        },
        {
            "case_id": "ats_columns_001",
            "target_keywords": ["Python", "FastAPI", "Flutter"],
            "resume_text": (
                "alex@example.com      (415) 555-0100\n"
                "Experience\tSkills\n"
                "- Built Python service      FastAPI\n"
                "- Delivered Flutter dashboard      CI\n"
            ),
        },
    ]


def run_black_box_harness(parser: BlackBoxATSParser | None = None) -> dict[str, object]:
    parser = parser or FixtureBlackBoxATSParser()
    results: list[dict[str, object]] = []
    for case in sanitized_cases():
        text = str(case["resume_text"])
        document = parse_resume_document(text.encode("utf-8"), f"{case['case_id']}.txt", "ats-black-box")
        report = build_ats_report(document, list(case["target_keywords"]))  # type: ignore[arg-type]
        black_box = parser.parse(text)
        results.append(
            {
                "case_id": case["case_id"],
                "ats_report": report.to_dict(),
                "black_box_observation": black_box,
            }
        )
    return {
        "harness": "ATS black-box baseline",
        "ats_test_matrix_version": results[0]["ats_report"]["ats_test_matrix_version"],
        "case_count": len(results),
        "results": results,
        "lane_au_validation_required": True,
    }


def main() -> int:
    argparse.ArgumentParser().parse_args()
    print(json.dumps(run_black_box_harness(), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
