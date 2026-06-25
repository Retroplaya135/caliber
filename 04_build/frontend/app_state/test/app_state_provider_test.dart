import 'package:caliber_app_state/caliber_app_state.dart';
import 'package:caliber_gateway_client/caliber_gateway_client.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('state providers initialize with typed empty states and dispose', () {
    final disposalLog = <String>[];
    final container = ProviderContainer(
      overrides: [providerDisposalLogProvider.overrideWithValue(disposalLog)],
    );
    addTearDown(container.dispose);

    final profileSub = container.listen(
      profileNotifierProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final corpusSub = container.listen(
      corpusSearchNotifierProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final interviewSub = container.listen(
      interviewSessionNotifierProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    final entitlementSub = container.listen(
      entitlementNotifierProvider,
      (previous, next) {},
      fireImmediately: true,
    );

    expect(profileSub.read().profiles, isEmpty);
    expect(corpusSub.read().results, isEmpty);
    expect(interviewSub.read().judgments, isEmpty);
    expect(entitlementSub.read().snapshot, isNull);

    profileSub.close();
    corpusSub.close();
    interviewSub.close();
    entitlementSub.close();
    container.dispose();

    expect(
      disposalLog,
      containsAll(<String>[
        'profile',
        'corpus_search',
        'interview_session',
        'entitlement',
      ]),
    );
  });

  test('gateway client and entitlement policy are wired as providers', () {
    final container = ProviderContainer(
      overrides: [
        gatewayClientConfigProvider.overrideWithValue(
          GatewayClientConfig(
            baseUrl: Uri.parse('http://127.0.0.1:8000'),
            apiKey: 'test',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(gatewayClientProvider), isA<GatewayClient>());
    expect(
      container.read(entitlementPolicyProvider),
      isA<schema.EntitlementPolicy>(),
    );
  });

  test('default entitlement policy allows active snapshots', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final policy = container.read(entitlementPolicyProvider);
    final now = DateTime.utc(2026);
    final snapshot = schema.EntitlementSnapshot(
      userId: 'user-1',
      status: schema.EntitlementStatus.active,
      planId: 'pro',
      effectiveAt: now,
    );

    final decision = policy.evaluate(
      snapshot: snapshot,
      featureKey: 'interview_judge',
      policyVersion: 'entitlement-policy-v1',
      evaluatedAt: now,
    );

    expect(decision.allowed, isTrue);
    expect(decision.reasonCode, 'entitled');
  });
}
