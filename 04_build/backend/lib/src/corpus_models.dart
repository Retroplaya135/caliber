import 'dart:collection';

enum CorpusRecordKind {
  rubricSlice,
  benchmarkAnswer,
  glossaryTerm,
}

final class CorpusRecord {
  CorpusRecord({
    required this.recordId,
    required this.kind,
    required this.title,
    required this.body,
    required this.corpusBundleVersion,
    this.roleId,
    this.domain,
    this.levelBand,
    this.companyArchetype,
    Iterable<String> tags = const <String>[],
    Map<String, String> metadata = const <String, String>{},
  })  : tags = UnmodifiableListView<String>(
          tags
              .map(_normalizeTag)
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
        ),
        metadata = UnmodifiableMapView<String, String>(
            Map<String, String>.from(metadata)) {
    _checkNotEmpty(recordId, 'recordId');
    _checkNotEmpty(title, 'title');
    _checkNotEmpty(body, 'body');
    _checkNotEmpty(corpusBundleVersion, 'corpusBundleVersion');
  }

  final String recordId;
  final CorpusRecordKind kind;
  final String title;
  final String body;
  final String corpusBundleVersion;
  final String? roleId;
  final String? domain;
  final String? levelBand;
  final String? companyArchetype;
  final UnmodifiableListView<String> tags;
  final UnmodifiableMapView<String, String> metadata;

  String get searchableText => '$title\n$body\n${tags.join(' ')}';

  bool matches(CorpusQuery query) {
    if (query.roleId != null && roleId != query.roleId) return false;
    if (query.domain != null && domain != query.domain) return false;
    if (query.levelBand != null && levelBand != query.levelBand) return false;
    if (query.companyArchetype != null &&
        companyArchetype != query.companyArchetype) {
      return false;
    }
    for (final tag in query.requiredTags) {
      if (!tags.contains(tag)) return false;
    }
    return true;
  }
}

final class CorpusQuery {
  CorpusQuery({
    required this.queryText,
    this.limit = 5,
    this.roleId,
    this.domain,
    this.levelBand,
    this.companyArchetype,
    Iterable<String> requiredTags = const <String>[],
  }) : requiredTags = UnmodifiableListView<String>(
          requiredTags
              .map(_normalizeTag)
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .toList()
            ..sort(),
        ) {
    _checkNotEmpty(queryText, 'queryText');
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be positive');
    }
  }

  final String queryText;
  final int limit;
  final String? roleId;
  final String? domain;
  final String? levelBand;
  final String? companyArchetype;
  final UnmodifiableListView<String> requiredTags;
}

final class CorpusEvidenceSpan {
  CorpusEvidenceSpan({
    required this.recordId,
    required this.startOffset,
    required this.endOffset,
    required this.text,
    required this.corpusBundleVersion,
    required this.score,
  }) {
    _checkNotEmpty(recordId, 'recordId');
    _checkNotEmpty(text, 'text');
    _checkNotEmpty(corpusBundleVersion, 'corpusBundleVersion');
    if (startOffset < 0) {
      throw ArgumentError.value(
          startOffset, 'startOffset', 'must be non-negative');
    }
    if (endOffset <= startOffset) {
      throw ArgumentError.value(
          endOffset, 'endOffset', 'must be greater than startOffset');
    }
    if (score < 0) {
      throw ArgumentError.value(score, 'score', 'must be non-negative');
    }
  }

  final String recordId;
  final int startOffset;
  final int endOffset;
  final String text;
  final String corpusBundleVersion;
  final double score;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'record_id': recordId,
      'start_offset': startOffset,
      'end_offset': endOffset,
      'text': text,
      'corpus_bundle_version': corpusBundleVersion,
      'score': score,
    };
  }
}

final class RetrievedCorpusRecord {
  const RetrievedCorpusRecord({
    required this.record,
    required this.score,
    required this.evidenceSpans,
  });

  final CorpusRecord record;
  final double score;
  final List<CorpusEvidenceSpan> evidenceSpans;
}

final class CorpusRetrievalResult {
  const CorpusRetrievalResult({
    required this.query,
    required this.corpusBundleVersion,
    required this.records,
    required this.routeHash,
  });

  final CorpusQuery query;
  final String corpusBundleVersion;
  final String routeHash;
  final List<RetrievedCorpusRecord> records;

  List<CorpusEvidenceSpan> get evidenceSpans {
    return <CorpusEvidenceSpan>[
      for (final record in records) ...record.evidenceSpans,
    ];
  }
}

String _normalizeTag(String tag) {
  return tag.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
