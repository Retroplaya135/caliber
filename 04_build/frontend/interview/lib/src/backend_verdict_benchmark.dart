import 'dart:convert';
import 'dart:io';

import 'interview_question.dart';
import 'interview_round.dart';

final class BackendBenchmarkSeedAnswer {
  const BackendBenchmarkSeedAnswer({
    required this.answerId,
    required this.answer,
    this.question = kSeedBackendPracticeQuestion,
  });

  final String answerId;
  final InterviewPracticeQuestion question;
  final String answer;
}

const kBackendBenchmarkSeedAnswers = <BackendBenchmarkSeedAnswer>[
  BackendBenchmarkSeedAnswer(
    answerId: 'backend_rate_limiter_l5_seed_strong_001',
    answer:
        'I would start by defining tenant quotas, burst policy, and latency budget before picking storage. '
        'For most public API endpoints I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
        'The tradeoff versus a sliding window is less exact fairness, so I would use sliding windows only for abuse-sensitive endpoints. '
        'For failure modes, login fails closed after a short timeout, while read-only traffic can fail open with sampling and alerts. '
        'I would roll out in shadow mode, publish the quota contract to producer teams, and measure p95 latency, reject rate, hot keys, and rollback triggers.',
  ),
  BackendBenchmarkSeedAnswer(
    answerId: 'backend_rate_limiter_downlevel_seed_001',
    answer:
        'I would use Redis and increment a counter for each user. If the counter is too high, reject the request. '
        'Redis is fast and common for this kind of problem.',
  ),
];

Future<List<Map<String, Object?>>> buildBackendVerdictBenchmarkRows({
  Iterable<BackendBenchmarkSeedAnswer> seedAnswers =
      kBackendBenchmarkSeedAnswers,
  InterviewRoundFn runRound = runInterviewRound,
  int? limit,
}) async {
  final selected = limit == null ? seedAnswers : seedAnswers.take(limit);
  final rows = <Map<String, Object?>>[];
  for (final seed in selected) {
    final judgment = await runRound(seed.question, seed.answer);
    rows.add(<String, Object?>{
      'answer_id': seed.answerId,
      'question_id': seed.question.questionId,
      'rubric_version': judgment.rubricVersion,
      'prompt_version': judgment.promptVersion,
      'model_id': judgment.modelId,
      'level_read': judgment.levelBand,
      'strengths': judgment.strengths,
      'risks': judgment.risks,
      'recommended_actions': judgment.recommendedActions,
      'evidence': <Map<String, Object?>>[
        for (final span in judgment.evidenceSpans)
          <String, Object?>{
            'criterion_id': span.metadata['criterion_id'],
            'criterion_label': span.metadata['criterion_label'],
            'level_signal': span.metadata['level_signal'],
            'quote': span.quote,
            'start_offset': span.startOffset,
            'end_offset': span.endOffset,
            'minimum_fix': span.metadata['minimum_fix'],
            'down_level_reason': span.metadata['down_level_reason'],
          },
      ],
      'created_at': judgment.createdAt.toIso8601String(),
    });
  }
  return rows;
}

Future<File> writeBackendVerdictBenchmarkJsonl({
  required File outputFile,
  Iterable<BackendBenchmarkSeedAnswer> seedAnswers =
      kBackendBenchmarkSeedAnswers,
  int? limit,
}) async {
  final rows = await buildBackendVerdictBenchmarkRows(
    seedAnswers: seedAnswers,
    limit: limit,
  );
  await outputFile.parent.create(recursive: true);
  final sink = outputFile.openWrite();
  try {
    for (final row in rows) {
      sink.writeln(jsonEncode(row));
    }
  } finally {
    await sink.close();
  }
  return outputFile;
}
