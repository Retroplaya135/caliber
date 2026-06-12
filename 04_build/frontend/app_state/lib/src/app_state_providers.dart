import 'package:caliber_gateway_client/caliber_gateway_client.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_states.dart';
import 'default_entitlement_policy.dart';

final providerDisposalLogProvider = Provider<List<String>>((ref) => <String>[]);

final gatewayClientConfigProvider = Provider<GatewayClientConfig>(
  (ref) => GatewayClientConfig.fromEnvironment(),
);

final gatewayClientProvider = Provider<GatewayClient>(
  (ref) => GatewayClient(config: ref.watch(gatewayClientConfigProvider)),
);

final entitlementPolicyProvider = Provider<schema.EntitlementPolicy>(
  (ref) => const DefaultEntitlementPolicy(),
);

final profileNotifierProvider =
    NotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
      ProfileNotifier.new,
    );

final corpusSearchNotifierProvider =
    NotifierProvider.autoDispose<CorpusSearchNotifier, CorpusSearchState>(
      CorpusSearchNotifier.new,
    );

final interviewSessionNotifierProvider =
    NotifierProvider.autoDispose<
      InterviewSessionNotifier,
      InterviewSessionState
    >(InterviewSessionNotifier.new);

final entitlementNotifierProvider =
    NotifierProvider.autoDispose<EntitlementNotifier, EntitlementState>(
      EntitlementNotifier.new,
    );

abstract base class _LoggedNotifier<State> extends Notifier<State> {
  void registerDispose(String label) {
    final log = ref.read(providerDisposalLogProvider);
    ref.onDispose(() => log.add(label));
  }
}

@Riverpod(keepAlive: false)
final class ProfileNotifier extends _LoggedNotifier<ProfileState> {
  @override
  ProfileState build() {
    registerDispose('profile');
    return const ProfileState.empty();
  }
}

@Riverpod(keepAlive: false)
final class CorpusSearchNotifier extends _LoggedNotifier<CorpusSearchState> {
  @override
  CorpusSearchState build() {
    registerDispose('corpus_search');
    return const CorpusSearchState.empty();
  }
}

@Riverpod(keepAlive: false)
final class InterviewSessionNotifier
    extends _LoggedNotifier<InterviewSessionState> {
  @override
  InterviewSessionState build() {
    registerDispose('interview_session');
    return const InterviewSessionState.empty();
  }
}

@Riverpod(keepAlive: false)
final class EntitlementNotifier extends _LoggedNotifier<EntitlementState> {
  @override
  EntitlementState build() {
    ref.watch(entitlementPolicyProvider);
    registerDispose('entitlement');
    return const EntitlementState.empty();
  }
}
