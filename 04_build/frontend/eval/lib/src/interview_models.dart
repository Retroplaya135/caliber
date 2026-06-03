import 'dart:collection';

import 'package:caliber_eval_backend/caliber_eval_backend.dart';

import 'interview_delivery_profile.dart';

final _routeHashPattern = RegExp(r'^[0-9a-f]{64}$');

final class TranscriptSegment {
  TranscriptSegment({
    required this.segmentId,
    required this.text,
    required this.startMillis,
    required this.endMillis,
  }) {
    _checkNotEmpty(segmentId, 'segmentId');
    _checkNotEmpty(text, 'text');
    if (startMillis < 0) {
      throw ArgumentError.value(
        startMillis,
        'startMillis',
        'must be non-negative',
      );
    }
    if (endMillis <= startMillis) {
      throw ArgumentError.value(
        endMillis,
        'endMillis',
        'must be greater than startMillis',
      );
    }
  }

  final String segmentId;
  final String text;
  final int startMillis;
  final int endMillis;
}

final class InterviewAnswer {
  InterviewAnswer({
    required this.answerId,
    required this.userId,
    required this.questionId,
    required this.roleId,
    required this.domain,
    required this.levelBand,
    required this.companyArchetype,
    required Iterable<TranscriptSegment> segments,
  }) : segments = UnmodifiableListView<TranscriptSegment>(segments.toList()) {
    _checkNotEmpty(answerId, 'answerId');
    _checkNotEmpty(userId, 'userId');
    _checkNotEmpty(questionId, 'questionId');
    _checkNotEmpty(roleId, 'roleId');
    _checkNotEmpty(domain, 'domain');
    _checkNotEmpty(levelBand, 'levelBand');
    _checkNotEmpty(companyArchetype, 'companyArchetype');
    if (this.segments.isEmpty) {
      throw ArgumentError.value(segments, 'segments', 'must not be empty');
    }
    for (var index = 1; index < this.segments.length; index += 1) {
      if (this.segments[index].startMillis <
          this.segments[index - 1].endMillis) {
        throw ArgumentError.value(
          this.segments[index].segmentId,
          'segments',
          'must be chronological and non-overlapping',
        );
      }
    }
  }

  final String answerId;
  final String userId;
  final String questionId;
  final String roleId;
  final String domain;
  final String levelBand;
  final String companyArchetype;
  final UnmodifiableListView<TranscriptSegment> segments;

  String get normalizedText {
    final joined = segments
        .map((segment) => segment.text.trim())
        .where((text) => text.isNotEmpty)
        .join(' ');
    return joined.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  int get durationMillis =>
      segments.last.endMillis - segments.first.startMillis;
}

final class InterviewContentJudgment {
  InterviewContentJudgment({
    required this.judgmentId,
    required this.answerId,
    required this.schemaVersion,
    required this.promptVersion,
    required this.corpusBundleVersion,
    required this.routingPolicyVersion,
    required this.modelId,
    required this.routeHash,
    required this.band,
    String? levelRead,
    required this.summary,
    required Iterable<String> strengths,
    required Iterable<String> gaps,
    Iterable<String> recommendedActions = const <String>[],
    required Iterable<CorpusEvidenceSpan> evidenceSpans,
    Iterable<Map<String, Object?>> evidenceMetadata =
        const <Map<String, Object?>>[],
  }) : levelRead = levelRead ?? band,
       strengths = UnmodifiableListView<String>(strengths.toList()),
       gaps = UnmodifiableListView<String>(gaps.toList()),
       recommendedActions = UnmodifiableListView<String>(
         recommendedActions.toList(),
       ),
       evidenceSpans = UnmodifiableListView<CorpusEvidenceSpan>(
         evidenceSpans.toList(),
       ),
       evidenceMetadata = UnmodifiableListView<Map<String, Object?>>(
         evidenceMetadata
             .map(
               (item) => UnmodifiableMapView<String, Object?>(
                 Map<String, Object?>.of(item),
               ),
             )
             .toList(),
       ) {
    _checkNotEmpty(judgmentId, 'judgmentId');
    _checkNotEmpty(answerId, 'answerId');
    _checkNotEmpty(schemaVersion, 'schemaVersion');
    _checkNotEmpty(promptVersion, 'promptVersion');
    _checkNotEmpty(corpusBundleVersion, 'corpusBundleVersion');
    _checkNotEmpty(routingPolicyVersion, 'routingPolicyVersion');
    _checkNotEmpty(modelId, 'modelId');
    _checkNotEmpty(this.levelRead, 'levelRead');
    _checkNotEmpty(summary, 'summary');
    _checkNotEmptyItems(this.strengths, 'strengths');
    _checkNotEmptyItems(this.gaps, 'gaps');
    for (final value in this.recommendedActions) {
      if (value.trim().isEmpty) {
        throw ArgumentError.value(
          recommendedActions,
          'recommendedActions',
          'must not contain empty items',
        );
      }
    }
    if (!_routeHashPattern.hasMatch(routeHash)) {
      throw ArgumentError.value(
        routeHash,
        'routeHash',
        'must be 64 lowercase hex characters',
      );
    }
    if (this.evidenceSpans.isEmpty) {
      throw ArgumentError.value(
        evidenceSpans,
        'evidenceSpans',
        'must not be empty',
      );
    }
    if (this.evidenceMetadata.isNotEmpty &&
        this.evidenceMetadata.length != this.evidenceSpans.length) {
      throw ArgumentError.value(
        evidenceMetadata,
        'evidenceMetadata',
        'must be empty or match evidenceSpans length',
      );
    }
    if (!const <String>{
      'emerging',
      'solid',
      'strong',
      'exceptional',
      'below_bar',
      'approaching',
      'at_bar',
      'above_bar',
    }.contains(band)) {
      throw ArgumentError.value(band, 'band', 'unknown judgment band');
    }
  }

  final String judgmentId;
  final String answerId;
  final String schemaVersion;
  final String promptVersion;
  final String corpusBundleVersion;
  final String routingPolicyVersion;
  final String modelId;
  final String routeHash;
  final String band;
  final String levelRead;
  final String summary;
  final UnmodifiableListView<String> strengths;
  final UnmodifiableListView<String> gaps;
  final UnmodifiableListView<String> recommendedActions;
  final UnmodifiableListView<CorpusEvidenceSpan> evidenceSpans;
  final UnmodifiableListView<Map<String, Object?>> evidenceMetadata;
}

final class InterviewEvaluation {
  const InterviewEvaluation({
    required this.answer,
    required this.corpus,
    required this.contentJudgment,
    required this.deliveryProfile,
    required this.renderedJudgment,
  });

  final InterviewAnswer answer;
  final CorpusRetrievalResult corpus;
  final InterviewContentJudgment contentJudgment;
  final InterviewDeliveryProfile deliveryProfile;
  final String renderedJudgment;
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}

void _checkNotEmptyItems(Iterable<String> values, String name) {
  if (values.isEmpty) {
    throw ArgumentError.value(values, name, 'must not be empty');
  }
  for (final value in values) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'must not contain empty items');
    }
  }
}
