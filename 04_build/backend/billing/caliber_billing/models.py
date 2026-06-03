from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any, Mapping


class FeatureCostClass(StrEnum):
    LOCAL_FREE = "local_free"
    SERVER_EXPENSIVE = "server_expensive"


class FeatureId(StrEnum):
    LOCAL_CORPUS_SEARCH = "local_corpus_search"
    LOCAL_DELIVERY_SCORE = "local_delivery_score"
    LOCAL_ATS_REPORT = "local_ats_report"
    GATEWAY_INTERVIEW_EVAL = "gateway_interview_eval"
    CLOUD_STT = "cloud_stt"
    RESUME_REWRITE = "resume_rewrite"


FEATURE_COSTS: dict[FeatureId, FeatureCostClass] = {
    FeatureId.LOCAL_CORPUS_SEARCH: FeatureCostClass.LOCAL_FREE,
    FeatureId.LOCAL_DELIVERY_SCORE: FeatureCostClass.LOCAL_FREE,
    FeatureId.LOCAL_ATS_REPORT: FeatureCostClass.LOCAL_FREE,
    FeatureId.GATEWAY_INTERVIEW_EVAL: FeatureCostClass.SERVER_EXPENSIVE,
    FeatureId.CLOUD_STT: FeatureCostClass.SERVER_EXPENSIVE,
    FeatureId.RESUME_REWRITE: FeatureCostClass.SERVER_EXPENSIVE,
}


class EntitlementState(StrEnum):
    FREE = "free"
    TRIAL = "trial"
    PAID = "paid"
    GRACE = "grace"
    REVOKED = "revoked"


class LedgerName(StrEnum):
    ENTITLEMENT = "entitlement"
    CREDIT = "credit"
    RETENTION = "retention"


class RevenueCatEventType(StrEnum):
    INITIAL_PURCHASE = "INITIAL_PURCHASE"
    RENEWAL = "RENEWAL"
    CANCELLATION = "CANCELLATION"
    BILLING_ISSUE = "BILLING_ISSUE"
    GRACE_PERIOD = "GRACE_PERIOD"
    REFUND = "REFUND"
    TRANSFER = "TRANSFER"
    RESTORE = "RESTORE"


@dataclass(frozen=True, slots=True)
class LedgerEvent:
    ledger: LedgerName
    account_id: str
    idempotency_key: str
    delta: int
    reason: str
    source: str
    metadata: Mapping[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))


@dataclass(frozen=True, slots=True)
class LedgerDecision:
    event: LedgerEvent
    applied: bool
    balance_after: int
    replay_of: str | None = None


@dataclass(frozen=True, slots=True)
class EntitlementSnapshot:
    account_id: str
    state: EntitlementState
    active_product_id: str | None
    entitlement_version: int
    source_event_id: str | None

    @property
    def server_authorized(self) -> bool:
        return self.state in {
            EntitlementState.TRIAL,
            EntitlementState.PAID,
            EntitlementState.GRACE,
        }


@dataclass(frozen=True, slots=True)
class FeatureDecision:
    account_id: str
    feature_id: FeatureId
    allowed: bool
    reason: str
    requires_credit: bool = False


@dataclass(frozen=True, slots=True)
class RevenueCatEvent:
    event_id: str
    account_id: str
    event_type: RevenueCatEventType
    product_id: str | None = None
    entitlement_id: str | None = None
    purchased_at_ms: int | None = None
    raw: Mapping[str, Any] = field(default_factory=dict)

    @property
    def idempotency_key(self) -> str:
        return f"revenuecat:{self.event_id}:{self.event_type.value}"


@dataclass(frozen=True, slots=True)
class BillingSandboxCase:
    name: str
    event_type: RevenueCatEventType
    replay_safe: bool
    expected_entitlement: EntitlementState
    expected_credit_delta: int
    lane_au_validation: str
