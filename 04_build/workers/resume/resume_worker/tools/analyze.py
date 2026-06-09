"""Stdlib static checks for the Resume Evidence worker."""

from __future__ import annotations

import compileall
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    ok = compileall.compile_dir(str(root), quiet=1, force=True)
    if not ok:
        print("compileall failed")
        return 1
    print(f"analyze passed: compiled {root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
