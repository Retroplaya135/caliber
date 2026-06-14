import 'interview_delivery_profile.dart';
import 'interview_models.dart';

final class JudgmentRenderer {
  String render(InterviewContentJudgment judgment,
      InterviewDeliveryProfile deliveryProfile) {
    final buffer = StringBuffer()
      ..writeln('# Interview Judgment')
      ..writeln()
      ..writeln('- Band: ${judgment.band}')
      ..writeln('- Schema: ${judgment.schemaVersion}')
      ..writeln('- Corpus: ${judgment.corpusBundleVersion}')
      ..writeln('- Route: ${judgment.routeHash}')
      ..writeln('- Delivery: ${deliveryProfile.wordsPerMinute} wpm, '
          '${deliveryProfile.pauseCount} pauses, '
          '${deliveryProfile.fillerRatio} filler ratio')
      ..writeln()
      ..writeln('## Summary')
      ..writeln(judgment.summary)
      ..writeln()
      ..writeln('## Strengths');
    for (final strength in judgment.strengths) {
      buffer.writeln('- $strength');
    }
    buffer
      ..writeln()
      ..writeln('## Gaps');
    for (final gap in judgment.gaps) {
      buffer.writeln('- $gap');
    }
    buffer
      ..writeln()
      ..writeln('## Evidence');
    for (final span in judgment.evidenceSpans) {
      buffer.writeln(
          '- ${span.recordId} [${span.startOffset}-${span.endOffset}]: ${span.text}');
    }
    return buffer.toString().trimRight();
  }
}
