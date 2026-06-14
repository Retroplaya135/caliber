import 'dart:collection';

final class RubricScenario {
  RubricScenario({
    required this.questionId,
    required this.title,
    required this.prompt,
    required Iterable<RubricCriterion> criteria,
  }) : criteria = UnmodifiableListView<RubricCriterion>(criteria.toList()) {
    _checkNotEmpty(questionId, 'questionId');
    _checkNotEmpty(title, 'title');
    _checkNotEmpty(prompt, 'prompt');
    if (this.criteria.isEmpty) {
      throw ArgumentError.value(criteria, 'criteria', 'must not be empty');
    }
  }

  final String questionId;
  final String title;
  final String prompt;
  final UnmodifiableListView<RubricCriterion> criteria;
}

final class RubricCriterion {
  RubricCriterion({
    required this.criterionId,
    required this.label,
    required this.judgmentFocus,
    required this.l5Anchor,
    required this.l6Anchor,
    required Iterable<String> downLevelSignals,
    required Iterable<String> expectedSignals,
    required Iterable<String> advancedSignals,
    required this.minimumFix,
  }) : downLevelSignals = UnmodifiableListView<String>(
         _cleanItems(downLevelSignals),
       ),
       expectedSignals = UnmodifiableListView<String>(
         _cleanItems(expectedSignals),
       ),
       advancedSignals = UnmodifiableListView<String>(
         _cleanItems(advancedSignals),
       ) {
    _checkNotEmpty(criterionId, 'criterionId');
    _checkNotEmpty(label, 'label');
    _checkNotEmpty(judgmentFocus, 'judgmentFocus');
    _checkNotEmpty(l5Anchor, 'l5Anchor');
    _checkNotEmpty(l6Anchor, 'l6Anchor');
    _checkNotEmpty(minimumFix, 'minimumFix');
    if (this.downLevelSignals.isEmpty) {
      throw ArgumentError.value(
        downLevelSignals,
        'downLevelSignals',
        'must not be empty',
      );
    }
    if (this.expectedSignals.isEmpty) {
      throw ArgumentError.value(
        expectedSignals,
        'expectedSignals',
        'must not be empty',
      );
    }
  }

  final String criterionId;
  final String label;
  final String judgmentFocus;
  final String l5Anchor;
  final String l6Anchor;
  final UnmodifiableListView<String> downLevelSignals;
  final UnmodifiableListView<String> expectedSignals;
  final UnmodifiableListView<String> advancedSignals;
  final String minimumFix;
}

final class RubricMappedVerdict {
  const RubricMappedVerdict({
    required this.rubricVersion,
    required this.promptVersion,
    required this.levelRead,
    required this.levelReason,
    required this.findings,
    required this.deliveryStrengths,
    required this.deliveryRisks,
    required this.deliveryFixes,
  });

  final String rubricVersion;
  final String promptVersion;
  final String levelRead;
  final String levelReason;
  final List<RubricCriterionVerdict> findings;
  final List<String> deliveryStrengths;
  final List<String> deliveryRisks;
  final List<String> deliveryFixes;

  List<String> get contentStrengths {
    return <String>[
      'Level read: $levelRead, because $levelReason.',
      for (final finding in findings)
        if (finding.levelSignal == RubricLevelSignal.l5 ||
            finding.levelSignal == RubricLevelSignal.l6)
          '[${finding.criterionId}] ${finding.finding}',
    ];
  }

  List<String> get contentRisks {
    return <String>[
      for (final finding in findings)
        if (finding.levelSignal == RubricLevelSignal.downLevel ||
            finding.levelSignal == RubricLevelSignal.partial)
          '[${finding.criterionId}] ${finding.downLevelReason} Minimum fix: ${finding.minimumFix}',
    ];
  }

  List<String> get recommendedActions {
    for (final finding in findings) {
      if (finding.levelSignal == RubricLevelSignal.downLevel ||
          finding.levelSignal == RubricLevelSignal.partial) {
        return <String>[
          'Content: [${finding.criterionId}] ${finding.minimumFix}',
        ];
      }
    }
    if (deliveryFixes.isNotEmpty) {
      return <String>['Delivery: ${deliveryFixes.first}'];
    }
    return const <String>[
      'Next pass: answer the same scenario again and preserve the rubric-visible evidence trail.',
    ];
  }
}

enum RubricLevelSignal { downLevel, partial, l5, l6 }

