// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_data_structures.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CorpusQuery _$CorpusQueryFromJson(Map<String, dynamic> json) => _CorpusQuery(
  schemaVersion: json['schema_version'] as String? ?? kCorpusQuerySchemaVersion,
  queryId: json['query_id'] as String,
  queryText: json['query_text'] as String,
  target: TargetRoleCompany.fromJson(json['target'] as Map<String, dynamic>),
  corpusBundleVersion: json['corpus_bundle_version'] as String,
  filters:
      (json['filters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  limit: (json['limit'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$CorpusQueryToJson(_CorpusQuery instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'query_id': instance.queryId,
      'query_text': instance.queryText,
      'target': instance.target.toJson(),
      'corpus_bundle_version': instance.corpusBundleVersion,
      'filters': instance.filters,
      'limit': instance.limit,
    };

_CorpusHit _$CorpusHitFromJson(Map<String, dynamic> json) => _CorpusHit(
  schemaVersion: json['schema_version'] as String? ?? kCorpusHitSchemaVersion,
  recordId: json['record_id'] as String,
  bundleId: json['bundle_id'] as String,
  bundleVersion: json['bundle_version'] as String,
  score: (json['score'] as num).toDouble(),
  evidenceSpans: (json['evidence_spans'] as List<dynamic>)
      .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, Object?>{},
);

Map<String, dynamic> _$CorpusHitToJson(_CorpusHit instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'record_id': instance.recordId,
      'bundle_id': instance.bundleId,
      'bundle_version': instance.bundleVersion,
      'score': instance.score,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
      'metadata': instance.metadata,
    };

_CorpusRetrievalResult _$CorpusRetrievalResultFromJson(
  Map<String, dynamic> json,
) => _CorpusRetrievalResult(
  schemaVersion:
      json['schema_version'] as String? ?? kCorpusRetrievalResultSchemaVersion,
  query: CorpusQuery.fromJson(json['query'] as Map<String, dynamic>),
  hits: (json['hits'] as List<dynamic>)
      .map((e) => CorpusHit.fromJson(e as Map<String, dynamic>))
      .toList(),
  retrievalPolicyVersion: json['retrieval_policy_version'] as String,
  generatedAt: DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$CorpusRetrievalResultToJson(
  _CorpusRetrievalResult instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'query': instance.query.toJson(),
  'hits': instance.hits.map((e) => e.toJson()).toList(),
  'retrieval_policy_version': instance.retrievalPolicyVersion,
  'generated_at': instance.generatedAt.toIso8601String(),
};

_BillingLedgerEntry _$BillingLedgerEntryFromJson(Map<String, dynamic> json) =>
    _BillingLedgerEntry(
      schemaVersion:
          json['schema_version'] as String? ?? kBillingLedgerEntrySchemaVersion,
      entryId: json['entry_id'] as String,
      userId: json['user_id'] as String,
      providerId: json['provider_id'] as String,
      providerEventId: json['provider_event_id'] as String,
      eventType: $enumDecode(_$BillingEventTypeEnumMap, json['event_type']),
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$BillingLedgerEntryToJson(_BillingLedgerEntry instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'entry_id': instance.entryId,
      'user_id': instance.userId,
      'provider_id': instance.providerId,
      'provider_event_id': instance.providerEventId,
      'event_type': _$BillingEventTypeEnumMap[instance.eventType]!,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$BillingEventTypeEnumMap = {
  BillingEventType.purchase: 'purchase',
  BillingEventType.renewal: 'renewal',
  BillingEventType.cancellation: 'cancellation',
  BillingEventType.billingIssue: 'billing_issue',
  BillingEventType.refund: 'refund',
  BillingEventType.restore: 'restore',
};

_EntitlementSnapshot _$EntitlementSnapshotFromJson(Map<String, dynamic> json) =>
    _EntitlementSnapshot(
      schemaVersion:
          json['schema_version'] as String? ??
          kEntitlementSnapshotSchemaVersion,
      userId: json['user_id'] as String,
      status: $enumDecode(_$EntitlementStatusEnumMap, json['status']),
      planId: json['plan_id'] as String,
      sourceLedgerEntryIds:
          (json['source_ledger_entry_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      effectiveAt: DateTime.parse(json['effective_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$EntitlementSnapshotToJson(
  _EntitlementSnapshot instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'user_id': instance.userId,
  'status': _$EntitlementStatusEnumMap[instance.status]!,
  'plan_id': instance.planId,
  'source_ledger_entry_ids': instance.sourceLedgerEntryIds,
  'effective_at': instance.effectiveAt.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
};

const _$EntitlementStatusEnumMap = {
  EntitlementStatus.active: 'active',
  EntitlementStatus.grace: 'grace',
  EntitlementStatus.trial: 'trial',
  EntitlementStatus.expired: 'expired',
  EntitlementStatus.revoked: 'revoked',
};

_EntitlementDecision _$EntitlementDecisionFromJson(Map<String, dynamic> json) =>
    _EntitlementDecision(
      schemaVersion:
          json['schema_version'] as String? ??
          kEntitlementDecisionSchemaVersion,
      decisionId: json['decision_id'] as String,
      allowed: json['allowed'] as bool,
      reasonCode: json['reason_code'] as String,
      policyVersion: json['policy_version'] as String,
      snapshot: EntitlementSnapshot.fromJson(
        json['snapshot'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EntitlementDecisionToJson(
  _EntitlementDecision instance,
) => <String, dynamic>{
  'schema_version': instance.schemaVersion,
  'decision_id': instance.decisionId,
  'allowed': instance.allowed,
  'reason_code': instance.reasonCode,
  'policy_version': instance.policyVersion,
  'snapshot': instance.snapshot.toJson(),
};

_EvidenceAtomView _$EvidenceAtomViewFromJson(Map<String, dynamic> json) =>
    _EvidenceAtomView(
      atomId: json['atom_id'] as String,
      sourceId: json['source_id'] as String,
      text: json['text'] as String,
      evidenceSpans: (json['evidence_spans'] as List<dynamic>)
          .map((e) => EvidenceSpan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EvidenceAtomViewToJson(_EvidenceAtomView instance) =>
    <String, dynamic>{
      'atom_id': instance.atomId,
      'source_id': instance.sourceId,
      'text': instance.text,
      'evidence_spans': instance.evidenceSpans.map((e) => e.toJson()).toList(),
    };
