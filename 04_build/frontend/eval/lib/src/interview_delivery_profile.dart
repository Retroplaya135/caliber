import 'interview_models.dart';

final class InterviewDeliveryProfile {
  InterviewDeliveryProfile({
    required this.answerId,
    required this.wordsPerMinute,
    required this.pauseCount,
    required this.fillerRatio,
    required this.durationMillis,
  }) {
    if (answerId.trim().isEmpty) {
      throw ArgumentError.value(answerId, 'answerId', 'must not be empty');
    }
    if (wordsPerMinute < 0) {
      throw ArgumentError.value(
          wordsPerMinute, 'wordsPerMinute', 'must be non-negative');
    }
    if (pauseCount < 0) {
      throw ArgumentError.value(
          pauseCount, 'pauseCount', 'must be non-negative');
    }
    if (fillerRatio < 0 || fillerRatio > 1) {
      throw ArgumentError.value(
          fillerRatio, 'fillerRatio', 'must be between 0 and 1');
    }
    if (durationMillis <= 0) {
      throw ArgumentError.value(
          durationMillis, 'durationMillis', 'must be positive');
    }
  }

  final String answerId;
  final double wordsPerMinute;
  final int pauseCount;
  final double fillerRatio;
  final int durationMillis;
}

final class InterviewDeliveryProfiler {
  static const _fillers = <String>{'um', 'uh', 'like', 'basically', 'actually'};

  InterviewDeliveryProfile profile(InterviewAnswer answer) {
    final words = RegExp(r'[A-Za-z0-9]+')
        .allMatches(answer.normalizedText.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();
    final durationMinutes =
        answer.durationMillis <= 0 ? 1 / 60 : answer.durationMillis / 60000;
    final pauseCount = _pauseCount(answer);
    final fillerCount = words.where(_fillers.contains).length;
    return InterviewDeliveryProfile(
      answerId: answer.answerId,
      wordsPerMinute:
          double.parse((words.length / durationMinutes).toStringAsFixed(2)),
      pauseCount: pauseCount,
      fillerRatio: words.isEmpty
          ? 0
          : double.parse((fillerCount / words.length).toStringAsFixed(4)),
      durationMillis: answer.durationMillis,
    );
  }

  int _pauseCount(InterviewAnswer answer) {
    var pauses = 0;
    for (var index = 1; index < answer.segments.length; index += 1) {
      final gap = answer.segments[index].startMillis -
          answer.segments[index - 1].endMillis;
      if (gap >= 900) pauses += 1;
    }
    return pauses;
  }
}
