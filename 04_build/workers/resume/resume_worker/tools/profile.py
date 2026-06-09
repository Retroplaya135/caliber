"""Timing profile for Resume Evidence worker review paths."""

from __future__ import annotations

import argparse
import json
from collections.abc import Callable
from time import perf_counter
from typing import Any

from ..ats import build_ats_report
from ..ats_black_box_harness import run_black_box_harness
from ..evidence import build_evidence_atoms
from ..harness_100_doc import run_review_set
from ..parsing import parse_resume_document
from ..rewrite_pipeline import ResumeRewritePipeline, persist_rewrite_payload
from ..structured_judge import DeterministicFixtureJudge


PROFILE_VERSION = "resume-profile-2026-05-31.v1"


def _timed(name: str, callback: Callable[[], dict[str, Any]]) -> dict[str, Any]:
    started = perf_counter()
    result = callback()
    elapsed_ms = (perf_counter() - started) * 1000
    return {
        "name": name,
        "elapsed_ms": round(elapsed_ms, 3),
        "result": result,
    }


def _single_document_flow() -> dict[str, Any]:
    text = (
        "alex@example.com (415) 555-0100\n"
        "Experience\n"
        "- Built Python FastAPI worker that reduced parse latency by 31%.\n"
        "- Delivered Flutter review dashboard for 900 weekly users.\n"
    )
    document = parse_resume_document(text.encode("utf-8"), "profile.txt", "profile-session")
    evidence = build_evidence_atoms(document)
    rewrite = ResumeRewritePipeline(DeterministicFixtureJudge()).run(
        document,
        "backend platform engineer",
    )
    ats = build_ats_report(document, ["Python", "FastAPI", "Flutter"])
    return {
        "source_bullets": len(document.source_bullets),
        "evidence_atoms": len(evidence),
        "rewrite_bullets": len(persist_rewrite_payload(rewrite, document)["bullets"]),
        "ats_flags": len(ats.layout_risk_flags),
        "ats_keywords": len(ats.keyword_findings),
    }


def run_profile(review_count: int = 100) -> dict[str, Any]:
    single_flow = _timed("single_document_parse_rewrite_ats", _single_document_flow)
    review = _timed("rewrite_review_harness", lambda: run_review_set(review_count))
    ats = _timed("ats_black_box_harness", run_black_box_harness)
    return {
        "profile_version": PROFILE_VERSION,
        "review_count": review_count,
        "timings": [single_flow, review, ats],
        "notes": [
            "Timing is local wall-clock evidence, not a production SLO.",
            "Harnesses stay deterministic and do not call hosted ATS or LLM providers.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--review-count", type=int, default=100)
    args = parser.parse_args()
    print(json.dumps(run_profile(args.review_count), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
