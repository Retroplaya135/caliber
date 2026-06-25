import 'package:caliber_app_shell/src/entitlement_policy.dart';
import 'package:caliber_app_shell/src/feature_gate.dart';
import 'package:caliber_app_shell/src/router_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = ServerAuthoritativeEntitlementPolicy();

  test('local-first features remain free without server entitlement', () {
    final decision = policy.decide(
      serverSnapshot: const EntitlementSnapshot(
        accountId: 'acct_free',
        state: EntitlementState.free,
        version: 0,
      ),
      featureId: CaliberFeatureId.localAtsReport,
    );

    expect(decision.allowed, isTrue);
    expect(decision.requiresCredit, isFalse);
  });

  test('expensive server features require server entitlement', () {
    final decision = policy.decide(
      serverSnapshot: const EntitlementSnapshot(
        accountId: 'acct_free',
        state: EntitlementState.free,
        version: 0,
      ),
      featureId: CaliberFeatureId.resumeRewrite,
    );

    expect(decision.allowed, isFalse);
    expect(decision.requiresCredit, isTrue);
    expect(decision.reason, contains('server entitlement'));
  });

  test('paid server entitlement allows expensive feature with credit burn', () {
    final decision = policy.decide(
      serverSnapshot: const EntitlementSnapshot(
        accountId: 'acct_paid',
        state: EntitlementState.paid,
        version: 1,
        activeProductId: 'caliber_pro_monthly',
      ),
      featureId: CaliberFeatureId.gatewayInterviewEval,
    );

    expect(decision.allowed, isTrue);
    expect(decision.requiresCredit, isTrue);
  });

  test('shell manifest nests every feature lane', () {
    final lanes = caliberShellDestinations.map((route) => route.lane).toSet();

    expect(lanes, containsAll(CaliberLane.values));
  });

  test('interview route stays reachable for local typed practice', () {
    final interview = caliberShellDestinations.firstWhere(
      (route) => route.lane == CaliberLane.interview,
    );

    expect(
      caliberFeatureCosts[interview.featureId],
      CaliberFeatureCostClass.localFree,
    );
  });
}
