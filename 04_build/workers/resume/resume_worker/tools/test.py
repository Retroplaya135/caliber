"""Stdlib unittest runner with optional trace coverage."""

from __future__ import annotations

import argparse
import contextlib
import io
import sys
import unittest
from pathlib import Path
from trace import Trace


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--coverage", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[2]
    tests = root / "tests"
    sys.path.insert(0, str(root))

    if args.coverage:
        tracer = Trace(count=True, trace=False, ignoredirs=[sys.prefix, sys.exec_prefix])
        stream = io.StringIO()
        with contextlib.redirect_stdout(stream):
            result = tracer.runfunc(_run_tests, tests)
        print(stream.getvalue(), end="")
        coverage = _coverage_percent(tracer, root / "resume_worker")
        print(f"coverage {coverage:.1f}%")
        return 0 if result.wasSuccessful() and coverage >= 70.0 else 1

    result = _run_tests(tests)
    return 0 if result.wasSuccessful() else 1


def _run_tests(tests: Path) -> unittest.result.TestResult:
    suite = unittest.defaultTestLoader.discover(str(tests))
    runner = unittest.TextTestRunner(stream=sys.stdout, verbosity=2)
    return runner.run(suite)


def _coverage_percent(tracer: Trace, package_root: Path) -> float:
    results = tracer.results()
    counts = results.counts
    executable = 0
    covered = 0
    for path in package_root.rglob("*.py"):
        if "__pycache__" in path.parts:
            continue
        if path.name == "__init__.py" or "tools" in path.parts:
            continue
        lines = path.read_text().splitlines()
        for index, line in enumerate(lines, start=1):
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or stripped.startswith(("\"\"\"", "'''")):
                continue
            if stripped in {"else:", "try:", "finally:"}:
                continue
            executable += 1
            if (str(path), index) in counts:
                covered += 1
    return 100.0 if executable == 0 else covered / executable * 100


if __name__ == "__main__":
    raise SystemExit(main())
