from __future__ import annotations

import json

from .sandbox_matrix import run_sandbox_matrix


def main() -> int:
    results = run_sandbox_matrix()
    print(
        json.dumps(
            [
                {"name": result.name, "passed": result.passed, "detail": result.detail}
                for result in results
            ],
            indent=2,
            sort_keys=True,
        )
    )
    return 0 if all(result.passed for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
