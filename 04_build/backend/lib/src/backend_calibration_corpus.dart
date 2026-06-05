import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'backend_depth_rubric.dart';
import 'bm25_corpus_retriever.dart';
import 'corpus_models.dart';
import 'signed_corpus_bundle.dart';

final class BackendCalibrationCorpus {
  BackendCalibrationCorpus({
    CorpusBundle? bundle,
    BackendInterviewRubric? rubric,
    this._retrieverId = 'bm25_fts5_local_v1',
  }) : bundle = bundle ?? backendDepthCorpusBundleV02(),
       rubric = rubric ?? kBackendDepthRubric {
    if (!this.bundle.verifySignature()) {
      throw StateError(
        'Corpus bundle ${this.bundle.bundleVersion} signature mismatch. '
        'Replace the bundle instead of mutating it in place.',
      );
    }
    if (this.rubric.replacePolicy != kBackendDepthReplacePolicy) {
      throw StateError(
        'Backend rubric ${this.rubric.rubricVersion} must be '
        '$kBackendDepthReplacePolicy.',
      );
    }
  }

  final CorpusBundle bundle;
  final BackendInterviewRubric rubric;
  final String _retrieverId;

  String get corpusBundleVersion => bundle.bundleVersion;
  String get rubricVersion => rubric.rubricVersion;
  String get promptVersion => rubric.promptVersion;

  Future<BackendCorpusRankResult> rankForPrepBrief({
    required String jobDescription,
    int limit = 30,
  }) async {
    final result =
        await Bm25CorpusRetriever(
          bundle: bundle,
          retrieverId: _retrieverId,
        ).retrieve(
          CorpusQuery(
            queryText: jobDescription,
            roleId: 'backend_engineer',
            domain: 'Backend',
            levelBand: 'L5/L6',
            companyArchetype: 'growth-stage-product',
            requiredTags: const <String>['interview'],
            limit: limit,
          ),
        );
    final ranked = <BackendRubricScenario>[];
    final seen = <String>{};
    for (final record in result.records) {
      final scenarioId = record.record.metadata['scenario_id'];
      if (scenarioId == null || !seen.add(scenarioId)) continue;
      ranked.add(scenarioForScenarioId(scenarioId));
    }
    for (final fallback in _fallbackRank(jobDescription)) {
      if (seen.add(fallback.scenarioId)) {
        ranked.add(fallback);
      }
    }
    return BackendCorpusRankResult(
      retrieval: result,
      scenarios: ranked.take(limit).toList(growable: false),
    );
  }

  CorpusRetrievalResult groundingForQuestion({
    required String questionId,
    required String answer,
    required String roleId,
    required String domain,
    required String levelBand,
    required String companyArchetype,
  }) {
    final scenario = rubric.scenarioForQuestion(questionId);
    final record = _recordForScenario(scenario.scenarioId);
    final retrieved = RetrievedCorpusRecord(
      record: CorpusRecord(
        recordId: record.recordId,
        kind: record.kind,
        title: record.title,
        body: record.body,
        corpusBundleVersion: bundle.bundleVersion,
        roleId: roleId,
        domain: domain,
        levelBand: levelBand,
        companyArchetype: companyArchetype,
        tags: record.tags,
        metadata: record.metadata,
      ),
      score: 1,
      evidenceSpans: <CorpusEvidenceSpan>[_evidenceSpanFor(record)],
    );
    return CorpusRetrievalResult(
      query: CorpusQuery(
        queryText:
            '${scenario.questionId} ${scenario.title} ${_trimForHash(answer)}',
        roleId: roleId,
        domain: domain,
        levelBand: levelBand,
        companyArchetype: companyArchetype,
        requiredTags: const <String>['interview'],
      ),
      corpusBundleVersion: bundle.bundleVersion,
      records: <RetrievedCorpusRecord>[retrieved],
      routeHash: _routeHash(<String>[
        'backend_calibration_grounding.v1',
        _retrieverId,
        bundle.bundleVersion,
        rubric.rubricVersion,
        rubric.promptVersion,
        scenario.questionId,
        record.recordId,
        roleId,
        domain,
        levelBand,
        companyArchetype,
        _trimForHash(answer),
      ]),
    );
  }

