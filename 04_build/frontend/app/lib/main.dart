import 'dart:async';

import 'package:caliber_app_shell/app_shell.dart' as shell;
import 'package:caliber_app_state/caliber_app_state.dart' as app_state;
import 'package:caliber_auth/auth.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_interview/interview.dart';
import 'package:caliber_screens/screens.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'src/auth_fallback_store.dart';
import 'src/runtime_gateway_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtimeGatewayConfig = await loadRuntimeGatewayConfig();
  final gatewayConfig = runtimeGatewayConfig.gatewayClientConfig;
  runApp(
    ProviderScope(
      overrides: [
        if (gatewayConfig != null)
          app_state.gatewayClientConfigProvider.overrideWithValue(
            gatewayConfig,
          ),
      ],
      child: CaliberApp(
        useGatewayJudge: runtimeGatewayConfig.useGatewayJudge,
        funnelEndpoint: runtimeGatewayConfig.funnelEndpoint,
      ),
    ),
  );
}

final class CaliberApp extends StatefulWidget {
  CaliberApp({
    AuthProvider? authProvider,
    OnboardingPreferences? onboardingPreferences,
    this.useGatewayJudge = false,
    this.funnelEndpoint,
    this.runRoundOverride,
    super.key,
  }) : authProvider = authProvider ?? buildCaliberLocalAuthProvider(),
       onboardingPreferences =
           onboardingPreferences ?? const SharedPrefsOnboardingPreferences();

  final AuthProvider authProvider;
  final OnboardingPreferences onboardingPreferences;
  final bool useGatewayJudge;
  final Uri? funnelEndpoint;
  final InterviewRoundFn? runRoundOverride;

  @override
  State<CaliberApp> createState() => _CaliberAppState();
}

LocalAnonymousAuthProvider buildCaliberLocalAuthProvider() {
  const primary = FlutterAuthSecureStore(
    storage: FlutterSecureStorage(
      mOptions: MacOsOptions(usesDataProtectionKeychain: false),
    ),
  );
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    return LocalAnonymousAuthProvider(
      store: _ResilientMacOsAuthStore(
        primary: primary,
        fallback: buildAuthFallbackStore(),
      ),
    );
  }
  return LocalAnonymousAuthProvider(store: primary);
}

final class _CaliberAppState extends State<CaliberApp> {
  @override
  void dispose() {
    final authProvider = widget.authProvider;
    if (authProvider is LocalAnonymousAuthProvider) {
      authProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caliber',
      theme: CaliberTheme.light(),
      darkTheme: CaliberTheme.dark(),
      home: AuthGate(
        authProvider: widget.authProvider,
        preferences: widget.onboardingPreferences,
        shell: CaliberShellHost(
          authProvider: widget.authProvider,
          useGatewayJudge: widget.useGatewayJudge,
          funnelEndpoint: widget.funnelEndpoint,
          runRoundOverride: widget.runRoundOverride,
        ),
      ),
    );
  }
}

final class CaliberShellHost extends ConsumerWidget {
  const CaliberShellHost({
    required this.authProvider,
    this.useGatewayJudge = false,
    this.funnelEndpoint,
    this.runRoundOverride,
    super.key,
  });

  final AuthProvider authProvider;
  final bool useGatewayJudge;
  final Uri? funnelEndpoint;
  final InterviewRoundFn? runRoundOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<schema.ProfileIdentity?>(
      future: authProvider.currentProfile,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _CaliberRouterHost(
          profile: profile,
          useGatewayJudge: useGatewayJudge,
          funnelEndpoint: funnelEndpoint,
          runRoundOverride: runRoundOverride,
        );
      },
    );
  }
}

final class _CaliberRouterHost extends ConsumerStatefulWidget {
  const _CaliberRouterHost({
    required this.profile,
    required this.useGatewayJudge,
    this.funnelEndpoint,
    this.runRoundOverride,
  });