final class RubricCriterionVerdict {
  const RubricCriterionVerdict({
    required this.criterionId,
    required this.label,
    required this.levelSignal,
    required this.finding,
    required this.downLevelReason,
    required this.minimumFix,
    required this.quote,
    required this.startOffset,
    required this.endOffset,
    required this.matchedSignals,
  });

  final String criterionId;
  final String label;
  final RubricLevelSignal levelSignal;
  final String finding;
  final String downLevelReason;
  final String minimumFix;
  final String quote;
  final int startOffset;
  final int endOffset;
  final List<String> matchedSignals;
}

final class DeterministicRubricVerdictEngine {
  const DeterministicRubricVerdictEngine();

  RubricMappedVerdict evaluate({
    required RubricScenario scenario,
    required String answer,
    required String rubricVersion,
    required String promptVersion,
  }) {
    final normalized = answer.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(answer, 'answer', 'must not be empty');
    }
    final findings = <RubricCriterionVerdict>[
      for (final criterion in scenario.criteria)
        _evaluateCriterion(criterion: criterion, answer: normalized),
    ];
    final levelRead = _levelRead(findings);
    return RubricMappedVerdict(
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      levelRead: levelRead,
      levelReason: _levelReason(levelRead, findings),
      findings: List<RubricCriterionVerdict>.unmodifiable(findings),
      deliveryStrengths: _deliveryStrengths(normalized),
      deliveryRisks: _deliveryRisks(normalized),
      deliveryFixes: _deliveryFixes(normalized),
    );
  }

  RubricCriterionVerdict _evaluateCriterion({
    required RubricCriterion criterion,
    required String answer,
  }) {
    final expected = _matchedTerms(answer, criterion.expectedSignals);
    final advanced = _matchedTerms(answer, criterion.advancedSignals);
    final threshold = criterion.expectedSignals.length <= 2 ? 1 : 2;
    final levelSignal = switch ((
      expected.length >= threshold,
      advanced.isNotEmpty,
      expected.isNotEmpty,
    )) {
      (true, true, _) => RubricLevelSignal.l6,
      (true, false, _) => RubricLevelSignal.l5,
      (false, _, true) => RubricLevelSignal.partial,
      _ => RubricLevelSignal.downLevel,
    };
    final evidence = _evidenceSlice(
      answer: answer,
      terms: <String>[...expected, ...advanced, ...criterion.expectedSignals],
    );
    return RubricCriterionVerdict(
      criterionId: criterion.criterionId,
      label: criterion.label,
      levelSignal: levelSignal,
      finding: _finding(criterion, levelSignal),
      downLevelReason: criterion.downLevelSignals.first,
      minimumFix: criterion.minimumFix,
      quote: evidence.quote,
      startOffset: evidence.startOffset,
      endOffset: evidence.endOffset,
      matchedSignals: List<String>.unmodifiable(
        <String>{...expected, ...advanced}.toList()..sort(),
      ),
    );
  }

  String _finding(RubricCriterion criterion, RubricLevelSignal signal) {
    return switch (signal) {
      RubricLevelSignal.l6 =>
        '${criterion.label} reads L6: ${criterion.l6Anchor}',
      RubricLevelSignal.l5 =>
        '${criterion.label} reads L5: ${criterion.l5Anchor}',
      RubricLevelSignal.partial =>
        '${criterion.label} is partially supported but not yet anchored enough for L5: ${criterion.judgmentFocus}',
      RubricLevelSignal.downLevel =>
        '${criterion.label} is a down-level risk: ${criterion.downLevelSignals.first}',
    };
  }

  String _levelRead(List<RubricCriterionVerdict> findings) {
    final l5OrBetter = findings
        .where(
          (finding) =>
              finding.levelSignal == RubricLevelSignal.l5 ||
              finding.levelSignal == RubricLevelSignal.l6,
        )
        .length;
    final misses = findings
        .where((finding) => finding.levelSignal == RubricLevelSignal.downLevel)
        .length;
    if (l5OrBetter >= 4 && misses == 0) return 'at_bar';
    if (l5OrBetter >= 2 && misses <= 2) return 'approaching';
    return 'below_bar';
  }

  String _levelReason(String levelRead, List<RubricCriterionVerdict> findings) {
    final l6Labels = findings
        .where((finding) => finding.levelSignal == RubricLevelSignal.l6)
        .map((finding) => finding.label)
        .toList();
    final riskLabels = findings
        .where(
          (finding) =>
              finding.levelSignal == RubricLevelSignal.downLevel ||
              finding.levelSignal == RubricLevelSignal.partial,
        )
        .map((finding) => finding.label)
        .toList();
    if (levelRead == 'at_bar') {
      return 'the answer shows staff-level signal in ${l6Labels.take(3).join(', ')} with no uncovered rubric dimension';
    }
    if (levelRead == 'approaching') {
      return 'the answer is production-capable, but ${riskLabels.take(2).join(', ')} need more cross-team or failure-mode depth';
    }
    return 'multiple rubric dimensions lack enough concrete evidence, especially ${riskLabels.take(2).join(', ')}';
  }

  List<String> _deliveryStrengths(String answer) {
    final wordCount = _wordCount(answer);
    return <String>[
      if (wordCount >= 70 && wordCount <= 220)
        'The answer is in a usable typed-interview length range.',
      if (_hasAny(answer, const <String>['because', 'so', 'therefore']))
        'The answer uses causal language that makes the decision trace easier to follow.',
    ];
  }

  List<String> _deliveryRisks(String answer) {
    final wordCount = _wordCount(answer);
    return <String>[
      if (wordCount < 70)
        'The answer is too compressed for a senior/staff backend verdict.',
      if (wordCount > 220)
        'The answer may bury the decision in too much setup.',
      if (!_hasAny(answer, const <String>['because', 'tradeoff', 'therefore']))
        'The answer needs clearer decision rationale, not only components.',
    ];
  }

  List<String> _deliveryFixes(String answer) {
    final risks = _deliveryRisks(answer);
    if (risks.isEmpty) return const <String>[];
    return <String>[
      if (_wordCount(answer) < 70)
        'Expand into requirements, decision, failure mode, and measurement.',
      if (_wordCount(answer) > 220)
        'Cut setup and preserve only the decisive trade-off and evidence.',
      if (!_hasAny(answer, const <String>['because', 'tradeoff', 'therefore']))
        'Add one sentence that says why the chosen design beats the alternative.',
    ];
  }
}

