import 'dart:collection';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';
import '../schemas/common_contracts.dart';
import '../schemas/target_contracts.dart';
import '../schemas/transcript_contracts.dart';

part 'schema_data_structures.freezed.dart';
part 'schema_data_structures.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum BillingEventType {
  purchase,
  renewal,
  cancellation,
  billingIssue,
  refund,
  restore,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum EntitlementStatus {
  active,
  grace,
  trial,
  expired,
  revoked,
}

@freezed
abstract class CorpusQuery with _$CorpusQuery {
  @JsonSerializable(explicitToJson: true)
  const factory CorpusQuery({
    @JsonKey(name: 'schema_version')
    @Default(kCorpusQuerySchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'query_id') required String queryId,
    @JsonKey(name: 'query_text') required String queryText,
    required TargetRoleCompany target,
    @JsonKey(name: 'corpus_bundle_version') required String corpusBundleVersion,
    @Default(<String, String>{}) Map<String, String> filters,
    @JsonKey(name: 'limit') @Default(10) int limit,
  }) = _CorpusQuery;

  factory CorpusQuery.fromJson(Map<String, Object?> json) =>
      _$CorpusQueryFromJson(json);
}

@freezed
abstract class CorpusHit with _$CorpusHit {
  @Assert('score >= 0', 'score must be non-negative')
  @JsonSerializable(explicitToJson: true)
  const factory CorpusHit({
    @JsonKey(name: 'schema_version')
    @Default(kCorpusHitSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'record_id') required String recordId,
    @JsonKey(name: 'bundle_id') required String bundleId,
    @JsonKey(name: 'bundle_version') required String bundleVersion,
    required double score,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _CorpusHit;

  factory CorpusHit.fromJson(Map<String, Object?> json) =>
      _$CorpusHitFromJson(json);
}

@freezed
abstract class CorpusRetrievalResult with _$CorpusRetrievalResult {
  @JsonSerializable(explicitToJson: true)
  const factory CorpusRetrievalResult({
    @JsonKey(name: 'schema_version')
    @Default(kCorpusRetrievalResultSchemaVersion)
    String schemaVersion,
    required CorpusQuery query,
    required List<CorpusHit> hits,
    @JsonKey(name: 'retrieval_policy_version')
    required String retrievalPolicyVersion,
    @JsonKey(name: 'generated_at') required DateTime generatedAt,
  }) = _CorpusRetrievalResult;

  factory CorpusRetrievalResult.fromJson(Map<String, Object?> json) =>
      _$CorpusRetrievalResultFromJson(json);
}

@freezed
abstract class BillingLedgerEntry with _$BillingLedgerEntry {
  @JsonSerializable(explicitToJson: true)
  const factory BillingLedgerEntry({
    @JsonKey(name: 'schema_version')
    @Default(kBillingLedgerEntrySchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'entry_id') required String entryId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'provider_id') required String providerId,
    @JsonKey(name: 'provider_event_id') required String providerEventId,
    @JsonKey(name: 'event_type') required BillingEventType eventType,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _BillingLedgerEntry;

  factory BillingLedgerEntry.fromJson(Map<String, Object?> json) =>
      _$BillingLedgerEntryFromJson(json);
}

@freezed
abstract class EntitlementSnapshot with _$EntitlementSnapshot {
  @JsonSerializable(explicitToJson: true)
  const factory EntitlementSnapshot({
    @JsonKey(name: 'schema_version')
    @Default(kEntitlementSnapshotSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'user_id') required String userId,
    required EntitlementStatus status,
    @JsonKey(name: 'plan_id') required String planId,
    @JsonKey(name: 'source_ledger_entry_ids')
    @Default(<String>[])
    List<String> sourceLedgerEntryIds,
    @JsonKey(name: 'effective_at') required DateTime effectiveAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _EntitlementSnapshot;

  factory EntitlementSnapshot.fromJson(Map<String, Object?> json) =>
      _$EntitlementSnapshotFromJson(json);
}

@freezed
abstract class EntitlementDecision with _$EntitlementDecision {
  @JsonSerializable(explicitToJson: true)
  const factory EntitlementDecision({
    @JsonKey(name: 'schema_version')
    @Default(kEntitlementDecisionSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'decision_id') required String decisionId,
    @JsonKey(name: 'allowed') required bool allowed,
    @JsonKey(name: 'reason_code') required String reasonCode,
    @JsonKey(name: 'policy_version') required String policyVersion,
    required EntitlementSnapshot snapshot,
  }) = _EntitlementDecision;

  factory EntitlementDecision.fromJson(Map<String, Object?> json) =>
      _$EntitlementDecisionFromJson(json);
}

class RetrievalIndexShape {
  RetrievalIndexShape(Iterable<CorpusHit> hits) {
    for (final hit in hits) {
      final terms = hit.metadata['terms'];
      if (terms is Iterable) {
        for (final term in terms.whereType<String>()) {
          _postingsByTerm.putIfAbsent(term, () => <CorpusHit>[]).add(hit);
        }
      }
    }
    for (final entry in _postingsByTerm.entries) {
      entry.value.sort(_corpusHitOrder);
    }
  }

  final Map<String, List<CorpusHit>> _postingsByTerm =
      HashMap<String, List<CorpusHit>>();

  List<CorpusHit> postingsFor(String term) =>
      List<CorpusHit>.unmodifiable(_postingsByTerm[term] ?? <CorpusHit>[]);

  static int _corpusHitOrder(CorpusHit left, CorpusHit right) {
    final scoreCompare = right.score.compareTo(left.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    return left.recordId.compareTo(right.recordId);
  }
}

class EvidenceLedger {
  EvidenceLedger(Iterable<EvidenceAtomView> atoms)
      : _atomsById = Map<String, EvidenceAtomView>.unmodifiable(
          <String, EvidenceAtomView>{
            for (final atom in atoms) atom.atomId: atom,
          },
        );

  final Map<String, EvidenceAtomView> _atomsById;

  EvidenceAtomView? byAtomId(String atomId) => _atomsById[atomId];

  List<EvidenceAtomView> get atoms =>
      List<EvidenceAtomView>.unmodifiable(_atomsById.values);

  EvidenceLedger add(EvidenceAtomView atom) => EvidenceLedger(
        <EvidenceAtomView>[..._atomsById.values, atom],
      );
}

@freezed
abstract class EvidenceAtomView with _$EvidenceAtomView {
  @JsonSerializable(explicitToJson: true)
  const factory EvidenceAtomView({
    @JsonKey(name: 'atom_id') required String atomId,
    @JsonKey(name: 'source_id') required String sourceId,
    required String text,
    @JsonKey(name: 'evidence_spans') required List<EvidenceSpan> evidenceSpans,
  }) = _EvidenceAtomView;

  factory EvidenceAtomView.fromJson(Map<String, Object?> json) =>
      _$EvidenceAtomViewFromJson(json);
}

class TranscriptSegmentTree {
  TranscriptSegmentTree(List<TranscriptSegment> segments)
      : _root = _SegmentNode.build(
          List<TranscriptSegment>.of(segments)
            ..sort((left, right) => left.startMs.compareTo(right.startMs)),
        );

  final _SegmentNode? _root;

  TranscriptSegment? segmentAt(int offsetMs) => _root?.segmentAt(offsetMs);
}

class _SegmentNode {
  _SegmentNode({
    required this.segment,
    required this.left,
    required this.right,
  });

  final TranscriptSegment segment;
  final _SegmentNode? left;
  final _SegmentNode? right;

  static _SegmentNode? build(List<TranscriptSegment> segments) {
    if (segments.isEmpty) {
      return null;
    }
    final middle = segments.length ~/ 2;
    return _SegmentNode(
      segment: segments[middle],
      left: build(segments.sublist(0, middle)),
      right: build(segments.sublist(middle + 1)),
    );
  }

  TranscriptSegment? segmentAt(int offsetMs) {
    if (offsetMs >= segment.startMs && offsetMs <= segment.endMs) {
      return segment;
    }
    if (offsetMs < segment.startMs) {
      return left?.segmentAt(offsetMs);
    }
    return right?.segmentAt(offsetMs);
  }
}

class ProviderRegistry<T> {
  ProviderRegistry();

  final Map<String, _ProviderRegistration<T>> _registrations =
      <String, _ProviderRegistration<T>>{};

  void register({
    required String providerId,
    required T provider,
    int priority = 100,
  }) {
    if (_registrations.containsKey(providerId)) {
      throw StateError('Provider already registered: $providerId');
    }
    _registrations[providerId] = _ProviderRegistration<T>(
      providerId: providerId,
      provider: provider,
      priority: priority,
      insertionOrder: _registrations.length,
    );
  }

  T provider(String providerId) => _registrations[providerId]?.provider ??
      (throw StateError('Provider not registered: $providerId'));

  T get primary {
    if (_registrations.isEmpty) {
      throw StateError('No providers registered');
    }
    final registrations = _registrations.values.toList()
      ..sort((left, right) {
        final priorityCompare = left.priority.compareTo(right.priority);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return left.insertionOrder.compareTo(right.insertionOrder);
      });
    return registrations.first.provider;
  }

  List<String> get providerIds => List<String>.unmodifiable(
        _registrations.keys,
      );
}

class _ProviderRegistration<T> {
  const _ProviderRegistration({
    required this.providerId,
    required this.provider,
    required this.priority,
    required this.insertionOrder,
  });

  final String providerId;
  final T provider;
  final int priority;
  final int insertionOrder;
}