  final schema.ProfileIdentity profile;
  final bool useGatewayJudge;
  final Uri? funnelEndpoint;
  final InterviewRoundFn? runRoundOverride;

  @override
  ConsumerState<_CaliberRouterHost> createState() => _CaliberRouterHostState();
}

final class _CaliberRouterHostState extends ConsumerState<_CaliberRouterHost> {
  late final DateTime _startedAt = DateTime.now().toUtc();
  late final PersistentPrepBriefEventSink _prepBriefEventSink =
      PersistentPrepBriefEventSink(
        anonProfileId: widget.profile.profileId,
        funnelEndpoint: widget.funnelEndpoint,
      );

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(app_state.profileNotifierProvider)
      ..watch(app_state.corpusSearchNotifierProvider)
      ..watch(app_state.interviewSessionNotifierProvider);

    final schemaPolicy = ref.watch(app_state.entitlementPolicyProvider);
    final entitlementState = ref.watch(app_state.entitlementNotifierProvider);
    final schemaSnapshot =
        entitlementState.snapshot ?? _localStartupEntitlement();
    final interviewFeedbackAccess = _interviewFeedbackAccess(
      schemaPolicy: schemaPolicy,
      schemaSnapshot: schemaSnapshot,
      evaluatedAt: _startedAt,
    );

    final runRound = widget.runRoundOverride ?? _runtimeRunRound();
    final router = shell.buildCaliberRouter(
      serverSnapshot: _toShellSnapshot(schemaSnapshot),
      entitlementPolicy: _SchemaBackedShellEntitlementPolicy(
        schemaPolicy: schemaPolicy,
        schemaSnapshot: schemaSnapshot,
        evaluatedAt: _startedAt,
      ),
      pageBuilder: (context, destination) => buildScreenForDestination(
        context,
        destination,
        interviewFeedbackAccess: interviewFeedbackAccess,
        anonProfileId: widget.profile.profileId,
        prepBriefEventSink: _prepBriefEventSink,
        runRound: runRound,
      ),
    );

    return MaterialApp.router(
      title: 'Caliber',
      theme: CaliberTheme.light(),
      darkTheme: CaliberTheme.dark(),
      routerConfig: router,
    );
  }

  schema.EntitlementSnapshot _localStartupEntitlement() {
    return schema.EntitlementSnapshot(
      userId: widget.profile.ownerUserId,
      status: schema.EntitlementStatus.trial,
      planId: 'anonymous_local_trial',
      sourceLedgerEntryIds: const <String>['local-anonymous-start'],
      effectiveAt: _startedAt,
    );
  }

  InterviewRoundFn? _runtimeRunRound() {
    if (!widget.useGatewayJudge) return null;
    final gatewayClient = ref.read(app_state.gatewayClientProvider);
    return (question, answer) {
      return runInterviewRound(
        question,
        answer,
        judge: GatewayStructuredJudgeAdapter(gatewayClient: gatewayClient),
        profile: widget.profile,
      );
    };
  }
}

final class _SchemaBackedShellEntitlementPolicy
    implements shell.EntitlementPolicy {
  const _SchemaBackedShellEntitlementPolicy({
    required this.schemaPolicy,
    required this.schemaSnapshot,
    required this.evaluatedAt,
  });

  final schema.EntitlementPolicy schemaPolicy;
  final schema.EntitlementSnapshot schemaSnapshot;
  final DateTime evaluatedAt;

  @override
  shell.FeatureGateDecision decide({
    required shell.EntitlementSnapshot serverSnapshot,
    required shell.CaliberFeatureId featureId,
  }) {
    if (shell.caliberFeatureCosts[featureId] ==
        shell.CaliberFeatureCostClass.localFree) {
      return shell.FeatureGateDecision(
        featureId: featureId,
        allowed: true,
        reason: 'local-first feature remains free',
        requiresCredit: false,
      );
    }
    final decision = schemaPolicy.evaluate(
      snapshot: schemaSnapshot,
      featureKey: _featureKeyFor(featureId),
      policyVersion: 'entitlement-policy-v1',
      evaluatedAt: evaluatedAt,
    );
    return shell.FeatureGateDecision(
      featureId: featureId,
      allowed: decision.allowed,
      reason: decision.reasonCode,
      requiresCredit:
          shell.caliberFeatureCosts[featureId] ==
          shell.CaliberFeatureCostClass.serverExpensive,
    );
  }
}

