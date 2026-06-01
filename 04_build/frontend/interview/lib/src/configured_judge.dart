import 'package:caliber_gateway_client/caliber_gateway_client.dart';
import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'environment_values.dart';
import 'gateway_structured_judge_adapter.dart';
import 'local_structured_judge.dart';

enum InterviewJudgeMode { local, gateway }

InterviewJudgeMode interviewJudgeModeFromEnvironment({
  Map<String, String>? environment,
}) {
  final value = (environment ?? environmentValues())['CALIBER_INTERVIEW_JUDGE'];
  return switch (value?.trim().toLowerCase()) {
    'gateway' || 'remote' => InterviewJudgeMode.gateway,
    _ => InterviewJudgeMode.local,
  };
}

schema.StructuredJudge buildConfiguredStructuredJudge({
  Map<String, String>? environment,
  DateTime Function()? clock,
}) {
  final values = environment ?? environmentValues();
  return switch (interviewJudgeModeFromEnvironment(environment: values)) {
    InterviewJudgeMode.local => LocalDeterministicStructuredJudge(),
    InterviewJudgeMode.gateway => GatewayStructuredJudgeAdapter(
      gatewayClient: GatewayClient(
        config: GatewayClientConfig.fromEnvironment(environment: values),
      ),
      clock: clock,
    ),
  };
}
