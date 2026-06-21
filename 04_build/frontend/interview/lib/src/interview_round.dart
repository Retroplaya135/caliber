import 'package:caliber_shared/caliber_shared.dart' as schema;

import 'calibration_policy.dart';
import 'configured_judge.dart';
import 'interview_question.dart';

typedef InterviewRoundFn =
    Future<schema.InterviewContentJudgment> Function(
      InterviewPracticeQuestion question,
      String answer,
    );

Future<schema.InterviewContentJudgment> runInterviewRound(
  InterviewPracticeQuestion question,
  String answer, {
  schema.StructuredJudge? judge,
  schema.ProfileIdentity? profile,
  CalibrationLoopLogger? logger,
  DateTime? now,
}) {
  final runner = InterviewRoundRunner(
    judge: judge ?? buildConfiguredStructuredJudge(),
    profile: profile ?? _seedProfile(now ?? DateTime.now().toUtc()),
    logger: logger,
    now: now ?? DateTime.now().toUtc(),
  );
  return runner.run(question, answer);
}

final class InterviewRoundRunner {
  const InterviewRoundRunner({
    required this.judge,
    required this.profile,
    this.logger,
    required this.now,
  });

  final schema.StructuredJudge judge;
  final schema.ProfileIdentity profile;
  final CalibrationLoopLogger? logger;
  final DateTime now;

  Future<schema.InterviewContentJudgment> run(
    InterviewPracticeQuestion question,
    String answer,
  ) async {
    final normalized = answer.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(answer, 'answer', 'must not be empty');
    }
    final transcript = _transcriptFromAnswer(
      question: question,
      answer: normalized,
      recordedAt: now,
    );
    final judgment = await judge.judgeInterviewContent(
      profile: profile,
      target: question.target,
      transcript: transcript,
      questionId: question.questionId,
      rubricVersion: question.rubricVersion,
      promptVersion: question.promptVersion,
    );
    logger?.record(
      CalibrationLoopLogEvent(
        event: 'calibration_verdict_completed',
        questionId: question.questionId,
        corpusBundleVersion: CalibrationPolicyTuple.fromJudgment(
          judgment,
        ).corpusBundleVersion,
        rubricVersion: judgment.rubricVersion,
        schemaVersion: judgment.schemaVersion,
        modelPinHash: stableHashForLog(judgment.modelId),
        answerHash: stableHashForLog(normalized),
        attempts: 1,
        cacheStatus: 'gateway_or_local_cache_opaque',
      ),
    );
    return judgment;
  }
}

schema.ProfileIdentity _seedProfile(DateTime now) {
  return schema.ProfileIdentity(
    profileId: 'seed-local-practice-profile',
    ownerUserId: 'anonymous:local-practice',
    displayName: 'Local Candidate',
    primaryDomain: 'Backend',
    targetLevelBand: 'L5/L6',
    locale: 'en-US',
    createdAt: now,
    updatedAt: now,
    metadata: const <String, Object?>{'source': 'block_3_seed'},
  );
}

schema.Transcript _transcriptFromAnswer({
  required InterviewPracticeQuestion question,
  required String answer,
  required DateTime recordedAt,
}) {
  final words = RegExp(r"\S+").allMatches(answer).toList(growable: false);
  final durationMs = (words.length * 420).clamp(1200, 120000).toInt();
  final transcriptId = 'answer_${question.questionId}_${_fingerprint(answer)}';
  return schema.Transcript(
    transcriptId: transcriptId,
    segments: <schema.TranscriptSegment>[
      schema.TranscriptSegment(
        segmentId: '$transcriptId:segment:0',
        speakerLabel: 'candidate',
        startMs: 0,
        endMs: durationMs,
        text: answer,
        wordIds: <String>[
          for (var index = 0; index < words.length; index += 1)
            '$transcriptId:word:$index',
        ],
      ),
    ],
    words: <schema.TranscriptWord>[
      for (var index = 0; index < words.length; index += 1)
        schema.TranscriptWord(
          wordId: '$transcriptId:word:$index',
          segmentId: '$transcriptId:segment:0',
          text: words[index].group(0)!,
          startMs: index * 420,
          endMs: (index + 1) * 420,
        ),
    ],
    engineId: 'typed-answer',
    engineVersion: 'typed-answer.v1',
    glossaryHits: <schema.GlossaryHit>[
      for (final term in question.glossary)
        if (answer.toLowerCase().contains(term.toLowerCase()))
          schema.GlossaryHit(
            term: term,
            normalizedTerm: term.toLowerCase(),
            source: 'seed_glossary',
          ),
    ],
    transcriptPolicyVersion: 'typed_interview_answer.v1',
    locale: 'en-US',
    recordedAt: recordedAt,
    sourceUri: 'typed://interview/${question.questionId}',
    durationMs: durationMs,
  );
}

String _fingerprint(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
