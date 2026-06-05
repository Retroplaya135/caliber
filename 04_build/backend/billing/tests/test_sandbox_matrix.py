import unittest
from io import StringIO
from unittest.mock import patch

from caliber_billing.__main__ import main
from caliber_billing.sandbox_matrix import SANDBOX_MATRIX, run_sandbox_matrix


class BillingSandboxMatrixTests(unittest.TestCase):
    def test_matrix_covers_required_provider_events(self) -> None:
        names = {case.name for case in SANDBOX_MATRIX}

        self.assertEqual(
            names,
            {
                "new_purchase",
                "renewal",
                "cancel",
                "billing_issue",
                "grace",
                "refund",
                "restore",
                "cross_device_restore",
            },
        )

    def test_matrix_is_runnable_and_replay_safe(self) -> None:
        results = run_sandbox_matrix()

        self.assertTrue(results)
        self.assertEqual([], [result for result in results if not result.passed])

    def test_matrix_cli_returns_success(self) -> None:
        with patch("sys.stdout", new_callable=StringIO):
            exit_code = main()

        self.assertEqual(exit_code, 0)


if __name__ == "__main__":
    unittest.main()
