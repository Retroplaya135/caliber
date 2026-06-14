import 'dart:collection';

final class AdjudicationCase {
  AdjudicationCase({
    required this.caseId,
    required this.rubricSliceId,
    required this.prompt,
    required this.answer,
    required this.expectedBand,
    required Iterable<String> seniorReviewerLabels,
  }) : seniorReviewerLabels =
            UnmodifiableListView<String>(seniorReviewerLabels.toList()) {
    if (this.seniorReviewerLabels.length != 2) {
      throw ArgumentError.value(seniorReviewerLabels, 'seniorReviewerLabels',
          'must contain two labels');
    }
  }

  final String caseId;
  final String rubricSliceId;
  final String prompt;
  final String answer;
  final String expectedBand;
  final UnmodifiableListView<String> seniorReviewerLabels;
}

final class AdjudicationSetFactory {
  static const requiredCaseCount = 200;

  List<AdjudicationCase> build200AnswerSet() {
    final rubricSlices = <String>[
      'system_design_scaling',
      'debugging_root_cause',
      'data_structures_tradeoff',
      'api_contracts',
      'testing_strategy',
      'security_boundary',
      'database_modeling',
      'async_state',
      'performance_budget',
      'product_reasoning',
    ];
    final bands = <String>['emerging', 'solid', 'strong', 'exceptional'];
    final cases = <AdjudicationCase>[];
    for (final slice in rubricSlices) {
      for (var variant = 0; variant < 20; variant += 1) {
        final band = bands[(variant + slice.length) % bands.length];
        cases.add(
          AdjudicationCase(
            caseId: 'adj_${slice}_v${variant.toString().padLeft(2, '0')}',
            rubricSliceId: slice,
            prompt:
                'Evaluate a ${slice.replaceAll('_', ' ')} answer for calibrated evidence.',
            answer:
                'Candidate answer variant $variant for $slice includes tradeoffs, constraints, '
                'and evidence references for the judgment flow.',
            expectedBand: band,
            seniorReviewerLabels: <String>[
              band,
              bands[(variant + slice.length + 1) % bands.length]
            ],
          ),
        );
      }
    }
    if (cases.length != requiredCaseCount) {
      throw StateError(
          'Expected $requiredCaseCount adjudication cases, got ${cases.length}.');
    }
    return List<AdjudicationCase>.unmodifiable(cases);
  }
}
