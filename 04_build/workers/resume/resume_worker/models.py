"""Worker-local compatibility models for the frozen resume/evidence contracts.

These dataclasses mirror the fields this lane consumes from Schema Core. They
stay inside the worker boundary until Fork 02 publishes the canonical package.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any, Literal

SCHEMA_VERSION = "resume-evidence-schema-2026-05-31.v1"
ATS_TEST_MATRIX_VERSION = "ats-matrix-2026-05-31.v1"


def _drop_none(value: Any) -> Any:
    if isinstance(value, dict):
        return {key: _drop_none(item) for key, item in value.items() if item is not None}
    if isinstance(value, list):
        return [_drop_none(item) for item in value]
    return value


@dataclass(frozen=True)
class SourceBullet:
    id: str
    section: str
    text: str
    line_number: int

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class EvidenceAtom:
    id: str
    source_bullet_id: str
    claim_text: str
    normalized_terms: tuple[str, ...]
    evidence_type: Literal["impact", "scope", "skill", "ownership", "delivery"]
    confidence: Literal["high", "medium", "low"] = "medium"

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["normalized_terms"] = list(self.normalized_terms)
        return data


@dataclass(frozen=True)
class ResumeDocument:
    document_id: str
    session_id: str
    source_name: str
    text_sha256: str
    raw_text: str
    source_bullets: tuple[SourceBullet, ...]
    evidence_atoms: tuple[EvidenceAtom, ...] = ()
    schema_version: str = SCHEMA_VERSION

    def with_evidence(self, evidence_atoms: list[EvidenceAtom]) -> "ResumeDocument":
        return ResumeDocument(
            document_id=self.document_id,
            session_id=self.session_id,
            source_name=self.source_name,
            text_sha256=self.text_sha256,
            raw_text=self.raw_text,
            source_bullets=self.source_bullets,
            evidence_atoms=tuple(evidence_atoms),
            schema_version=self.schema_version,
        )

    def to_dict(self, include_raw_text: bool = False) -> dict[str, Any]:
        data = asdict(self)
        data["source_bullets"] = [bullet.to_dict() for bullet in self.source_bullets]
        data["evidence_atoms"] = [atom.to_dict() for atom in self.evidence_atoms]
        if not include_raw_text:
            data.pop("raw_text", None)
        return _drop_none(data)


@dataclass(frozen=True)
class ResumeBullet:
    id: str
    text: str
    supported_by_source_bullet_ids: tuple[str, ...]
    supported_by_evidence_atom_ids: tuple[str, ...]
    schema_version: str = SCHEMA_VERSION
    prompt_version: str = "resume-rewrite-prompt-2026-05-31.v1"

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["supported_by_source_bullet_ids"] = list(self.supported_by_source_bullet_ids)
        data["supported_by_evidence_atom_ids"] = list(self.supported_by_evidence_atom_ids)
        return data


@dataclass(frozen=True)
class RewriteRejection:
    source_bullet_id: str | None
    reason: str
    candidate_text: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return _drop_none(asdict(self))


@dataclass(frozen=True)
class ResumeRewriteResult:
    document_id: str
    bullets: tuple[ResumeBullet, ...]
    rejected: tuple[RewriteRejection, ...]
    schema_version: str = SCHEMA_VERSION

    def to_dict(self) -> dict[str, Any]:
        return {
            "document_id": self.document_id,
            "schema_version": self.schema_version,
            "bullets": [bullet.to_dict() for bullet in self.bullets],
            "rejected": [item.to_dict() for item in self.rejected],
        }


@dataclass(frozen=True)
class ATSRiskFlag:
    id: str
    category: str
    severity: Literal["high", "medium", "low"]
    message: str
    evidence: str

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class ATSKeywordFinding:
    keyword: str
    matched_text: str | None
    match_type: Literal["exact", "fuzzy", "missing"]

    def to_dict(self) -> dict[str, Any]:
        return _drop_none(asdict(self))


@dataclass(frozen=True)
class ATSReport:
    document_id: str
    ats_test_matrix_version: str
    layout_risk_flags: tuple[ATSRiskFlag, ...]
    keyword_findings: tuple[ATSKeywordFinding, ...]
    parser_risk_summary: str
    schema_version: str = SCHEMA_VERSION
    notes: tuple[str, ...] = field(default_factory=tuple)

    def to_dict(self) -> dict[str, Any]:
        return {
            "document_id": self.document_id,
            "schema_version": self.schema_version,
            "ats_test_matrix_version": self.ats_test_matrix_version,
            "layout_risk_flags": [flag.to_dict() for flag in self.layout_risk_flags],
            "keyword_findings": [finding.to_dict() for finding in self.keyword_findings],
            "parser_risk_summary": self.parser_risk_summary,
            "notes": list(self.notes),
        }
