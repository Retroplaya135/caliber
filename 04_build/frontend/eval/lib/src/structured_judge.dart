import 'dart:collection';

import 'package:caliber_eval_backend/caliber_eval_backend.dart';

import 'interview_models.dart';

final _routeHashPattern = RegExp(r'^[0-9a-f]{64}$');

abstract interface class StructuredJudge {
  Future<InterviewContentJudgment> judgeInterviewContent(
      StructuredJudgeRequest request);
}

final class StructuredJudgeRequest {
  StructuredJudgeRequest({
    required this.answerId,
    required this.questionId,
    required this.normalizedAnswer,
    required this.schemaVersion,
    required this.rubricVersion,
    required this.promptVersion,
    required this.corpusBundleVersion,
    required this.routingPolicyVersion,
    required this.routeHash,
    required Iterable<RetrievedCorpusRecord> fixedCorpusSubset,
  }) : fixedCorpusSubset = UnmodifiableListView<RetrievedCorpusRecord>(
            fixedCorpusSubset.toList()) {
    _checkNotEmpty(answerId, 'answerId');
    _checkNotEmpty(questionId, 'questionId');
    _checkNotEmpty(normalizedAnswer, 'normalizedAnswer');
    _checkNotEmpty(schemaVersion, 'schemaVersion');
    _checkNotEmpty(rubricVersion, 'rubricVersion');
    _checkNotEmpty(promptVersion, 'promptVersion');
    _checkNotEmpty(corpusBundleVersion, 'corpusBundleVersion');
    _checkNotEmpty(routingPolicyVersion, 'routingPolicyVersion');
    if (!_routeHashPattern.hasMatch(routeHash)) {
      throw ArgumentError.value(
          routeHash, 'routeHash', 'must be 64 lowercase hex characters');
    }
    if (this.fixedCorpusSubset.isEmpty) {
      throw ArgumentError.value(
          fixedCorpusSubset, 'fixedCorpusSubset', 'must not be empty');
    }
  }

  final String answerId;
  final String questionId;
  final String normalizedAnswer;
  final String schemaVersion;
  final String rubricVersion;
  final String promptVersion;
  final String corpusBundleVersion;
  final String routingPolicyVersion;
  final String routeHash;
  final UnmodifiableListView<RetrievedCorpusRecord> fixedCorpusSubset;
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