List<String> _matchedTerms(String answer, Iterable<String> terms) {
  final lower = answer.toLowerCase();
  return <String>[
    for (final term in terms)
      if (_containsTerm(lower, term.toLowerCase())) term,
  ];
}

bool _containsTerm(String lowerAnswer, String lowerTerm) {
  if (lowerTerm.contains(' ')) return lowerAnswer.contains(lowerTerm);
  return RegExp(
    '(?<![a-z0-9])${RegExp.escape(lowerTerm)}(?![a-z0-9])',
  ).hasMatch(lowerAnswer);
}

bool _hasAny(String answer, Iterable<String> terms) {
  final lower = answer.toLowerCase();
  return terms.any((term) => _containsTerm(lower, term.toLowerCase()));
}

int _wordCount(String answer) => RegExp(r'\S+').allMatches(answer).length;

_EvidenceSlice _evidenceSlice({
  required String answer,
  required Iterable<String> terms,
}) {
  final lower = answer.toLowerCase();
  for (final term in terms) {
    final index = lower.indexOf(term.toLowerCase());
    if (index >= 0) return _sentenceAround(answer, index);
  }
  return _sentenceAround(answer, 0);
}

_EvidenceSlice _sentenceAround(String answer, int anchor) {
  final start = _sentenceStart(answer, anchor);
  final end = _sentenceEnd(answer, anchor);
  return _EvidenceSlice(
    quote: answer.substring(start, end).trim(),
    startOffset: start,
    endOffset: end,
  );
}

int _sentenceStart(String value, int anchor) {
  final prior = value.lastIndexOf(RegExp(r'[.!?]'), anchor);
  return prior < 0 ? 0 : (prior + 1).clamp(0, value.length).toInt();
}

int _sentenceEnd(String value, int anchor) {
  final match = RegExp(r'[.!?]').firstMatch(value.substring(anchor));
  if (match == null) return value.length;
  return (anchor + match.end).clamp(0, value.length).toInt();
}

final class _EvidenceSlice {
  const _EvidenceSlice({
    required this.quote,
    required this.startOffset,
    required this.endOffset,
  });

  final String quote;
  final int startOffset;
  final int endOffset;
}

List<String> _cleanItems(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) {
        return value.isNotEmpty;
      })
      .toList(growable: false);
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
