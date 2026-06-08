"""Deterministic ATS report generation.

The report deliberately emits parser/layout risks and keyword findings only.
It never emits or computes a numeric ATS score.
"""

from __future__ import annotations

import re
from difflib import SequenceMatcher

from .models import ATSKeywordFinding, ATSReport, ATSRiskFlag, ATS_TEST_MATRIX_VERSION, ResumeDocument

try:
    from rapidfuzz import fuzz, process  # type: ignore[import-not-found]
except Exception:  # pragma: no cover - exercised only when RapidFuzz is absent
    fuzz = None
    process = None


def build_ats_report(document: ResumeDocument, target_keywords: list[str]) -> ATSReport:
    text = document.raw_text
    flags = tuple(_layout_flags(text))
    findings = tuple(_keyword_findings(text, target_keywords))
    high_count = sum(1 for flag in flags if flag.severity == "high")
    medium_count = sum(1 for flag in flags if flag.severity == "medium")
    if high_count:
        summary = f"{high_count} high parser risk(s), {medium_count} medium parser risk(s)."
    elif medium_count:
        summary = f"{medium_count} medium parser risk(s); review before export."
    else:
        summary = "No high-risk parser layout issues detected by the current matrix."
    return ATSReport(
        document_id=document.document_id,
        ats_test_matrix_version=ATS_TEST_MATRIX_VERSION,
        layout_risk_flags=flags,
        keyword_findings=findings,
        parser_risk_summary=summary,
        notes=(
            "Deterministic report; no numeric ATS score is produced.",
            "Matrix flags are parser-risk heuristics and must be AU-certified against black-box tests.",
        ),
    )


def _layout_flags(text: str) -> list[ATSRiskFlag]:
    flags: list[ATSRiskFlag] = []
    lines = text.splitlines()
    if any("\t" in line or re.search(r"\S {6,}\S", line) for line in lines):
        flags.append(
            ATSRiskFlag(
                id="layout_columns_or_tabs",
                category="layout",
                severity="high",
                message="Possible columns or tabbed layout can scramble ATS parser order.",
                evidence="tab or six-plus-space gap detected",
            )
        )
    if re.search(r"\b(textbox|text box|shape|image|photo|icon)\b", text, re.IGNORECASE):
        flags.append(
            ATSRiskFlag(
                id="embedded_objects",
                category="layout",
                severity="high",
                message="Embedded objects can be ignored or misordered by ATS parsers.",
                evidence="embedded-object marker detected",
            )
        )
    if not re.search(r"[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}", text):
        flags.append(
            ATSRiskFlag(
                id="missing_email",
                category="contact",
                severity="medium",
                message="No email address detected in parsed text.",
                evidence="email regex found no match",
            )
        )
    if not re.search(r"(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}", text):
        flags.append(
            ATSRiskFlag(
                id="missing_phone",
                category="contact",
                severity="low",
                message="No US-style phone number detected in parsed text.",
                evidence="phone regex found no match",
            )
        )
    if any(line.strip().lower().startswith(("page ", "header:", "footer:")) for line in lines):
        flags.append(
            ATSRiskFlag(
                id="header_footer_content",
                category="layout",
                severity="medium",
                message="Header/footer content can be dropped by some ATS parsers.",
                evidence="header/footer/page marker detected",
            )
        )
    return flags


def _keyword_findings(text: str, target_keywords: list[str]) -> list[ATSKeywordFinding]:
    normalized_text = _normalize(text)
    words = re.findall(r"[A-Za-z][A-Za-z0-9+#.-]{1,}", text)
    findings: list[ATSKeywordFinding] = []
    for keyword in target_keywords:
        normalized_keyword = _normalize(keyword)
        if normalized_keyword in normalized_text:
            findings.append(ATSKeywordFinding(keyword=keyword, matched_text=keyword, match_type="exact"))
            continue
        matched_text, ratio = _best_match(keyword, words)
        if matched_text and ratio >= 86:
            findings.append(ATSKeywordFinding(keyword=keyword, matched_text=matched_text, match_type="fuzzy"))
        else:
            findings.append(ATSKeywordFinding(keyword=keyword, matched_text=None, match_type="missing"))
    return findings


def _best_match(keyword: str, words: list[str]) -> tuple[str | None, float]:
    if not words:
        return None, 0.0
    if process is not None and fuzz is not None:
        result = process.extractOne(keyword, words, scorer=fuzz.WRatio)
        if result is None:
            return None, 0.0
        match, ratio, _index = result
        return str(match), float(ratio)
    best = max(words, key=lambda word: SequenceMatcher(None, keyword.lower(), word.lower()).ratio())
    return best, SequenceMatcher(None, keyword.lower(), best.lower()).ratio() * 100


def _normalize(text: str) -> str:
    return " ".join(re.findall(r"[a-z0-9+#.-]+", text.lower()))
