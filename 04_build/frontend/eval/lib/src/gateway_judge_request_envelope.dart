import 'dart:collection';

import 'package:caliber_eval_backend/caliber_eval_backend.dart';

import 'structured_judge.dart';

final class GatewayJudgeRequestEnvelope {
  GatewayJudgeRequestEnvelope({
    required this.schemaVersion,
    required this.promptVersion,
    required this.corpusBundleVersion,
    required this.routingPolicyVersion,
    required this.role,
    required this.answer,
    required Map<String, Object?> rubric,
    required Iterable<GatewayEvidenceInput> evidence,
    Map<String, Object?> userContext = const <String, Object?>{},
  })  : rubric = UnmodifiableMapView<String, Object?>(
          Map<String, Object?>.of(rubric),
        ),
        evidence = UnmodifiableListView<GatewayEvidenceInput>(
          evidence.toList(),
        ),
        userContext = UnmodifiableMapView<String, Object?>(
          Map<String, Object?>.of(userContext),
        ) {
    if (role.trim().isEmpty) {
      throw ArgumentError.value(role, 'role', 'must not be empty');
    }
    if (answer.trim().isEmpty) {
      throw ArgumentError.value(answer, 'answer', 'must not be empty');
    }
    if (this.evidence.isEmpty) {
      throw ArgumentError.value(evidence, 'evidence', 'must not be empty');
    }
  }

  factory GatewayJudgeRequestEnvelope.fromStructuredJudgeRequest(
    StructuredJudgeRequest request, {
    required String role,
    Map<String, Object?> userContext = const <String, Object?>{},
  }) {
    return GatewayJudgeRequestEnvelope(
      schemaVersion: request.schemaVersion,
      promptVersion: request.promptVersion,
      corpusBundleVersion: request.corpusBundleVersion,
      routingPolicyVersion: request.routingPolicyVersion,
      role: role,
      answer: request.normalizedAnswer,
      rubric: _rubricFrom(request),
      evidence: _evidenceFrom(request.fixedCorpusSubset),
      userContext: userContext,
    );
  }

  final String schemaVersion;
  final String promptVersion;
  final String corpusBundleVersion;
  final String routingPolicyVersion;
  final String role;
  final String answer;
  final UnmodifiableMapView<String, Object?> rubric;
  final UnmodifiableListView<GatewayEvidenceInput> evidence;
  final UnmodifiableMapView<String, Object?> userContext;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'schema_version': schemaVersion,
      'prompt_version': promptVersion,
      'corpus_bundle_version': corpusBundleVersion,
      'routing_policy_version': routingPolicyVersion,
      'feature': 'interview_content',
      'role': role,
      'rubric': rubric,
      'answer': answer,
      'evidence': evidence.map((item) => item.toJson()).toList(),
      'user_context': userContext,
    };
  }
}

final class GatewayEvidenceInput {
  GatewayEvidenceInput({
    required this.sourceId,
    required this.start,
    required this.end,
    required this.text,
  }) {
    if (sourceId.trim().isEmpty) {
      throw ArgumentError.value(sourceId, 'sourceId', 'must not be empty');
    }
    if (start < 0) {
      throw ArgumentError.value(start, 'start', 'must be non-negative');
    }
    if (end <= start) {
      throw ArgumentError.value(end, 'end', 'must be greater than start');
    }
    if (text.trim().isEmpty) {
      throw ArgumentError.value(text, 'text', 'must not be empty');
    }
  }

  final String sourceId;
  final int start;
  final int end;
  final String text;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'source_id': sourceId,
      'start': start,
      'end': end,
      'text': text,
    };
  }
}

Map<String, Object?> _rubricFrom(StructuredJudgeRequest request) {
  return <String, Object?>{
    'answer_id': request.answerId,
    'question_id': request.questionId,
    'rubric_version': request.rubricVersion,
    'route_hash': request.routeHash,
    'corpus_bundle_version': request.corpusBundleVersion,
    'records': <Map<String, Object?>>[
      for (final retrieved in request.fixedCorpusSubset)
        _recordToRubricJson(retrieved.record, retrieved.score),
    ],
    'rubric_slices': <Map<String, Object?>>[
      for (final retrieved in request.fixedCorpusSubset)
        if (retrieved.record.kind == CorpusRecordKind.rubricSlice)
          _recordToRubricJson(retrieved.record, retrieved.score),
    ],
  };
}

Map<String, Object?> _recordToRubricJson(CorpusRecord record, double score) {
  return <String, Object?>{
    'record_id': record.recordId,
    'kind': _kindToWire(record.kind),
    'title': record.title,
    'body': record.body,
    'score': double.parse(score.toStringAsFixed(6)),
    'tags': record.tags.toList(),
  };
}

List<GatewayEvidenceInput> _evidenceFrom(
  Iterable<RetrievedCorpusRecord> records,
) {
  return <GatewayEvidenceInput>[
    for (final record in records)
      for (final span in record.evidenceSpans)
        GatewayEvidenceInput(
          sourceId: span.recordId,
          start: span.startOffset,
          end: span.endOffset,
          text: span.text,
        ),
  ];
}

String _kindToWire(CorpusRecordKind kind) {
  return switch (kind) {
    CorpusRecordKind.rubricSlice => 'rubric_slice',
    CorpusRecordKind.benchmarkAnswer => 'benchmark_answer',
    CorpusRecordKind.glossaryTerm => 'glossary_term',
  };
}
