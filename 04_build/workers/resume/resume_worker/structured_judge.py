"""Gateway Core read-only port for provenance-bound resume rewriting."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from .models import EvidenceAtom


@dataclass(frozen=True)
class RewriteCandidate:
    text: str
    supported_by_source_bullet_ids: tuple[str, ...]
    supported_by_evidence_atom_ids: tuple[str, ...]


class StructuredJudge(Protocol):
    """Gateway Core port.

    The concrete implementation must live behind Fork 03's ProviderAdapter.
    This worker never calls model vendors directly.
    """

    def rewrite_resume_bullets(
        self,
        *,
        evidence_atoms: tuple[EvidenceAtom, ...],
        target_role: str,
        prompt_version: str,
    ) -> tuple[RewriteCandidate, ...]:
        """Return strict structured rewrite candidates with provenance IDs."""


class DeterministicFixtureJudge:
    """Test/review harness implementation; not a production model caller."""

    def rewrite_resume_bullets(
        self,
        *,
        evidence_atoms: tuple[EvidenceAtom, ...],
        target_role: str,
        prompt_version: str,
    ) -> tuple[RewriteCandidate, ...]:
        candidates: list[RewriteCandidate] = []
        for atom in evidence_atoms:
            target = target_role.strip() or "target role"
            text = f"{atom.claim_text.rstrip('.')} for {target} readiness."
            candidates.append(
                RewriteCandidate(
                    text=text,
                    supported_by_source_bullet_ids=(atom.source_bullet_id,),
                    supported_by_evidence_atom_ids=(atom.id,),
                )
            )
        return tuple(candidates)
