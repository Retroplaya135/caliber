"""Evidence-grounded resume rewrite pipeline."""

from __future__ import annotations

from dataclasses import dataclass

from .evidence import build_evidence_atoms
from .models import (
    EvidenceAtom,
    ResumeBullet,
    ResumeDocument,
    ResumeRewriteResult,
    RewriteRejection,
)
from .structured_judge import RewriteCandidate, StructuredJudge

PROMPT_VERSION = "resume-rewrite-prompt-2026-05-31.v1"


@dataclass(frozen=True)
class AdequacyDecision:
    evidence_atom: EvidenceAtom
    adequate: bool
    reason: str


class ResumeRewritePipeline:
    def __init__(self, judge: StructuredJudge) -> None:
        self._judge = judge

    def run(self, document: ResumeDocument, target_role: str) -> ResumeRewriteResult:
        evidence = tuple(build_evidence_atoms(document))
        enriched_document = document.with_evidence(list(evidence))
        adequate = self._adequacy_pass(enriched_document.evidence_atoms)
        selected, rejections = self._select_reject_pass(adequate, target_role)
        candidates = self._judge.rewrite_resume_bullets(
            evidence_atoms=tuple(selected),
            target_role=target_role,
            prompt_version=PROMPT_VERSION,
        )
        bullets, guard_rejections = self._provenance_guard(candidates, enriched_document)
        return ResumeRewriteResult(
            document_id=document.document_id,
            bullets=tuple(bullets),
            rejected=tuple(rejections + guard_rejections),
        )

    def _adequacy_pass(self, evidence_atoms: tuple[EvidenceAtom, ...]) -> list[AdequacyDecision]:
        decisions: list[AdequacyDecision] = []
        for atom in evidence_atoms:
            has_action = len(atom.claim_text.split()) >= 6
            has_terms = len(atom.normalized_terms) >= 3
            adequate = has_action and has_terms
            reason = "adequate" if adequate else "too little evidence to rewrite safely"
            decisions.append(AdequacyDecision(atom, adequate, reason))
        return decisions

    def _select_reject_pass(
        self, decisions: list[AdequacyDecision], target_role: str
    ) -> tuple[list[EvidenceAtom], list[RewriteRejection]]:
        target_terms = {term.lower() for term in target_role.replace("/", " ").split() if len(term) > 2}
        selected: list[EvidenceAtom] = []
        rejected: list[RewriteRejection] = []
        for decision in decisions:
            atom = decision.evidence_atom
            if not decision.adequate:
                rejected.append(RewriteRejection(atom.source_bullet_id, decision.reason))
                continue
            overlap = target_terms.intersection(atom.normalized_terms)
            impact_or_delivery = atom.evidence_type in {"impact", "delivery", "ownership"}
            if overlap or impact_or_delivery or not target_terms:
                selected.append(atom)
            else:
                rejected.append(
                    RewriteRejection(
                        atom.source_bullet_id,
                        "adequate but not selected for this target role",
                    )
                )
        return selected, rejected

    def _provenance_guard(
        self, candidates: tuple[RewriteCandidate, ...], document: ResumeDocument
    ) -> tuple[list[ResumeBullet], list[RewriteRejection]]:
        source_ids = {bullet.id for bullet in document.source_bullets}
        evidence_by_id = {atom.id: atom for atom in document.evidence_atoms}
        evidence_source_pairs = {(atom.id, atom.source_bullet_id) for atom in document.evidence_atoms}
        accepted: list[ResumeBullet] = []
        rejected: list[RewriteRejection] = []

        for candidate in candidates:
            if not candidate.supported_by_source_bullet_ids:
                rejected.append(RewriteRejection(None, "rewrite candidate has no source support", candidate.text))
                continue
            if not candidate.supported_by_evidence_atom_ids:
                rejected.append(RewriteRejection(None, "rewrite candidate has no evidence atom support", candidate.text))
                continue
            unknown_sources = set(candidate.supported_by_source_bullet_ids).difference(source_ids)
            unknown_atoms = set(candidate.supported_by_evidence_atom_ids).difference(evidence_by_id)
            if unknown_sources or unknown_atoms:
                rejected.append(RewriteRejection(None, "rewrite candidate references unknown provenance", candidate.text))
                continue
            if not any(
                (atom_id, source_id) in evidence_source_pairs
                for atom_id in candidate.supported_by_evidence_atom_ids
                for source_id in candidate.supported_by_source_bullet_ids
            ):
                rejected.append(
                    RewriteRejection(
                        None,
                        "rewrite candidate evidence atoms do not trace to the declared source bullets",
                        candidate.text,
                    )
                )
                continue
            accepted.append(
                ResumeBullet(
                    id=f"rw_{len(accepted) + 1:04d}",
                    text=candidate.text,
                    supported_by_source_bullet_ids=candidate.supported_by_source_bullet_ids,
                    supported_by_evidence_atom_ids=candidate.supported_by_evidence_atom_ids,
                    prompt_version=PROMPT_VERSION,
                )
            )
        return accepted, rejected


def persist_rewrite_payload(
    result: ResumeRewriteResult,
    grounding_document: ResumeDocument,
) -> dict[str, object]:
    """Return a persistable payload only if provenance is complete and grounded."""

    if result.document_id != grounding_document.document_id:
        raise ValueError("cannot persist rewrite for a different resume document")

    source_ids = {bullet.id for bullet in grounding_document.source_bullets}
    evidence_atoms = grounding_document.evidence_atoms or tuple(build_evidence_atoms(grounding_document))
    evidence_by_id = {atom.id: atom for atom in evidence_atoms}
    evidence_source_pairs = {(atom.id, atom.source_bullet_id) for atom in evidence_atoms}
    for bullet in result.bullets:
        if not bullet.supported_by_source_bullet_ids:
            raise ValueError(f"cannot persist ungrounded bullet {bullet.id}: no source bullet")
        if not bullet.supported_by_evidence_atom_ids:
            raise ValueError(f"cannot persist ungrounded bullet {bullet.id}: no evidence atom")
        unknown_sources = set(bullet.supported_by_source_bullet_ids).difference(source_ids)
        unknown_atoms = set(bullet.supported_by_evidence_atom_ids).difference(evidence_by_id)
        if unknown_sources or unknown_atoms:
            raise ValueError(f"cannot persist ungrounded bullet {bullet.id}: unknown provenance")
        if not any(
            (atom_id, source_id) in evidence_source_pairs
            for atom_id in bullet.supported_by_evidence_atom_ids
            for source_id in bullet.supported_by_source_bullet_ids
        ):
            raise ValueError(
                f"cannot persist ungrounded bullet {bullet.id}: evidence does not trace to source bullet"
            )
    return result.to_dict()
