import 'dart:collection';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as backend;
import 'package:caliber_shared/caliber_shared.dart' as schema;

const kCalibrationRoutingPolicyVersion = 'backend_calibration_route.v1';

final class CalibrationPolicyTuple {
  const CalibrationPolicyTuple({
    required this.corpusBundleVersion,
    required this.rubricVersion,
    required this.promptVersion,
    required this.modelPin,
    required this.schemaVersion,
    required this.routingPolicyVersion,
  });

  factory CalibrationPolicyTuple.forBackend({
    required String modelPin,
    String schemaVersion = schema.kInterviewContentJudgmentSchemaVersion,
  }) {
    return CalibrationPolicyTuple(
      corpusBundleVersion: backend.kBackendDepthCorpusBundleVersion,
      rubricVersion: backend.kBackendDepthRubricVersion,
      promptVersion: backend.kBackendDepthPromptVersion,
      modelPin: modelPin,
      schemaVersion: schemaVersion,
      routingPolicyVersion: kCalibrationRoutingPolicyVersion,
    );
  }

  factory CalibrationPolicyTuple.fromJudgment(
    schema.InterviewContentJudgment judgment,
  ) {
    final metadata = judgment.evidenceSpans.isEmpty
        ? const <String, Object?>{}
        : judgment.evidenceSpans.first.metadata;
    final rawPolicy = metadata['policy_tuple'];
    if (rawPolicy is Map<Object?, Object?>) {
      return CalibrationPolicyTuple(
        corpusBundleVersion:
            rawPolicy['corpus_bundle_version'] as String? ??
            backend.kBackendDepthCorpusBundleVersion,
        rubricVersion:
            rawPolicy['rubric_version'] as String? ?? judgment.rubricVersion,
        promptVersion:
            rawPolicy['prompt_version'] as String? ?? judgment.promptVersion,
        modelPin: rawPolicy['model_pin'] as String? ?? judgment.modelId,
        schemaVersion:
            rawPolicy['schema_version'] as String? ?? judgment.schemaVersion,
        routingPolicyVersion:
            rawPolicy['routing_policy_version'] as String? ??
            kCalibrationRoutingPolicyVersion,
      );
    }
    return CalibrationPolicyTuple(
      corpusBundleVersion:
          metadata['corpus_bundle_version'] as String? ??
          backend.kBackendDepthCorpusBundleVersion,
      rubricVersion: judgment.rubricVersion,
      promptVersion: judgment.promptVersion,
      modelPin: judgment.modelId,
      schemaVersion: judgment.schemaVersion,
      routingPolicyVersion: kCalibrationRoutingPolicyVersion,
    );
  }

  final String corpusBundleVersion;
  final String rubricVersion;
  final String promptVersion;
  final String modelPin;
  final String schemaVersion;
  final String routingPolicyVersion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'corpus_bundle_version': corpusBundleVersion,
      'rubric_version': rubricVersion,
      'prompt_version': promptVersion,
      'model_pin': modelPin,
      'schema_version': schemaVersion,
      'routing_policy_version': routingPolicyVersion,
    };
  }
}

Map<String, Object?> policyTupleMetadata(CalibrationPolicyTuple policy) {
  return <String, Object?>{
    'corpus_bundle_version': policy.corpusBundleVersion,
    'policy_tuple': policy.toJson(),
  };
}

final class CalibrationLoopLogEvent {
  const CalibrationLoopLogEvent({
    required this.event,
    required this.questionId,
    required this.corpusBundleVersion,
    required this.rubricVersion,
    required this.schemaVersion,
    required this.modelPinHash,
    required this.answerHash,
    required this.attempts,
    required this.cacheStatus,
  });

  final String event;
  final String questionId;
  final String corpusBundleVersion;
  final String rubricVersion;
  final String schemaVersion;
  final String modelPinHash;
  final String answerHash;
  final int attempts;
  final String cacheStatus;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'event': event,
      'question_id': questionId,
      'corpus_bundle_version': corpusBundleVersion,
      'rubric_version': rubricVersion,
      'schema_version': schemaVersion,
      'model_pin_hash': modelPinHash,
      'answer_hash': answerHash,
      'attempts': attempts,
      'cache_status': cacheStatus,
    };
  }
}

abstract interface class CalibrationLoopLogger {
  void record(CalibrationLoopLogEvent event);
}

final class InMemoryCalibrationLoopLogger implements CalibrationLoopLogger {
  final List<CalibrationLoopLogEvent> _events = <CalibrationLoopLogEvent>[];

  UnmodifiableListView<CalibrationLoopLogEvent> get events {
    return UnmodifiableListView<CalibrationLoopLogEvent>(_events);
  }

  @override
  void record(CalibrationLoopLogEvent event) {
    _events.add(event);
  }
}

String stableHashForLog(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
