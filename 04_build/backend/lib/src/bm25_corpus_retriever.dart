import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'corpus_models.dart';
import 'corpus_retriever.dart';
import 'signed_corpus_bundle.dart';

final class Bm25CorpusRetriever implements CorpusRetriever {
  Bm25CorpusRetriever({
    required CorpusBundle bundle,
    this.retrieverId = 'bm25_fts5_local_v1',
    this.k1 = 1.2,
    this.b = 0.75,
  })  : _bundle = bundle,
        _indexedRecords = bundle.records,
        _documentTokens = _buildDocumentTokens(bundle.records),
        _documentFrequency =
            _buildDocumentFrequency(_buildDocumentTokens(bundle.records)) {
    if (!bundle.verifySignature()) {
      throw StateError(
        'Corpus bundle ${bundle.bundleVersion} signature mismatch. '
        'Replace the bundle instead of mutating it in place.',
      );
    }
  }

  final CorpusBundle _bundle;
  final UnmodifiableListView<CorpusRecord> _indexedRecords;
  final Map<String, List<String>> _documentTokens;
  final Map<String, int> _documentFrequency;
  final double k1;
  final double b;

  @override
  final String retrieverId;

  @override
  String get corpusBundleVersion => _bundle.bundleVersion;

  @override
  Future<CorpusRetrievalResult> retrieve(CorpusQuery query) async {
    final queryTokens = _tokenize(query.queryText).toSet().toList()..sort();
    if (queryTokens.isEmpty) {
      return CorpusRetrievalResult(
        query: query,
        corpusBundleVersion: corpusBundleVersion,
        records: const <RetrievedCorpusRecord>[],
        routeHash: _routeHash(query, const <String>[]),
      );
    }

    final eligibleRecords = _indexedRecords
        .where((record) => record.matches(query))
        .toList()
      ..sort((left, right) => left.recordId.compareTo(right.recordId));
    final averageDocumentLength = _averageDocumentLength(eligibleRecords);

    final scored = <RetrievedCorpusRecord>[];
    for (final record in eligibleRecords) {
      final tokens = _documentTokens[record.recordId] ?? const <String>[];
      final score = _bm25Score(
        queryTokens: queryTokens,
        documentTokens: tokens,
        averageDocumentLength: averageDocumentLength,
      );
      if (score <= 0) continue;
      scored.add(
        RetrievedCorpusRecord(
          record: record,
          score: score,
          evidenceSpans: <CorpusEvidenceSpan>[
            _evidenceSpanFor(
                record: record, queryTokens: queryTokens, score: score),
          ],
        ),
      );
    }

    scored.sort((left, right) {
      final byScore = right.score.compareTo(left.score);
      if (byScore != 0) return byScore;
      return left.record.recordId.compareTo(right.record.recordId);
    });

    final selected =
        List<RetrievedCorpusRecord>.unmodifiable(scored.take(query.limit));
    return CorpusRetrievalResult(
      query: query,
      corpusBundleVersion: corpusBundleVersion,
      records: selected,
      routeHash:
          _routeHash(query, selected.map((record) => record.record.recordId)),
    );
  }

  double _bm25Score({
    required List<String> queryTokens,
    required List<String> documentTokens,
    required double averageDocumentLength,
  }) {
    if (documentTokens.isEmpty || averageDocumentLength == 0) return 0;
    final documentLength = documentTokens.length;
    final termFrequency = <String, int>{};
    for (final token in documentTokens) {
      termFrequency[token] = (termFrequency[token] ?? 0) + 1;
    }

    var score = 0.0;
    for (final token in queryTokens) {
      final frequency = termFrequency[token] ?? 0;
      if (frequency == 0) continue;
      final documentCount = _indexedRecords.length;
      final docsWithTerm = _documentFrequency[token] ?? 0;
      final idf =
          log(1 + (documentCount - docsWithTerm + 0.5) / (docsWithTerm + 0.5));
      final numerator = frequency * (k1 + 1);
      final denominator =
          frequency + k1 * (1 - b + b * documentLength / averageDocumentLength);
      score += idf * numerator / denominator;
    }
    return score;
  }

  double _averageDocumentLength(List<CorpusRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold<int>(
      0,
      (sum, record) => sum + (_documentTokens[record.recordId]?.length ?? 0),
    );
    return total / records.length;
  }

  String _routeHash(CorpusQuery query, Iterable<String> recordIds) {
    final canonicalRoute = <String>[
      'retrieval_route_v001',
      retrieverId,
      corpusBundleVersion,
      query.queryText.trim().toLowerCase(),
      query.limit.toString(),
      query.roleId ?? '',
      query.domain ?? '',
      query.levelBand ?? '',
      query.companyArchetype ?? '',
      query.requiredTags.join(','),
      ...recordIds,
    ].join('|');
    return List<String>.generate(
      4,
      (index) => _fnv1a64('$index|$canonicalRoute'),
    ).join();
  }
}

Map<String, List<String>> _buildDocumentTokens(Iterable<CorpusRecord> records) {
  return <String, List<String>>{
    for (final record in records)
      record.recordId:
          List<String>.unmodifiable(_tokenize(record.searchableText)),
  };
}

Map<String, int> _buildDocumentFrequency(
    Map<String, List<String>> documentTokens) {
  final frequency = <String, int>{};
  for (final tokens in documentTokens.values) {
    for (final token in tokens.toSet()) {
      frequency[token] = (frequency[token] ?? 0) + 1;
    }
  }
  return frequency;
}

Iterable<String> _tokenize(String input) {
  return RegExp(r'[a-z0-9]+')
      .allMatches(input.toLowerCase())
      .map((match) => match.group(0)!)
      .where((token) => token.length > 1);
}

CorpusEvidenceSpan _evidenceSpanFor({
  required CorpusRecord record,
  required List<String> queryTokens,
  required double score,
}) {
  final lowerBody = record.body.toLowerCase();
  var start = 0;
  for (final token in queryTokens) {
    final index = lowerBody.indexOf(token);
    if (index >= 0) {
      start = index;
      break;
    }
  }
  final end = min(record.body.length, start + 180);
  return CorpusEvidenceSpan(
    recordId: record.recordId,
    startOffset: start,
    endOffset: end,
    text: record.body.substring(start, end).trim(),
    corpusBundleVersion: record.corpusBundleVersion,
    score: double.parse(score.toStringAsFixed(6)),
  );
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
