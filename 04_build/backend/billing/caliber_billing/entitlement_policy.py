from __future__ import annotations

from typing import Protocol

from .models import (
    FEATURE_COSTS,
    EntitlementSnapshot,
    FeatureCostClass,
    FeatureDecision,
    FeatureId,
)


class EntitlementPolicy(Protocol):
    def decide(self, snapshot: EntitlementSnapshot, feature_id: FeatureId) -> FeatureDecision:
        """Decide using server-side entitlement state only."""


class ServerAuthoritativeEntitlementPolicy:
    def decide(self, snapshot: EntitlementSnapshot, feature_id: FeatureId) -> FeatureDecision:
        cost_class = FEATURE_COSTS[feature_id]
        if cost_class is FeatureCostClass.LOCAL_FREE:
            return FeatureDecision(
                account_id=snapshot.account_id,
                feature_id=feature_id,
                allowed=True,
                reason="local-first feature remains free",
            )

        if not snapshot.server_authorized:
            return FeatureDecision(
                account_id=snapshot.account_id,
                feature_id=feature_id,
                allowed=False,
                reason="server entitlement required",
                requires_credit=True,
            )

        return FeatureDecision(
            account_id=snapshot.account_id,
            feature_id=feature_id,
            allowed=True,
            reason="server entitlement active",
            requires_credit=True,
        )
