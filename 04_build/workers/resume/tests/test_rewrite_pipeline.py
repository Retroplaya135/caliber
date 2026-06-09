from __future__ import annotations

import unittest

from resume_worker.models import ResumeRewriteResult, ResumeBullet
from resume_worker.parsing import parse_resume_document
from resume_worker.rewrite_pipeline import ResumeRewritePipeline, persist_rewrite_payload
from resume_worker.structured_judge import DeterministicFixtureJudge, RewriteCandidate


class UngroundedJudge:
    def rewrite_resume_bullets(self, *, evidence_atoms, target_role, prompt_version):
        return (
            RewriteCandidate(
                text="Invented $10M revenue growth with no support.",
                supported_by_source_bullet_ids=(),
                supported_by_evidence_atom_ids=(),
            ),
        )


class UnknownProvenanceJudge:
    def rewrite_resume_bullets(self, *, evidence_atoms, target_role, prompt_version):
        return (
            RewriteCandidate(
                text="Built supported work but declared unknown provenance.",
                supported_by_source_bullet_ids=("src_missing",),
                supported_by_evidence_atom_ids=("ev_missing",),
            ),
        )


class MismatchedProvenanceJudge:
    def rewrite_resume_bullets(self, *, evidence_atoms, target_role, prompt_version):
        return (
            RewriteCandidate(
                text="Built supported work but mixed evidence from another source.",
                supported_by_source_bullet_ids=("src_0001",),
                supported_by_evidence_atom_ids=("ev_0002",),
            ),
        )


class RewritePipelineTests(unittest.TestCase):
    def test_every_rewritten_bullet_traces_to_source_and_evidence(self) -> None:
        document = parse_resume_document(
            (
                "Experience\n"
                "- Built Python automation that reduced release work by 30%.\n"
                "- Owned CI migration for Flutter test workflow across 8 apps.\n"
            ).encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewritePipeline(DeterministicFixtureJudge()).run(
            document,
            "backend platform engineer",
        )
        payload = persist_rewrite_payload(result, document)

        self.assertGreater(len(payload["bullets"]), 0)
        for bullet in payload["bullets"]:
            self.assertTrue(bullet["supported_by_source_bullet_ids"])
            self.assertTrue(bullet["supported_by_evidence_atom_ids"])

    def test_no_source_rewrite_candidate_is_rejected(self) -> None:
        document = parse_resume_document(
            "Experience\n- Built Python service that reduced latency by 20%.\n".encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewritePipeline(UngroundedJudge()).run(document, "backend engineer")

        self.assertEqual(result.bullets, ())
        self.assertEqual(result.rejected[0].reason, "rewrite candidate has no source support")

    def test_no_source_bullet_fails_to_persist(self) -> None:
        document = parse_resume_document(
            "Experience\n- Built Python service that reduced latency by 20%.\n".encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewriteResult(
            document_id=document.document_id,
            bullets=(
                ResumeBullet(
                    id="rw_0001",
                    text="Ungrounded bullet.",
                    supported_by_source_bullet_ids=(),
                    supported_by_evidence_atom_ids=("ev_0001",),
                ),
            ),
            rejected=(),
        )

        with self.assertRaisesRegex(ValueError, "no source bullet"):
            persist_rewrite_payload(result, document)

    def test_unknown_persisted_provenance_fails_to_persist(self) -> None:
        document = parse_resume_document(
            "Experience\n- Built Python service that reduced latency by 20%.\n".encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewriteResult(
            document_id=document.document_id,
            bullets=(
                ResumeBullet(
                    id="rw_0001",
                    text="Built Python service that reduced latency by 20%.",
                    supported_by_source_bullet_ids=("src_missing",),
                    supported_by_evidence_atom_ids=("ev_missing",),
                ),
            ),
            rejected=(),
        )

        with self.assertRaisesRegex(ValueError, "unknown provenance"):
            persist_rewrite_payload(result, document)

    def test_mismatched_persisted_provenance_fails_to_persist(self) -> None:
        document = parse_resume_document(
            (
                "Experience\n"
                "- Built Python service that reduced latency by 20%.\n"
                "- Owned Flutter workflow that improved release confidence by 30%.\n"
            ).encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewriteResult(
            document_id=document.document_id,
            bullets=(
                ResumeBullet(
                    id="rw_0001",
                    text="Built Python service that reduced latency by 20%.",
                    supported_by_source_bullet_ids=("src_0001",),
                    supported_by_evidence_atom_ids=("ev_0002",),
                ),
            ),
            rejected=(),
        )

        with self.assertRaisesRegex(ValueError, "evidence does not trace"):
            persist_rewrite_payload(result, document)

    def test_different_document_fails_to_persist(self) -> None:
        document = parse_resume_document(
            "Experience\n- Built Python service that reduced latency by 20%.\n".encode(),
            "resume.txt",
            "session-1",
        )
        result = ResumeRewriteResult(
            document_id="resume_other",
            bullets=(),
            rejected=(),
        )

        with self.assertRaisesRegex(ValueError, "different resume document"):
            persist_rewrite_payload(result, document)

    def test_unknown_provenance_is_rejected(self) -> None:
        document = parse_resume_document(
            (
                "Experience\n"
                "- Built Python service that reduced latency by 20%.\n"
                "- Owned Flutter workflow that improved release confidence by 30%.\n"
            ).encode(),
            "resume.txt",
            "session-1",
        )

        result = ResumeRewritePipeline(UnknownProvenanceJudge()).run(document, "backend engineer")

        self.assertEqual(result.bullets, ())
        self.assertEqual(result.rejected[0].reason, "rewrite candidate references unknown provenance")

    def test_mismatched_evidence_source_pair_is_rejected(self) -> None:
        document = parse_resume_document(
            (
                "Experience\n"
                "- Built Python service that reduced latency by 20%.\n"
                "- Owned Flutter workflow that improved release confidence by 30%.\n"
            ).encode(),
            "resume.txt",
            "session-1",
        )

        result = ResumeRewritePipeline(MismatchedProvenanceJudge()).run(document, "backend engineer")

        self.assertEqual(result.bullets, ())
        self.assertEqual(
            result.rejected[0].reason,
            "rewrite candidate evidence atoms do not trace to the declared source bullets",
        )


if __name__ == "__main__":
    unittest.main()
