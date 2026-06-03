from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping

from .entitlement_policy import EntitlementPolicy, ServerAuthoritativeEntitlementPolicy
from .ledgers import CreditLedger, EntitlementLedger, IdempotentLedgerStore, RetentionLedger
from .models import (
    EntitlementSnapshot,
    EntitlementState,
    FeatureDecision,
    FeatureId,
    LedgerDecision,
    LedgerEvent,
    LedgerName,
    RevenueCatEvent,
    RevenueCatEventType,
)
from .providers import BillingProviderRegistry, default_billing_registry


_PAID_EVENTS = {
    RevenueCatEventType.INITIAL_PURCHASE,
    RevenueCatEventType.RENEWAL,
    RevenueCatEventType.RESTORE,
    RevenueCatEventType.TRANSFER,
}


@dataclass(frozen=True, slots=True)
class BillingEventResult:
    entitlement: LedgerDecision
    credit: LedgerDecision | None
    retention: LedgerDecision | None
    snapshot: EntitlementSnapshot


class BillingService:
    def __init__(
        self,
        *,
        store: IdempotentLedgerStore | None = None,
        providers: BillingProviderRegistry | None = None,
        policy: EntitlementPolicy | None = None,
    ) -> None:
        self._store = store or IdempotentLedgerStore()
        self._providers = providers or default_billing_registry()
        self._policy = policy or ServerAuthoritativeEntitlementPolicy()
        self._entitlements: dict[str, EntitlementSnapshot] = {}
        self._entitlement_ledger = EntitlementLedger(self._store)
        self._credit_ledger = CreditLedger(self._store)
        self._retention_ledger = RetentionLedger(self._store)

    def handle_provider_payload(
        self,
        provider_name: str,
        payload: Mapping[str, object],
    ) -> BillingEventResult:
        event = self._providers.provider(provider_name).parse_server_event(payload)
        return self.handle_revenuecat_event(event)

    def handle_revenuecat_event(self, event: RevenueCatEvent) -> BillingEventResult:
        state = _state_for_revenuecat_event(event.event_type)
        entitlement_decision = self._entitlement_ledger.record(
            LedgerEvent(
                ledger=LedgerName.ENTITLEMENT,
                account_id=event.account_id,
                idempotency_key=event.idempotency_key,
                delta=_entitlement_delta(state),
                reason=f"revenuecat:{event.event_type.value}",
                source="revenuecat_server",
                metadata={
                    "event_id": event.event_id,
                    "product_id": event.product_id,
                    "entitlement_id": event.entitlement_id,
                },
            )
        )

        credit_decision = None
        if event.event_type in _PAID_EVENTS:
            credit_decision = self._credit_ledger.grant(
                LedgerEvent(
                    ledger=LedgerName.CREDIT,
                    account_id=event.account_id,
                    idempotency_key=f"{event.idempotency_key}:monthly-credit-grant",
                    delta=100,
                    reason="paid_entitlement_credit_grant",
                    source="revenuecat_server",
                    metadata={"event_id": event.event_id},
                )
            )

        retention_decision = self._retention_ledger.record(
            LedgerEvent(
                ledger=LedgerName.RETENTION,
                account_id=event.account_id,
                idempotency_key=f"{event.idempotency_key}:retained-token",
                delta=_retention_delta(event.event_type),
                reason="retention_token_lifecycle",
                source="revenuecat_server",
                metadata={"event_id": event.event_id, "event_type": event.event_type.value},
            )
        )

        existing = self._entitlements.get(event.account_id)
        if entitlement_decision.applied or existing is None:
            snapshot = EntitlementSnapshot(
                account_id=event.account_id,
                state=state,
                active_product_id=event.product_id,
                entitlement_version=entitlement_decision.balance_after,
                source_event_id=event.event_id,
            )
            self._entitlements[event.account_id] = snapshot
        else:
            snapshot = existing

        return BillingEventResult(
            entitlement=entitlement_decision,
            credit=credit_decision,
            retention=retention_decision,
            snapshot=snapshot,
        )

    def decide_feature(self, account_id: str, feature_id: FeatureId) -> FeatureDecision:
        snapshot = self._entitlements.get(
            account_id,
            EntitlementSnapshot(
                account_id=account_id,
                state=EntitlementState.FREE,
                active_product_id=None,
                entitlement_version=0,
                source_event_id=None,
            ),
        )
        return self._policy.decide(snapshot, feature_id)

    def burn_server_feature_credit(
        self,
        *,
        account_id: str,
        feature_id: FeatureId,
        request_id: str,
    ) -> LedgerDecision:
        decision = self.decide_feature(account_id, feature_id)
        if not decision.allowed:
            raise PermissionError(decision.reason)
        if not decision.requires_credit:
            return LedgerDecision(
                event=LedgerEvent(
                    ledger=LedgerName.CREDIT,
                    account_id=account_id,
                    idempotency_key=f"free:{feature_id.value}:{request_id}",
                    delta=0,
                    reason="free_local_feature_no_credit_burn",
                    source="billing_service",
                ),
                applied=False,
                balance_after=self._store.balance(LedgerName.CREDIT, account_id),
                replay_of=None,
            )
        return self._credit_ledger.burn(
            LedgerEvent(
                ledger=LedgerName.CREDIT,
                account_id=account_id,
                idempotency_key=f"credit-burn:{feature_id.value}:{request_id}",
                delta=-1,
                reason=f"server_feature:{feature_id.value}",
                source="billing_service",
            )
        )

    def balance(self, ledger: LedgerName, account_id: str) -> int:
        return self._store.balance(ledger, account_id)


def _state_for_revenuecat_event(event_type: RevenueCatEventType) -> EntitlementState:
    if event_type in _PAID_EVENTS:
        return EntitlementState.PAID
    if event_type is RevenueCatEventType.GRACE_PERIOD:
        return EntitlementState.GRACE
    if event_type is RevenueCatEventType.BILLING_ISSUE:
        return EntitlementState.GRACE
    if event_type in {RevenueCatEventType.CANCELLATION, RevenueCatEventType.REFUND}:
        return EntitlementState.REVOKED
    raise ValueError(f"unhandled RevenueCat event type: {event_type}")


def _entitlement_delta(state: EntitlementState) -> int:
    if state in {EntitlementState.PAID, EntitlementState.GRACE, EntitlementState.TRIAL}:
        return 1
    if state is EntitlementState.REVOKED:
        return -1
    return 0


def _retention_delta(event_type: RevenueCatEventType) -> int:
    if event_type in {RevenueCatEventType.BILLING_ISSUE, RevenueCatEventType.CANCELLATION}:
        return 1
    if event_type in {RevenueCatEventType.RENEWAL, RevenueCatEventType.REFUND}:
        return -1
    return 0
