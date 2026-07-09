from __future__ import annotations

import sys
import types
import unittest

from resume_worker.evidence import build_evidence_atoms
from resume_worker.parsing import parse_resume_document


class ParsingEvidenceTests(unittest.TestCase):
    def test_text_resume_parses_source_bullets_and_evidence(self) -> None:
        document = parse_resume_document(
            (
                "Experience\n"
                "- Built FastAPI service that reduced batch latency by 24%.\n"
                "- Led Flutter migration for 1200 weekly users.\n"
            ).encode(),
            "resume.txt",
            "session-1",
        )

        atoms = build_evidence_atoms(document)

        self.assertEqual(len(document.source_bullets), 2)
        self.assertEqual(atoms[0].source_bullet_id, "src_0001")
        self.assertEqual(atoms[0].evidence_type, "impact")
        self.assertIn("fastapi", atoms[0].normalized_terms)

    def test_empty_payload_rejected(self) -> None:
        with self.assertRaisesRegex(ValueError, "empty"):
            parse_resume_document(b"", "resume.txt", "session-1")

    def test_pdf_uses_pymupdf_text_pages_without_disk_write(self) -> None:
        class FakePage:
            def get_text(self, mode: str) -> str:
                if mode != "text":
                    raise AssertionError(mode)
                return "- Built Python parser that reduced extraction review by 25%."

        class FakeDocument:
            def __enter__(self):
                return [FakePage()]

            def __exit__(self, exc_type, exc, tb):
                return False

        fake_fitz = types.SimpleNamespace(open=lambda **kwargs: FakeDocument())
        original = sys.modules.get("fitz")
        sys.modules["fitz"] = fake_fitz
        try:
            document = parse_resume_document(b"%PDF fake", "resume.pdf", "session-pdf")
        finally:
            if original is None:
                sys.modules.pop("fitz", None)
            else:
                sys.modules["fitz"] = original

        self.assertEqual(document.source_bullets[0].text, "Built Python parser that reduced extraction review by 25%.")

    def test_docx_uses_paragraphs_and_tables(self) -> None:
        class FakeParagraph:
            def __init__(self, text: str) -> None:
                self.text = text

        class FakeCell:
            def __init__(self, text: str) -> None:
                self.text = text

        class FakeRow:
            cells = [FakeCell("- Led Flutter rollout for 1400 weekly users.")]

        class FakeTable:
            rows = [FakeRow()]

        class FakeDocx:
            paragraphs = [FakeParagraph("- Built FastAPI worker that improved parse coverage by 30%.")]
            tables = [FakeTable()]

        fake_docx = types.SimpleNamespace(Document=lambda stream: FakeDocx())
        original = sys.modules.get("docx")
        sys.modules["docx"] = fake_docx
        try:
            document = parse_resume_document(b"docx", "resume.docx", "session-docx")
        finally:
            if original is None:
                sys.modules.pop("docx", None)
            else:
                sys.modules["docx"] = original

        self.assertEqual(len(document.source_bullets), 2)

    def test_pdf_falls_back_to_pypdf_when_pymupdf_fails(self) -> None:
        class FakePdfPage:
            def extract_text(self) -> str:
                return "- Built PDF fallback parser that improved extraction resilience by 22%."

        class FakePdfReader:
            def __init__(self, stream) -> None:
                self.pages = [FakePdfPage()]

        fake_fitz = types.SimpleNamespace(open=lambda **kwargs: (_ for _ in ()).throw(RuntimeError("bad pdf")))
        fake_pypdf = types.SimpleNamespace(PdfReader=FakePdfReader)
        originals = {name: sys.modules.get(name) for name in ("fitz", "pypdf")}
        sys.modules["fitz"] = fake_fitz
        sys.modules["pypdf"] = fake_pypdf
        try:
            document = parse_resume_document(b"%PDF fake", "resume.pdf", "session-pdf")
        finally:
            for name, original in originals.items():
                if original is None:
                    sys.modules.pop(name, None)
                else:
                    sys.modules[name] = original

        self.assertIn("fallback parser", document.source_bullets[0].text)

    def test_unstructured_fallback_extracts_elements(self) -> None:
        auto_module = types.ModuleType("unstructured.partition.auto")
        auto_module.partition = lambda **kwargs: [
            "- Built unstructured fallback that reduced manual parsing by 12%."
        ]
        partition_module = types.ModuleType("unstructured.partition")
        root_module = types.ModuleType("unstructured")
        originals = {
            name: sys.modules.get(name)
            for name in ("unstructured", "unstructured.partition", "unstructured.partition.auto")
        }
        sys.modules["unstructured"] = root_module
        sys.modules["unstructured.partition"] = partition_module
        sys.modules["unstructured.partition.auto"] = auto_module
        try:
            document = parse_resume_document(b"rtf-ish", "resume.rtf", "session-unstructured")
        finally:
            for name, original in originals.items():
                if original is None:
                    sys.modules.pop(name, None)
                else:
                    sys.modules[name] = original

        self.assertIn("unstructured fallback", document.source_bullets[0].text)

    def test_unsupported_file_type_errors_without_persisting_payload(self) -> None:
        with self.assertRaisesRegex(ValueError, "unsupported"):
            parse_resume_document(b"plain", "resume.rtf", "session-rtf")


if __name__ == "__main__":
    unittest.main()
