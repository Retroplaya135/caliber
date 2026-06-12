import 'feature_gate.dart';

enum EntitlementState {
  free,
  trial,
  paid,
  grace,
  revoked,
}

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.accountId,
    required this.state,
    required this.version,
    this.activeProductId,
  });

  final String accountId;
  final EntitlementState state;
  final int version;
  final String? activeProductId;

  bool get serverAuthorized {
    return switch (state) {
      EntitlementState.trial ||
      EntitlementState.paid ||
      EntitlementState.grace =>
        true,
      EntitlementState.free || EntitlementState.revoked => false,
    };
  }
}

abstract interface class EntitlementPolicy {
  FeatureGateDecision decide({
    required EntitlementSnapshot serverSnapshot,
    required CaliberFeatureId featureId,
  });
}

final class ServerAuthoritativeEntitlementPolicy implements EntitlementPolicy {
  const ServerAuthoritativeEntitlementPolicy();

  @override
  FeatureGateDecision decide({
    required EntitlementSnapshot serverSnapshot,
    required CaliberFeatureId featureId,
  }) {
    final cost = caliberFeatureCosts[featureId]!;
    if (cost == CaliberFeatureCostClass.localFree) {
      return FeatureGateDecision(
        featureId: featureId,
        allowed: true,
        reason: 'local-first feature remains free',
        requiresCredit: false,
      );
    }
    if (!serverSnapshot.serverAuthorized) {
      return FeatureGateDecision(
        featureId: featureId,
        allowed: false,
        reason: 'server entitlement required',
        requiresCredit: true,
      );
    }
    return FeatureGateDecision(
      featureId: featureId,
      allowed: true,
      reason: 'server entitlement active',
      requiresCredit: true,
    );
  }
}
