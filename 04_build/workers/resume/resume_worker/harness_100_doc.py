"""Runnable 100-document rewrite review harness for Lane AU validation."""

from __future__ import annotations

import argparse
import json

from .parsing import parse_resume_document
from .rewrite_pipeline import ResumeRewritePipeline, persist_rewrite_payload
from .structured_judge import DeterministicFixtureJudge


def generate_review_cases(count: int = 100) -> list[dict[str, str]]:
    cases: list[dict[str, str]] = []
    for index in range(1, count + 1):
        cases.append(
            {
                "case_id": f"review_{index:03d}",
                "target_role": "backend platform engineer" if index % 2 else "flutter engineer",
                "resume_text": (
                    "Experience\n"
                    f"- Built Python service {index} that reduced batch latency by {10 + index % 20}%.\n"
                    f"- Led migration of Flutter workflow {index} serving {1000 + index} weekly users.\n"
                    "Skills\n"
                    "- Python, FastAPI, Flutter, SQL, CI automation.\n"
                ),
            }
        )
    return cases


def run_review_set(count: int = 100) -> dict[str, object]:
    pipeline = ResumeRewritePipeline(DeterministicFixtureJudge())
    failures: list[dict[str, str]] = []
    for case in generate_review_cases(count):
        document = parse_resume_document(
            case["resume_text"].encode("utf-8"),
            f"{case['case_id']}.txt",
            session_id="review-harness",
        )
        result = pipeline.run(document, case["target_role"])
        payload = persist_rewrite_payload(result, document)
        for bullet in payload["bullets"]:  # type: ignore[index]
            if not bullet["supported_by_source_bullet_ids"] or not bullet["supported_by_evidence_atom_ids"]:
                failures.append({"case_id": case["case_id"], "reason": "ungrounded rewrite"})
    return {
        "harness": "100-document rewrite review",
        "case_count": count,
        "unsupported_rewrite_count": len(failures),
        "failures": failures,
        "lane_au_validation_required": True,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=100)
    args = parser.parse_args()
    print(json.dumps(run_review_set(args.count), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