  BackendRubricScenario scenarioForQuestion(String questionId) {
    return rubric.scenarioForQuestion(questionId);
  }

  BackendRubricScenario scenarioForScenarioId(String scenarioId) {
    return rubric.scenarios.firstWhere(
      (scenario) => scenario.scenarioId == scenarioId,
      orElse: () => throw StateError('Unknown backend scenario: $scenarioId'),
    );
  }

  CorpusRecord _recordForScenario(String scenarioId) {
    return bundle.records.firstWhere(
      (record) => record.metadata['scenario_id'] == scenarioId,
      orElse: () => throw StateError(
        'No signed corpus record found for backend scenario $scenarioId.',
      ),
    );
  }

  List<BackendRubricScenario> _fallbackRank(String jobDescription) {
    final tokens = _tokens(jobDescription);
    final weighted =
        <_ScenarioRank>[
          for (final scenario in rubric.scenarios)
            _ScenarioRank(
              scenario: scenario,
              signalCount: _scenarioSignalCount(scenario, tokens),
            ),
        ]..sort((left, right) {
          final bySignals = right.signalCount.compareTo(left.signalCount);
          if (bySignals != 0) return bySignals;
          return left.scenario.scenarioId.compareTo(right.scenario.scenarioId);
        });
    return <BackendRubricScenario>[for (final item in weighted) item.scenario];
  }
}

final class BackendCorpusRankResult {
  BackendCorpusRankResult({
    required this.retrieval,
    required Iterable<BackendRubricScenario> scenarios,
  }) : scenarios = UnmodifiableListView<BackendRubricScenario>(
         scenarios.toList(growable: false),
       );

  final CorpusRetrievalResult retrieval;
  final UnmodifiableListView<BackendRubricScenario> scenarios;
}

final class _ScenarioRank {
  const _ScenarioRank({required this.scenario, required this.signalCount});

  final BackendRubricScenario scenario;
  final int signalCount;
}

int _scenarioSignalCount(BackendRubricScenario scenario, Set<String> tokens) {
  final terms = <String>{
    ..._tokens(scenario.title),
    ..._tokens(scenario.prompt),
    for (final probe in scenario.probes) ..._tokens(probe),
    for (final trap in scenario.commonDownLevelTraps) ..._tokens(trap),
    for (final dimension in scenario.dimensions) ...dimension.expectedSignals,
    for (final dimension in scenario.dimensions) ...dimension.advancedSignals,
  };
  return terms.where((term) => tokens.contains(term.toLowerCase())).length;
}

Set<String> _tokens(String input) {
  return RegExp(r'[a-z0-9]+')
      .allMatches(input.toLowerCase())
      .map((match) => match.group(0)!)
      .where((token) => token.length > 1)
      .toSet();
}

CorpusEvidenceSpan _evidenceSpanFor(CorpusRecord record) {
  final endOffset = min(record.body.length, 240);
  return CorpusEvidenceSpan(
    recordId: record.recordId,
    startOffset: 0,
    endOffset: endOffset,
    text: record.body.substring(0, endOffset).trim(),
    corpusBundleVersion: record.corpusBundleVersion,
    score: 1,
  );
}

String _trimForHash(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= 240) return normalized;
  return normalized.substring(0, 240);
}

String _routeHash(List<String> parts) {
  final canonical = parts.join('|');
  return List<String>.generate(
    4,
    (index) => _fnv1a64('$index|$canonical'),
  ).join();
}

String _fnv1a64(String input) {
  var hash = BigInt.parse('cbf29ce484222325', radix: 16);
  final prime = BigInt.parse('100000001b3', radix: 16);
  final mask = BigInt.parse('ffffffffffffffff', radix: 16);
  for (final codeUnit in utf8.encode(input)) {
    hash ^= BigInt.from(codeUnit);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
