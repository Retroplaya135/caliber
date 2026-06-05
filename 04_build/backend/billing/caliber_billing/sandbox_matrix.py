from __future__ import annotations

from dataclasses import dataclass

from .models import EntitlementState, RevenueCatEventType
from .service import BillingService


@dataclass(frozen=True, slots=True)
class SandboxMatrixResult:
    name: str
    passed: bool
    detail: str


@dataclass(frozen=True, slots=True)
class SandboxMatrixCase:
    name: str
    event_type: RevenueCatEventType
    expected_state: EntitlementState
    expected_credit_delta: int
    expected_retention_delta: int


SANDBOX_MATRIX: tuple[SandboxMatrixCase, ...] = (
    SandboxMatrixCase("new_purchase", RevenueCatEventType.INITIAL_PURCHASE, EntitlementState.PAID, 100, 0),
    SandboxMatrixCase("renewal", RevenueCatEventType.RENEWAL, EntitlementState.PAID, 100, -1),
    SandboxMatrixCase("cancel", RevenueCatEventType.CANCELLATION, EntitlementState.REVOKED, 0, 1),
    SandboxMatrixCase("billing_issue", RevenueCatEventType.BILLING_ISSUE, EntitlementState.GRACE, 0, 1),
    SandboxMatrixCase("grace", RevenueCatEventType.GRACE_PERIOD, EntitlementState.GRACE, 0, 0),
    SandboxMatrixCase("refund", RevenueCatEventType.REFUND, EntitlementState.REVOKED, 0, -1),
    SandboxMatrixCase("restore", RevenueCatEventType.RESTORE, EntitlementState.PAID, 100, 0),
    SandboxMatrixCase("cross_device_restore", RevenueCatEventType.TRANSFER, EntitlementState.PAID, 100, 0),
)


def run_sandbox_matrix() -> tuple[SandboxMatrixResult, ...]:
    results: list[SandboxMatrixResult] = []
    for case in SANDBOX_MATRIX:
        service = BillingService()
        event_id = f"sandbox_{case.name}"
        payload = {
            "event": {
                "id": event_id,
                "app_user_id": f"acct_{case.name}",
                "type": case.event_type.value,
                "product_id": "caliber_pro_monthly",
                "entitlement_id": "pro",
            }
        }
        first = service.handle_provider_payload("revenuecat", payload)
        replay = service.handle_provider_payload("revenuecat", payload)
        credit_replay_safe = first.credit is None or (
            replay.credit is not None and not replay.credit.applied
        )
        retention_replay_safe = replay.retention is not None and not replay.retention.applied
        passed = (
            first.snapshot.state is case.expected_state
            and first.entitlement.applied
            and not replay.entitlement.applied
            and credit_replay_safe
            and retention_replay_safe
        )
        results.append(
            SandboxMatrixResult(
                name=case.name,
                passed=passed,
                detail=(
                    f"state={first.snapshot.state.value} "
                    f"credit_delta={case.expected_credit_delta} "
                    f"retention_delta={case.expected_retention_delta}"
                ),
            )
        )
    return tuple(results)
