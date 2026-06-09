#!/usr/bin/env python3
"""Prove every Guardrail CI gate fails on a seeded violation."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PYTHON = sys.executable
GUARDRAILS = ROOT / "tool/guardrails/guardrails.py"


def copy_base(dst: Path) -> None:
    for rel in ["config", "goldens", "handoff"]:
        shutil.copytree(ROOT / rel, dst / rel)


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def run_gate(tmp: Path, command: str, expected: str) -> str:
    result = subprocess.run([PYTHON, str(GUARDRAILS), command, "--root", str(tmp)], text=True, capture_output=True)
    output = result.stdout + result.stderr
    if result.returncode == 0:
        raise AssertionError(f"{command} unexpectedly passed")
    if expected not in output:
        raise AssertionError(f"{command} did not emit expected message `{expected}`\n{output}")
    return expected


def prove(name: str, command: str, expected: str, seed) -> str:
    with tempfile.TemporaryDirectory(prefix=f"caliber-{name}-") as tmp_name:
        tmp = Path(tmp_name)
        copy_base(tmp)
        seed(tmp)
        message = run_gate(tmp, command, expected)
        print(f"CALIBER-SEEDED-FAIL: {name}: {message}")
        return message


def prove_golden_approval() -> tuple[str, str]:
    with tempfile.TemporaryDirectory(prefix="caliber-golden-") as tmp_name:
        tmp = Path(tmp_name)
        copy_base(tmp)
        actual = tmp / "goldens/gateway/actual/provider_adapter_handshake.json"
        actual.write_text('{"version":"golden-gateway-v1","provider":"ProviderAdapter","model":"gpt-5.4-mini","schema":"strict_json_schema","status":"changed"}\n', encoding="utf-8")
        fail_message = run_gate(tmp, "golden", "CALIBER-GOLDEN-001 gateway golden diff")
        env = dict(os.environ)
        env["CALIBER_APPROVE_GOLDENS"] = "1"
        approved = subprocess.run([PYTHON, str(GUARDRAILS), "golden", "--root", str(tmp)], text=True, capture_output=True, env=env)
        if approved.returncode != 0 or "CALIBER-GOLDEN-APPROVED: gateway/provider_adapter_handshake.json" not in approved.stdout:
            raise AssertionError("gateway golden approval flow did not update expected output\n" + approved.stdout + approved.stderr)
        clean = subprocess.run([PYTHON, str(GUARDRAILS), "golden", "--root", str(tmp)], text=True, capture_output=True)
        if clean.returncode != 0:
            raise AssertionError("approved gateway golden did not pass\n" + clean.stdout + clean.stderr)
        print(f"CALIBER-SEEDED-FAIL: golden-output: {fail_message}")

    with tempfile.TemporaryDirectory(prefix="caliber-component-golden-") as tmp_name:
        tmp = Path(tmp_name)
        copy_base(tmp)
        actual = tmp / "goldens/design_system/actual/glass_token_contract.json"
        actual.write_text('{"version":"golden-design-system-v1","surface":"glass","blur":20,"opacity":0.72,"contrast_overlay":true,"reduced_transparency_fallback":true}\n', encoding="utf-8")
        component_message = run_gate(tmp, "golden", "CALIBER-GOLDEN-001 design_system golden diff")
        env = dict(os.environ)
        env["CALIBER_APPROVE_GOLDENS"] = "1"
        approved = subprocess.run([PYTHON, str(GUARDRAILS), "golden", "--root", str(tmp)], text=True, capture_output=True, env=env)
        if approved.returncode != 0 or "CALIBER-GOLDEN-APPROVED: design_system/glass_token_contract.json" not in approved.stdout:
            raise AssertionError("design-system golden approval flow did not update expected output\n" + approved.stdout + approved.stderr)
        clean = subprocess.run([PYTHON, str(GUARDRAILS), "golden", "--root", str(tmp)], text=True, capture_output=True)
        if clean.returncode != 0:
            raise AssertionError("approved design-system golden did not pass\n" + clean.stdout + clean.stderr)
        print(f"CALIBER-SEEDED-FAIL: golden-component: {component_message}")
    return fail_message, component_message


def main() -> int:
    messages: list[str] = []
    messages.append(prove("secret-scan", "secret", "CALIBER-SECRET-001 secret-scan: potential secret detected", lambda tmp: write(tmp / "scratch/secret.txt", "api_key = '12345678901234567890'\n")))
    messages.append(prove("version-tag", "version", "CALIBER-VERSION-001 version-tag: artifact missing version tag", lambda tmp: write(tmp / "goldens/gateway/expected/no_version.json", '{"status":"missing"}\n')))
    messages.append(prove("domain-purity", "lint", "CALIBER-LINT-001 domain-purity: domain code must not import Flutter or data-layer packages", lambda tmp: write(tmp / "packages/core/domain/lib/bad.dart", "import 'package:flutter/widgets.dart';\n")))
    messages.append(prove("repository-boundary", "lint", "CALIBER-LINT-002 repository-boundary: UI may depend on repository interfaces only, never concrete repositories/services", lambda tmp: write(tmp / "packages/app/presentation/lib/bad.dart", "final repo = ConcreteRepository();\n")))
    messages.append(prove("raw-style-ban", "lint", "CALIBER-LINT-003 raw-style-ban: use design tokens instead of raw Color/size literals", lambda tmp: write(tmp / "packages/design_system/lib/src/bad.dart", "final c = Color(0xFFFFFFFF);\n")))
    messages.append(prove("disposal", "lint", "CALIBER-LINT-004 disposal: classes creating controllers/subscriptions must implement dispose", lambda tmp: write(tmp / "apps/mobile/lib/bad.dart", "final c = TextEditingController();\n")))
    messages.append(prove("banned-import", "lint", "CALIBER-LINT-005 banned-import: package boundary violation", lambda tmp: write(tmp / "packages/app/presentation/lib/bad.dart", "import 'package:caliber_app/gateway/internal.dart';\n")))
    messages.append(prove("complexity-budget", "complexity", "CALIBER-COMPLEXITY-001 complexity-budget: file exceeds configured budget", lambda tmp: write(tmp / "packages/core/lib/complex.dart", "\n".join([f"import 'p{i}.dart';" for i in range(13)]))))
    messages.append(prove("build-runner", "codegen", "CALIBER-CODEGEN-001 build_runner: generated part missing or stale", lambda tmp: write(tmp / "packages/core/lib/model.dart", "part 'model.g.dart';\n")))
    messages.extend(prove_golden_approval())
    messages.append(prove("handoff-shape", "handoff", "CALIBER-HANDOFF-001 handoff-shape: missing required CALIBER HANDOFF STATUS BLOCK field", lambda tmp: write(tmp / "handoff/bad.md", "CALIBER HANDOFF STATUS BLOCK\nStamp: x\n")))
    print("CALIBER-SEEDED-CLEAN: every required gate failed on its seeded violation and golden approval flow passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
