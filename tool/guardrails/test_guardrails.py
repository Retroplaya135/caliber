from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

import guardrails


class GuardrailUnitTests(unittest.TestCase):
    def write_base_config(self, root: Path) -> None:
        (root / "config/guardrails").mkdir(parents=True)
        (root / "config/guardrails/secret_patterns.txt").write_text("# version: 1\nCALIBER-SECRET-001 secret-scan: potential secret detected\nsk-[A-Za-z0-9_-]{20,}\n", encoding="utf-8")
        (root / "config/guardrails/handoff_required_fields.txt").write_text("Stamp:\nLane / Worker:\n", encoding="utf-8")

    def test_normalized_json_sorts_keys(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "fixture.json"
            path.write_text('{"b": 2, "a": 1}', encoding="utf-8")
            self.assertEqual(guardrails.normalized_json(path), '{\n  "a": 1,\n  "b": 2\n}\n')

    def test_domain_purity_finding_uses_exact_code(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "packages/core/domain/lib/bad.dart"
            target.parent.mkdir(parents=True)
            target.write_text("import 'package:flutter/widgets.dart';\n", encoding="utf-8")
            findings = guardrails.check_domain_purity(root)
            self.assertEqual(findings[0].code, "CALIBER-LINT-001 domain-purity: domain code must not import Flutter or data-layer packages")

    def test_handoff_fixture_requires_fields(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write_base_config(root)
            (root / "handoff").mkdir()
            (root / "handoff/bad.md").write_text("CALIBER HANDOFF STATUS BLOCK\nStamp: x\n", encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_handoff(root)

    def test_secret_scan_detects_key_shape(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write_base_config(root)
            target = root / "scratch/secret.txt"
            target.parent.mkdir()
            shaped_secret = "-".join(("sk", "123456789012345678901234"))
            target.write_text(f"{shaped_secret}\n", encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_secrets(root)

    def test_secret_scan_ignores_only_the_seeded_violation_fixture(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write_base_config(root)
            fixture = root / "tool/guardrails/seeded_violations.py"
            fixture.parent.mkdir(parents=True)
            seeded_value = "".join(("sk", "-", "123456789012345678901234", "\n"))
            fixture.write_text(seeded_value, encoding="utf-8")
            guardrails.check_secrets(root)

            duplicate = root / "tool/guardrails/copied_fixture.py"
            duplicate.write_text(fixture.read_text(encoding="utf-8"), encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_secrets(root)

    def test_disposal_accepts_a_subscription_registered_for_teardown(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "apps/mobile/test/subscription_test.dart"
            target.parent.mkdir(parents=True)
            target.write_text(
                "final subscription = source.listen(events.add);\n"
                "addTearDown(subscription.cancel);\n",
                encoding="utf-8",
            )
            self.assertEqual(guardrails.check_disposal(root), [])

    def test_disposal_rejects_an_uncancelled_subscription(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "apps/mobile/lib/leak.dart"
            target.parent.mkdir(parents=True)
            target.write_text("source.listen(events.add);\n", encoding="utf-8")
            self.assertEqual(len(guardrails.check_disposal(root)), 1)

    def test_version_tags_are_required_for_expected_goldens(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.write_base_config(root)
            target = root / "goldens/gateway/expected/no_version.json"
            target.parent.mkdir(parents=True)
            target.write_text('{"status": "missing"}', encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_version_tags(root)

    def test_codegen_requires_generated_parts(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "packages/core/lib/model.dart"
            target.parent.mkdir(parents=True)
            target.write_text("part 'model.g.dart';\n", encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_codegen(root)

    def test_golden_approval_updates_expected_fixture(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            expected = root / "goldens/gateway/expected/a.json"
            actual = root / "goldens/gateway/actual/a.json"
            expected.parent.mkdir(parents=True)
            actual.parent.mkdir(parents=True)
            expected.write_text('{"version": "v1", "value": 1}', encoding="utf-8")
            actual.write_text('{"version": "v1", "value": 2}', encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_goldens(root, approve=False)
            guardrails.check_goldens(root, approve=True)
            guardrails.check_goldens(root, approve=False)

    def test_complexity_budget_catches_import_overage(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "packages/core/lib/complex.dart"
            target.parent.mkdir(parents=True)
            target.write_text("\n".join([f"import 'p{i}.dart';" for i in range(13)]), encoding="utf-8")
            with self.assertRaises(guardrails.GateFailure):
                guardrails.check_complexity(root)


if __name__ == "__main__":
    unittest.main()
