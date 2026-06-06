import 'dart:collection';

import 'memory_models.dart';

abstract interface class UserMemoryStore {
  Future<void> writeTargetMatrix(TargetMatrixCell cell);

  Future<void> writeEvidence(EvidenceLedgerEntry entry);

  Future<void> writeGap(GapLedgerEntry entry);

  Future<void> writeHistory(HistoryEvent event);

  Future<void> writeSpeakingProfile(SpeakingProfile profile);

  Future<void> tombstone({
    required String userId,
    required String tableName,
    required String rowId,
    required DeletionTombstone tombstone,
  });

  Future<UserMemorySnapshot> snapshot(String userId);
}

final class InMemoryUserMemoryStore implements UserMemoryStore {
  final _targetMatrix = <String, TargetMatrixCell>{};
  final _evidenceLedger = <String, EvidenceLedgerEntry>{};
  final _gapLedger = <String, GapLedgerEntry>{};
  final _historyEvents = <String, HistoryEvent>{};
  final _speakingProfiles = <String, SpeakingProfile>{};
  final _deletionTombstones = <String, DeletionTombstone>{};

  @override
  Future<void> writeTargetMatrix(TargetMatrixCell cell) async {
    _put(_targetMatrix, cell);
  }

  @override
  Future<void> writeEvidence(EvidenceLedgerEntry entry) async {
    _put(_evidenceLedger, entry);
  }

  @override
  Future<void> writeGap(GapLedgerEntry entry) async {
    _put(_gapLedger, entry);
  }

  @override
  Future<void> writeHistory(HistoryEvent event) async {
    _put(_historyEvents, event);
  }

  @override
  Future<void> writeSpeakingProfile(SpeakingProfile profile) async {
    _put(_speakingProfiles, profile);
  }

  @override
  Future<void> tombstone({
    required String userId,
    required String tableName,
    required String rowId,
    required DeletionTombstone tombstone,
  }) async {
    if (tombstone.userId != userId) {
      throw StateError(
          'Tombstone user ${tombstone.userId} does not match $userId.');
    }
    if (tombstone.deletedTable != tableName ||
        tombstone.deletedRowId != rowId) {
      throw StateError('Tombstone does not identify $tableName/$rowId.');
    }
    _deleteFrom(tableName, userId: userId, rowId: rowId);
    _put(_deletionTombstones, tombstone);
  }

  @override
  Future<UserMemorySnapshot> snapshot(String userId) async {
    return UserMemorySnapshot(
      userId: userId,
      targetMatrix: _rowsFor(_targetMatrix, userId),
      evidenceLedger: _rowsFor(_evidenceLedger, userId),
      gapLedger: _rowsFor(_gapLedger, userId),
      historyEvents: _rowsFor(_historyEvents, userId),
      speakingProfiles: _rowsFor(_speakingProfiles, userId),
      deletionTombstones: _rowsFor(_deletionTombstones, userId),
    );
  }

  void _deleteFrom(
    String tableName, {
    required String userId,
    required String rowId,
  }) {
    final rowKey = _rowKey(userId: userId, rowId: rowId);
    switch (tableName) {
      case 'target_matrix':
        _targetMatrix.remove(rowKey);
      case 'evidence_ledger':
        _evidenceLedger.remove(rowKey);
      case 'gap_ledger':
        _gapLedger.remove(rowKey);
      case 'history_event':
        _historyEvents.remove(rowKey);
      case 'speaking_profile':
        _speakingProfiles.remove(rowKey);
      default:
        throw ArgumentError.value(
            tableName, 'tableName', 'unknown memory table');
    }
  }
}

final class UserMemorySnapshot {
  UserMemorySnapshot({
    required this.userId,
    required Iterable<TargetMatrixCell> targetMatrix,
    required Iterable<EvidenceLedgerEntry> evidenceLedger,
    required Iterable<GapLedgerEntry> gapLedger,
    required Iterable<HistoryEvent> historyEvents,
    required Iterable<SpeakingProfile> speakingProfiles,
    required Iterable<DeletionTombstone> deletionTombstones,
  })  : targetMatrix =
            UnmodifiableListView<TargetMatrixCell>(_sortRows(targetMatrix)),
        evidenceLedger = UnmodifiableListView<EvidenceLedgerEntry>(
            _sortRows(evidenceLedger)),
        gapLedger = UnmodifiableListView<GapLedgerEntry>(_sortRows(gapLedger)),
        historyEvents =
            UnmodifiableListView<HistoryEvent>(_sortRows(historyEvents)),
        speakingProfiles =
            UnmodifiableListView<SpeakingProfile>(_sortRows(speakingProfiles)),
        deletionTombstones = UnmodifiableListView<DeletionTombstone>(
            _sortRows(deletionTombstones));

  final String userId;
  final UnmodifiableListView<TargetMatrixCell> targetMatrix;
  final UnmodifiableListView<EvidenceLedgerEntry> evidenceLedger;
  final UnmodifiableListView<GapLedgerEntry> gapLedger;
  final UnmodifiableListView<HistoryEvent> historyEvents;
  final UnmodifiableListView<SpeakingProfile> speakingProfiles;
  final UnmodifiableListView<DeletionTombstone> deletionTombstones;
}

void _put<T extends UserMemoryRow>(Map<String, T> table, T row) {
  if (row.provenance.evidenceSpans.isEmpty) {
    throw StateError(
        'Memory row ${row.rowId} cannot persist without provenance evidence spans.');
  }
  table[_rowKey(userId: row.userId, rowId: row.rowId)] = row;
}

String _rowKey({required String userId, required String rowId}) {
  return '$userId\x1f$rowId';
}

List<T> _rowsFor<T extends UserMemoryRow>(Map<String, T> table, String userId) {
  return _sortRows(table.values.where((row) => row.userId == userId));
}

List<T> _sortRows<T extends UserMemoryRow>(Iterable<T> rows) {
  return rows.toList()
    ..sort((left, right) => left.rowId.compareTo(right.rowId));
}
