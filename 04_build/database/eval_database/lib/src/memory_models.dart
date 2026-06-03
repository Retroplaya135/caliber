import 'dart:collection';

import 'package:caliber_eval_backend/caliber_eval_backend.dart';

final class Provenance {
  Provenance({
    required this.sourceId,
    required this.sourceType,
    required this.schemaVersion,
    required this.corpusBundleVersion,
    required this.createdAt,
    required Iterable<CorpusEvidenceSpan> evidenceSpans,
    Map<String, String> metadata = const <String, String>{},
  })  : evidenceSpans =
            UnmodifiableListView<CorpusEvidenceSpan>(evidenceSpans.toList()),
        metadata = UnmodifiableMapView<String, String>(
            Map<String, String>.from(metadata)) {
    _checkNotEmpty(sourceId, 'sourceId');
    _checkNotEmpty(sourceType, 'sourceType');
    _checkNotEmpty(schemaVersion, 'schemaVersion');
    _checkNotEmpty(corpusBundleVersion, 'corpusBundleVersion');
    if (this.evidenceSpans.isEmpty) {
      throw ArgumentError.value(
          evidenceSpans, 'evidenceSpans', 'must not be empty');
    }
  }

  final String sourceId;
  final String sourceType;
  final String schemaVersion;
  final String corpusBundleVersion;
  final DateTime createdAt;
  final UnmodifiableListView<CorpusEvidenceSpan> evidenceSpans;
  final UnmodifiableMapView<String, String> metadata;
}

abstract class UserMemoryRow {
  UserMemoryRow({
    required this.rowId,
    required this.userId,
    required this.provenance,
  }) {
    _checkNotEmpty(rowId, 'rowId');
    _checkNotEmpty(userId, 'userId');
  }

  final String rowId;
  final String userId;
  final Provenance provenance;
}

final class TargetMatrixCell extends UserMemoryRow {
  TargetMatrixCell({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.roleId,
    required this.domain,
    required this.levelBand,
    required this.companyArchetype,
    required this.priority,
  }) {
    _checkNotEmpty(roleId, 'roleId');
    _checkNotEmpty(domain, 'domain');
    _checkNotEmpty(levelBand, 'levelBand');
    _checkNotEmpty(companyArchetype, 'companyArchetype');
    if (priority <= 0) {
      throw ArgumentError.value(priority, 'priority', 'must be positive');
    }
  }

  final String roleId;
  final String domain;
  final String levelBand;
  final String companyArchetype;
  final int priority;
}

final class EvidenceLedgerEntry extends UserMemoryRow {
  EvidenceLedgerEntry({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.claim,
    required this.strengthBand,
  }) {
    _checkNotEmpty(claim, 'claim');
    _checkNotEmpty(strengthBand, 'strengthBand');
  }

  final String claim;
  final String strengthBand;
}

final class GapLedgerEntry extends UserMemoryRow {
  GapLedgerEntry({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.gapLabel,
    required this.severityBand,
    required this.remediationHint,
  }) {
    _checkNotEmpty(gapLabel, 'gapLabel');
    _checkNotEmpty(severityBand, 'severityBand');
    _checkNotEmpty(remediationHint, 'remediationHint');
  }

  final String gapLabel;
  final String severityBand;
  final String remediationHint;
}

final class HistoryEvent extends UserMemoryRow {
  HistoryEvent({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.eventType,
    required this.summary,
  }) {
    _checkNotEmpty(eventType, 'eventType');
    _checkNotEmpty(summary, 'summary');
  }

  final String eventType;
  final String summary;
}

final class SpeakingProfile extends UserMemoryRow {
  SpeakingProfile({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.wordsPerMinute,
    required this.pauseCount,
    required this.fillerRatio,
  }) {
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
  }

  final double wordsPerMinute;
  final int pauseCount;
  final double fillerRatio;
}

final class DeletionTombstone extends UserMemoryRow {
  DeletionTombstone({
    required super.rowId,
    required super.userId,
    required super.provenance,
    required this.deletedTable,
    required this.deletedRowId,
    required this.deletedAt,
  }) {
    _checkNotEmpty(deletedTable, 'deletedTable');
    _checkNotEmpty(deletedRowId, 'deletedRowId');
  }

  final String deletedTable;
  final String deletedRowId;
  final DateTime deletedAt;
}

enum UserMemoryTable {
  targetMatrix('target_matrix'),
  evidenceLedger('evidence_ledger'),
  gapLedger('gap_ledger'),
  historyEvent('history_event'),
  speakingProfile('speaking_profile'),
  deletionTombstone('deletion_tombstone');

  const UserMemoryTable(this.tableName);

  final String tableName;
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