InterviewFeedbackAccess _interviewFeedbackAccess({
  required schema.EntitlementPolicy schemaPolicy,
  required schema.EntitlementSnapshot schemaSnapshot,
  required DateTime evaluatedAt,
}) {
  final decision = schemaPolicy.evaluate(
    snapshot: schemaSnapshot,
    featureKey: 'gateway_interview_eval',
    policyVersion: 'entitlement-policy-v1',
    evaluatedAt: evaluatedAt,
  );
  return decision.allowed
      ? InterviewFeedbackAccess.full
      : InterviewFeedbackAccess.teaser;
}

shell.EntitlementSnapshot _toShellSnapshot(
  schema.EntitlementSnapshot snapshot,
) {
  return shell.EntitlementSnapshot(
    accountId: snapshot.userId,
    state: _toShellEntitlementState(snapshot.status),
    version: snapshot.sourceLedgerEntryIds.length,
    activeProductId: snapshot.planId,
  );
}

shell.EntitlementState _toShellEntitlementState(
  schema.EntitlementStatus status,
) {
  return switch (status) {
    schema.EntitlementStatus.active => shell.EntitlementState.paid,
    schema.EntitlementStatus.grace => shell.EntitlementState.grace,
    schema.EntitlementStatus.trial => shell.EntitlementState.trial,
    schema.EntitlementStatus.expired => shell.EntitlementState.free,
    schema.EntitlementStatus.revoked => shell.EntitlementState.revoked,
  };
}

String _featureKeyFor(shell.CaliberFeatureId featureId) {
  return switch (featureId) {
    shell.CaliberFeatureId.localCorpusSearch => 'local_corpus_search',
    shell.CaliberFeatureId.localDeliveryScore => 'local_delivery_score',
    shell.CaliberFeatureId.localAtsReport => 'local_ats_report',
    shell.CaliberFeatureId.gatewayInterviewEval => 'gateway_interview_eval',
    shell.CaliberFeatureId.cloudStt => 'cloud_stt',
    shell.CaliberFeatureId.resumeRewrite => 'resume_rewrite',
  };
}

final class _ResilientMacOsAuthStore implements AuthSecureStore {
  const _ResilientMacOsAuthStore({
    required this.primary,
    required this.fallback,
  });

  static const _primaryTimeout = Duration(seconds: 2);

  final AuthSecureStore primary;
  final AuthSecureStore fallback;

  @override
  Future<String?> read({required String key}) async {
    try {
      return await primary.read(key: key).timeout(_primaryTimeout);
    } on PlatformException catch (error) {
      if (!isMissingMacOsKeychainEntitlement(error)) {
        rethrow;
      }
      return fallback.read(key: key);
    } on TimeoutException {
      return fallback.read(key: key);
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await primary.write(key: key, value: value).timeout(_primaryTimeout);
    } on PlatformException catch (error) {
      if (!isMissingMacOsKeychainEntitlement(error)) {
        rethrow;
      }
      await fallback.write(key: key, value: value);
    } on TimeoutException {
      await fallback.write(key: key, value: value);
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await primary.delete(key: key).timeout(_primaryTimeout);
    } on PlatformException catch (error) {
      if (!isMissingMacOsKeychainEntitlement(error)) {
        rethrow;
      }
      await fallback.delete(key: key);
    } on TimeoutException {
      await fallback.delete(key: key);
    }
  }
}
