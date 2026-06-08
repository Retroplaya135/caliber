"""Evidence frame extraction for resume bullets."""

from __future__ import annotations

import re

from .models import EvidenceAtom, ResumeDocument

_TERM_PATTERN = re.compile(r"[A-Za-z][A-Za-z0-9+#.-]{2,}")
_METRIC_PATTERN = re.compile(r"(?:\b\d+(?:\.\d+)?%?\b|\$\d+[A-Za-z0-9,.]*)")
_STOP_TERMS = {
    "and",
    "for",
    "from",
    "the",
    "with",
    "that",
    "this",
    "into",
    "using",
    "across",
}


def build_evidence_atoms(document: ResumeDocument) -> list[EvidenceAtom]:
    atoms: list[EvidenceAtom] = []
    for bullet in document.source_bullets:
        terms = tuple(_normalized_terms(bullet.text))
        evidence_type = _classify_evidence(bullet.text)
        confidence = "high" if _METRIC_PATTERN.search(bullet.text) else "medium"
        atoms.append(
            EvidenceAtom(
                id=f"ev_{len(atoms) + 1:04d}",
                source_bullet_id=bullet.id,
                claim_text=bullet.text,
                normalized_terms=terms,
                evidence_type=evidence_type,
                confidence=confidence,
            )
        )
    return atoms


def _normalized_terms(text: str) -> list[str]:
    terms: list[str] = []
    seen: set[str] = set()
    for match in _TERM_PATTERN.findall(text):
        term = match.lower().strip(".")
        if term in _STOP_TERMS or term in seen:
            continue
        seen.add(term)
        terms.append(term)
    return terms


def _classify_evidence(text: str) -> str:
    lowered = text.lower()
    if _METRIC_PATTERN.search(text) or any(token in lowered for token in ("reduced", "increased", "improved")):
        return "impact"
    if any(token in lowered for token in ("led", "managed", "owned")):
        return "ownership"
    if any(token in lowered for token in ("built", "implemented", "designed", "automated", "migrated")):
        return "delivery"
    if any(token in lowered for token in ("python", "dart", "flutter", "fastapi", "sql", "aws")):
        return "skill"
    return "scope"
