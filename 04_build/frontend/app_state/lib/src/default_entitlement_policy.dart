import 'package:caliber_shared/caliber_shared.dart' as schema;

final class DefaultEntitlementPolicy implements schema.EntitlementPolicy {
  const DefaultEntitlementPolicy();

  @override
  schema.EntitlementDecision evaluate({
    required schema.EntitlementSnapshot snapshot,
    required String featureKey,
    required String policyVersion,
    required DateTime evaluatedAt,
  }) {
    final allowed = switch (snapshot.status) {
      schema.EntitlementStatus.active ||
      schema.EntitlementStatus.grace ||
      schema.EntitlementStatus.trial => true,
      schema.EntitlementStatus.expired ||
      schema.EntitlementStatus.revoked => false,
    };
    return schema.EntitlementDecision(
      decisionId: 'entitlement:${snapshot.userId}:$featureKey',
      allowed: allowed,
      reasonCode: allowed ? 'entitled' : 'not_entitled',
      policyVersion: policyVersion,
      snapshot: snapshot,
    );
  }
}
