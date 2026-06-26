import 'dart:convert';
import 'dart:io';

import 'package:caliber_eval_backend/caliber_eval_backend.dart';
import 'package:caliber_eval_database/caliber_eval_database.dart';
import 'package:caliber_eval_frontend/caliber_eval_frontend.dart';

Future<void> main() async {
  final tests = <String, Future<void> Function()>{
    'CorpusRetriever contract: deterministic ordering and registry swappability':
        corpusRetrieverContract,
    'Corpus bundle and schema guardrails': corpusBundleAndSchemaGuardrails,
    'Backend L5/L6 rubric v0.2 loads as signed 30-scenario seed corpus':
        backendRubricSeedLoads,
    'Backend L5/L6 rubric v0.2 BM25 retrieves expanded bundles':
        backendRubricV02RetrievalSpotChecks,
    'Generic rubric verdict maps answer spans to criteria':
        rubricMappedVerdictEngineContract,
    'Corpus SQLite bundle plan: signed manifest, FTS5, BM25 query':
        corpusSqliteBundlePlanContract,
    'Per-user memory: provenance required and rows are user-visible/deletable':
        memoryStoreContract,
    'Per-user memory: row ids are isolated by user': memoryUserIsolation,
    'Per-user memory: tombstone and ordering guardrails': memoryGuardrails,
    'Per-user memory row codec: deterministic Storage Sync handoff':
        memoryRowCodecContract,
    'Interview engine: capture to evaluation to judgment to render':
        interviewE2eSlice,
    'Interview engine: missing rubric slice fails before StructuredJudge':
        interviewMissingRubricFailsClosed,
    'Interview engine: malformed evidence fails before memory writes':
        interviewMalformedEvidenceFailsClosed,
    'StructuredJudge gateway envelope: strict request compatibility':
        structuredJudgeGatewayEnvelope,
    'Judgment renderer golden output': judgmentRenderingGolden,
    '200-answer adjudication set is built and runnable': adjudicationSet,
  };

  var passed = 0;
  for (final entry in tests.entries) {
    await entry.value();
    passed += 1;
    stdout.writeln('PASS ${entry.key}');
  }
  stdout.writeln('Eval Cluster tests passed: $passed/${tests.length}');
}

Future<void> corpusRetrieverContract() async {
  final registry = CorpusRetrieverRegistry();
  registry.register(
    'bm25_fts5_local_v1',
    () => Bm25CorpusRetriever(bundle: _buildCorpusBundle()),
  );
  expectEquals(
    <String>['bm25_fts5_local_v1'],
    registry.registeredIds,
    'retriever registry ids',
  );

  final retriever = registry.create('bm25_fts5_local_v1');
  final query = CorpusQuery(
    queryText: 'hash map tradeoffs collision memory',
    roleId: 'backend_engineer',
    domain: 'software',
    levelBand: 'senior',
    companyArchetype: 'product_saas',
    requiredTags: const <String>['interview'],
    limit: 3,
  );
  final first = await retriever.retrieve(query);
  final second = await retriever.retrieve(query);
  expectEquals(
    first.routeHash,
    second.routeHash,
    'same query must keep same route hash',
  );
  expect(
    RegExp(r'^[0-9a-f]{64}$').hasMatch(first.routeHash),
    'route hash must be a Gateway-compatible 64-character hex fingerprint',
  );
  expectEquals(
    first.records.map((record) => record.record.recordId).toList(),
    second.records.map((record) => record.record.recordId).toList(),
    'same query must keep same ordered records',
  );
  expect(
    first.records.isNotEmpty,
    'retrieval must return a fixed corpus subset',
  );
  expect(
    first.evidenceSpans.isNotEmpty,
    'retrieval must return evidence spans',
  );

  final tied = await Bm25CorpusRetriever(bundle: _buildTieBundle()).retrieve(
    CorpusQuery(
      queryText: 'tie breaker identical',
      requiredTags: const <String>['interview'],
      limit: 2,
    ),
  );
  expectEquals(
    <String>['tie_a', 'tie_b'],
    tied.records.map((record) => record.record.recordId).toList(),
    'equal BM25 scores must tie-break by record_id',
  );
}

Future<void> corpusBundleAndSchemaGuardrails() async {
  final registry = CorpusRetrieverRegistry();
  registry.register(
    'bm25_fts5_local_v1',
    () => Bm25CorpusRetriever(bundle: _buildCorpusBundle()),
  );
  expectThrows(
    () => registry.create('missing_retriever'),
    'unknown retriever ids must fail closed',
  );

  final fixture = File(
    '../../backend/fixtures/corpus/caliber_eval_corpus_v001.json',
  ).readAsStringSync();
  final signed = CorpusBundle.fromJsonString(fixture);
  expect(signed.verifySignature(), 'fixture can be signed deterministically');
  expectEquals(
    signed.expectedSignature,
    signed.signature,
    'checked-in fixture carries its deterministic signature',
  );
  expect(
    RegExp(r'^caliber-fnv1a64:[0-9a-f]{16}$').hasMatch(signed.signature),
    'signed corpus fixture uses unsigned 64-bit hex',
  );
  expectEquals(
    <String>['data_structures', 'interview'],
    signed.records.single.tags.toList(),
    'corpus tags are normalized and sorted',
  );

  final emptyQuery = await Bm25CorpusRetriever(bundle: signed).retrieve(
    CorpusQuery(
      queryText: 'hash map',
      roleId: 'mobile_engineer',
      requiredTags: const <String>['interview'],
    ),
  );
  expectEquals(0, emptyQuery.records.length, 'metadata filters are enforced');
  expectEquals(
    0,
    emptyQuery.evidenceSpans.length,
    'empty results have no spans',
  );

  expectEquals(
    'fork/09-storage-sync',
    const StorageSyncCoordinationNote().owner,
    'Storage Sync remains the encryption owner',
  );
  expect(
    const StorageSyncCoordinationNote().evalClusterOwnership.contains(
      'per-user table shape',
    ),
    'coordination note documents Eval Cluster ownership',
  );
  expect(
    UserMemorySchema.requiredColumns(
      UserMemoryTable.targetMatrix,
    ).contains('provenance_json'),
    'target matrix requires provenance column',
  );

  expectThrows(
    () => CorpusBundle(
      bundleVersion: '',
      signature: '',
      records: const <CorpusRecord>[],
    ),
    'empty bundle version rejected',
  );
  expectThrows(
    () => CorpusQuery(queryText: 'bad limit', limit: 0),
    'non-positive retrieval limit rejected',
  );
  expectThrows(
    () => CorpusQuery(queryText: ' '),
    'empty retrieval query rejected',
  );
  expectThrows(() => _minimalRecord(' '), 'empty corpus record id rejected');
  expectThrows(
    () => CorpusRecord(
      recordId: 'empty_body',
      kind: CorpusRecordKind.rubricSlice,
      title: 'Empty body',
      body: ' ',
      corpusBundleVersion: 'corpus_bundle_v001',
    ),
    'empty corpus record body rejected',
  );
  expectThrows(
    () => CorpusEvidenceSpan(
      recordId: 'rubric_hash_map_tradeoffs',
      startOffset: 3,
      endOffset: 3,
      text: 'bad span',
      corpusBundleVersion: 'corpus_bundle_v001',
      score: 1,
    ),
    'zero-length corpus evidence rejected',
  );
  expectThrows(
    () => CorpusBundle.fromJson(<String, Object?>{
      'bundle_version': 'corpus_bundle_v001',
      'signature': 'placeholder',
      'records': const <Object?>[
        <String, Object?>{
          'record_id': 'bad_kind',
          'kind': 'unknown',
          'title': 'Bad kind',
          'body': 'Bad kind',
        },
      ],
    }),
    'unknown corpus record kind rejected',
  );
  expectThrows(
    () => CorpusBundle(
      bundleVersion: 'corpus_bundle_v001',
      signature: 'placeholder',
      records: <CorpusRecord>[
        _minimalRecord('duplicate'),
        _minimalRecord('duplicate'),
      ],
    ),
    'duplicate record ids rejected',
  );
  expectThrows(
    () => CorpusBundle(
      bundleVersion: 'corpus_bundle_v002',
      signature: 'placeholder',
      records: <CorpusRecord>[_minimalRecord('wrong_version')],
    ),
    'record bundle version mismatch rejected',
  );
  final unsignedBundle = CorpusBundle(
    bundleVersion: signed.bundleVersion,
    signature: 'not-${signed.signature}',
    records: signed.records,
  );
  expectThrows(
    () => Bm25CorpusRetriever(bundle: unsignedBundle),
    'retrievers reject unsigned bundles',
  );
}

Future<void> backendRubricSeedLoads() async {
  expectEquals(
    kBackendDepthRubricVersion,
    kBackendDepthRubric.rubricVersion,
    'backend rubric version',
  );
  expectEquals(
    kBackendDepthReplacePolicy,
    kBackendDepthRubric.replacePolicy,
    'backend rubric replace policy',
  );
  expectEquals(
    30,
    kBackendDepthRubric.scenarios.length,
    'backend rubric carries thirty seed scenarios',
  );
  for (final scenario in kBackendDepthRubric.scenarios) {
    expectEquals(
      5,
      scenario.dimensions.length,
      '${scenario.scenarioId} has five dimensions',
    );
    expect(
      scenario.probes.length >= 4 && scenario.probes.length <= 6,
      '${scenario.scenarioId} has deterministic probes',
    );
    expect(
      scenario.commonDownLevelTraps.isNotEmpty &&
          scenario.redFlags.isNotEmpty &&
          scenario.strongExemplarSketch.isNotEmpty &&
          scenario.weakExemplarSketch.isNotEmpty,
      '${scenario.scenarioId} has traps, red flags, and exemplar sketches',
    );
    expect(
      scenario.dimensions.every(
        (dimension) =>
            dimension.l5Anchor.isNotEmpty &&
            dimension.l6Anchor.isNotEmpty &&
            dimension.downLevelSignals.isNotEmpty &&
            dimension.strongExcerpt.isNotEmpty &&
            dimension.weakExcerpt.isNotEmpty &&
            dimension.minimumFix.isNotEmpty,
      ),
      '${scenario.scenarioId} has anchors, down-level signals, excerpts, and fixes',
    );
    expect(
      scenario.sourceEvidence.isNotEmpty,
      '${scenario.scenarioId} carries source evidence provenance',
    );
  }
  final bundle = backendDepthCorpusBundleV02();
  expect(bundle.verifySignature(), 'backend rubric bundle verifies');
  expectEquals(
    kBackendDepthCorpusBundleVersion,
    bundle.bundleVersion,
    'backend rubric corpus bundle version',
  );
  expect(
    bundle.records.every(
      (record) =>
          record.metadata['replace_policy'] == kBackendDepthReplacePolicy &&
          record.metadata['rubric_version'] == kBackendDepthRubricVersion &&
          record.metadata['source_evidence']!.isNotEmpty,
    ),
    'backend rubric records carry replace-never-mutate metadata',
  );
}

Future<void> backendRubricV02RetrievalSpotChecks() async {
  final retriever = Bm25CorpusRetriever(bundle: backendDepthCorpusBundleV02());
  final checks = <(String, String)>[
    (
      'token bucket redis counter store fail open rate limit headers',
      'distributed_rate_limiter_v0_2',
    ),
    (
      'ticket booking optimistic locking reservation timeout virtual queue oversell',
      'ticket_booking_concurrency_v0_2',
    ),
    (
      'code review domain invariant race condition dependency injection blast radius',
      'code_review_debugging_v0_2',
    ),
    (
      'push email sms notification preference template dead letter provider fallback',
      'notification_system_v0_2',
    ),
    (
      'distributed task scheduler cron delayed queue worker lease idempotency clock skew',
      'distributed_task_scheduler_v0_2',
    ),
    (
      'payment transaction idempotency key ledger webhook reconciliation refund',
      'payment_transaction_system_v0_2',
    ),
    (
      'pub sub event system topic subscription offset back pressure dead letter',
      'pub_sub_event_system_v0_2',
    ),
    (
      'food delivery dispatch driver matching geohash location freshness cancellation',
      'food_delivery_dispatch_v0_2',
    ),
    (
      'cache invalidation redis cache-aside thundering herd request coalescing hit rate',
      'caching_strategy_deep_dive_v0_2',
    ),
    (
      'database migration schema evolution expand contract backfill dual write rollback',
      'database_migration_schema_evolution_v0_2',
    ),
    (
      'incident response production 500 errors metrics logs traces blast radius rollback',
      'incident_response_debugging_v0_2',
    ),
    (
      'technical leadership architecture decision stakeholder alignment tradeoff metric hindsight',
      'technical_leadership_decision_v0_2',
    ),
    (
      'api design rest graphql grpc versioning pagination authorization error model',
      'api_design_tradeoffs_v0_2',
    ),
    (
      'observability metrics logs traces alerting slo sli sampling cardinality runbook',
      'observability_system_design_v0_2',
    ),
    (
      'people leadership mentoring coaching conflict resolution feedback team process impact',
      'people_leadership_v0_2',
    ),
  ];

  for (final (queryText, scenarioId) in checks) {
    final result = await retriever.retrieve(
      CorpusQuery(
        queryText: queryText,
        limit: 6,
        roleId: 'backend_engineer',
        domain: 'Backend',
        levelBand: 'L5/L6',
        companyArchetype: 'growth-stage-product',
        requiredTags: const <String>['backend', 'rubric'],
      ),
    );
    expect(
      result.records
          .map((record) => record.record.metadata['scenario_id'])
          .contains(scenarioId),
      'BM25 query "$queryText" retrieves $scenarioId in top 6',
    );
  }
}

Future<void> rubricMappedVerdictEngineContract() async {
  final scenario = kBackendDepthRubric.scenarioForQuestion(
    'backend_depth_rate_limiter_l5_l6_v0_1',
  );
  final verdict = const DeterministicRubricVerdictEngine().evaluate(
    scenario: _rubricScenarioFrom(scenario),
    answer:
        'I would define tenant quotas, burst policy, and latency budget first. '
        'Then I would use a token bucket in Redis with atomic updates because it handles bursts cheaply. '
        'The tradeoff versus sliding windows is less exact fairness. '
        'For login I would fail closed after a timeout, while read-only traffic can fail open. '
        'I would roll out in shadow mode with a quota contract and measure p95 latency and reject rate.',
    rubricVersion: kBackendDepthRubricVersion,
    promptVersion: kBackendDepthPromptVersion,
  );

  expectEquals(
    kBackendDepthRubricVersion,
    verdict.rubricVersion,
    'verdict carries rubric version',
  );
  expectEquals(
    'at_bar',
    verdict.levelRead,
    'strong seed answer with rollout and contract language clears the senior bar',
  );
  expect(
    verdict.findings.every((finding) => finding.quote.isNotEmpty),
    'every finding has an answer quote',
  );
  expect(
    verdict.findings.any(
      (finding) =>
          finding.criterionId == 'failure_modes' &&
          finding.quote.contains('fail closed'),
    ),
    'failure-mode finding quotes the user answer',
  );
  expect(
    verdict.recommendedActions.every((item) => !item.contains('score')),
    'verdict actions do not expose numeric scoring',
  );
}

Future<void> corpusSqliteBundlePlanContract() async {
  const plan = CorpusSqliteBundlePlan();
  final bundle = _buildCorpusBundle();

  expect(
    plan.createStatements.any((statement) => statement.contains('USING fts5')),
    'corpus bundle plan declares an FTS5 virtual table',
  );
  expect(
    plan.createStatements.any(
      (statement) => statement.contains(
        'ON corpus_record (role_id, domain, level_band, company_archetype, record_id)',
      ),
    ),
    'corpus bundle plan declares deterministic metadata filter index',
  );

  final manifest = plan.encodeBundleManifest(
    bundle,
    createdAtUtc: DateTime.utc(2026, 5, 31, 20, 45),
  );
  expectEquals(
    CorpusSqliteBundlePlan.manifestTableName,
    manifest.tableName,
    'bundle manifest table name',
  );
  expectEquals(
    plan.manifestColumns,
    manifest.values.keys.toList(),
    'bundle manifest column order',
  );
  expectEquals(
    manifest.values.values.toList(),
    manifest.arguments,
    'bundle manifest arguments match column order',
  );
  expectEquals(
    bundle.expectedSignature,
    manifest.values['signature'],
    'bundle manifest carries signed bundle signature',
  );

  final bundleRows = plan.encodeBundle(
    bundle,
    createdAtUtc: DateTime.utc(2026, 5, 31, 20, 45),
  );
  expectEquals(
    bundle.expectedSignature,
    bundleRows.manifest.values['signature'],
    'whole-bundle SQLite handoff carries signed manifest',
  );
  expectEquals(
    bundle.records.map((record) => record.recordId).toList(),
    bundleRows.records.map((row) => row.values['record_id']).toList(),
    'whole-bundle SQLite record rows preserve bundle order',
  );
  expectEquals(
    bundle.records.fold<int>(0, (sum, record) => sum + record.tags.length),
    bundleRows.tags.length,
    'whole-bundle SQLite handoff emits every tag row',
  );
  expectEquals(
    bundle.records.length,
    bundleRows.ftsRecords.length,
    'whole-bundle SQLite handoff emits every FTS row',
  );
  expectEquals(
    1 + bundle.records.length + bundleRows.tags.length + bundle.records.length,
    bundleRows.allRows.length,
    'whole-bundle SQLite handoff has deterministic row count',
  );

  final record = CorpusRecord(
    recordId: 'rubric_sqlite_plan',
    kind: CorpusRecordKind.rubricSlice,
    title: 'SQLite corpus storage plan',
    body: 'FTS5 retrieval uses BM25 rank with metadata filters.',
    corpusBundleVersion: 'corpus_bundle_v001',
    roleId: 'backend_engineer',
    domain: 'software',
    levelBand: 'senior',
    companyArchetype: 'product_saas',
    tags: const <String>['Beta', 'alpha'],
    metadata: const <String, String>{
      'z_lane': 'eval_cluster',
      'a_owner': 'module_04',
    },
  );
  final recordRow = plan.encodeRecord(record);
  expectEquals(
    plan.recordColumns,
    recordRow.values.keys.toList(),
    'corpus record column order',
  );
  expectEquals(
    '{"a_owner":"module_04","z_lane":"eval_cluster"}',
    recordRow.values['metadata_json'],
    'corpus metadata JSON is deterministic',
  );
  expectEquals(
    recordRow.values.values.toList(),
    recordRow.arguments,
    'corpus record arguments match column order',
  );

  final tagRows = plan.encodeRecordTags(record);
  expectEquals(
    <String>['alpha', 'beta'],
    tagRows.map((row) => row.values['tag']).toList(),
    'corpus tag rows are normalized and sorted',
  );
  expectEquals(
    <String>['record_id', 'title', 'body', 'tags'],
    plan.encodeFtsRecord(record).values.keys.toList(),
    'FTS row column order',
  );

  final retrievalSql = plan.retrievalSql(requiredTagCount: 2);
  expect(
    retrievalSql.contains('bm25(corpus_record_fts) AS rank'),
    'retrieval SQL exposes FTS5 BM25 rank',
  );
  expect(
    retrievalSql.contains('ORDER BY rank ASC, r.record_id ASC'),
    'retrieval SQL tie-breaks by record_id after BM25 rank',
  );
  expectEquals(
    12,
    '?'.allMatches(retrievalSql).length,
    'retrieval SQL placeholder count with two required tags',
  );
  expectEquals(
    plan.recordColumns.length,
    '?'.allMatches(plan.insertRecordSql).length,
    'record insert placeholders match columns',
  );
  expectThrows(
    () => plan.retrievalSql(requiredTagCount: -1),
    'negative required tag count rejected',
  );
}

Future<void> memoryStoreContract() async {
  final store = InMemoryUserMemoryStore();
  final provenance = _provenance();
  await store.writeEvidence(
    EvidenceLedgerEntry(
      rowId: 'answer_1:strength:0',
      userId: 'user_1',
      provenance: provenance,
      claim: 'Explains collision strategy with concrete tradeoffs.',
      strengthBand: 'strong',
    ),
  );
  await store.writeGap(
    GapLedgerEntry(
      rowId: 'answer_1:gap:0',
      userId: 'user_1',
      provenance: provenance,
      gapLabel: 'Quantify memory overhead',
      severityBand: 'medium',
      remediationHint: 'Add asymptotic and operational constraints.',
    ),
  );
  await store.tombstone(
    userId: 'user_1',
    tableName: UserMemoryTable.gapLedger.tableName,
    rowId: 'answer_1:gap:0',
    tombstone: DeletionTombstone(
      rowId: 'answer_1:gap:0:tombstone',
      userId: 'user_1',
      provenance: provenance,
      deletedTable: UserMemoryTable.gapLedger.tableName,
      deletedRowId: 'answer_1:gap:0',
      deletedAt: DateTime.utc(2026, 5, 31),
    ),
  );

  final snapshot = await store.snapshot('user_1');
  expectEquals(1, snapshot.evidenceLedger.length, 'evidence row visible');
  expectEquals(
    0,
    snapshot.gapLedger.length,
    'deleted row removed from user-visible gaps',
  );
  expectEquals(
    1,
    snapshot.deletionTombstones.length,
    'deletion tombstone retained',
  );

  expectThrows(
    () => Provenance(
      sourceId: 'bad',
      sourceType: 'test',
      schemaVersion: UserMemorySchema.schemaVersion,
      corpusBundleVersion: 'corpus_bundle_v001',
      createdAt: DateTime.utc(2026, 5, 31),
      evidenceSpans: const <CorpusEvidenceSpan>[],
    ),
    'provenance without evidence must be rejected',
  );
}

Future<void> memoryUserIsolation() async {
  final store = InMemoryUserMemoryStore();
  final provenance = _provenance();

  await store.writeEvidence(
    EvidenceLedgerEntry(
      rowId: 'shared_row',
      userId: 'user_a',
      provenance: provenance,
      claim: 'User A owns this row.',
      strengthBand: 'solid',
    ),
  );
  await store.writeEvidence(
    EvidenceLedgerEntry(
      rowId: 'shared_row',
      userId: 'user_b',
      provenance: provenance,
      claim: 'User B owns a same-id row independently.',
      strengthBand: 'strong',
    ),
  );

  final userA = await store.snapshot('user_a');
  final userB = await store.snapshot('user_b');
  expectEquals(1, userA.evidenceLedger.length, 'user A row visible');
  expectEquals(1, userB.evidenceLedger.length, 'user B row visible');
  expectEquals(
    'User A owns this row.',
    userA.evidenceLedger.single.claim,
    'user A same-id row is not overwritten by user B',
  );
  expectEquals(
    'User B owns a same-id row independently.',
    userB.evidenceLedger.single.claim,
    'user B same-id row is isolated',
  );

  await store.tombstone(
    userId: 'user_a',
    tableName: UserMemoryTable.evidenceLedger.tableName,
    rowId: 'shared_row',
    tombstone: DeletionTombstone(
      rowId: 'shared_row:tombstone',
      userId: 'user_a',
      provenance: provenance,
      deletedTable: UserMemoryTable.evidenceLedger.tableName,
      deletedRowId: 'shared_row',
      deletedAt: DateTime.utc(2026, 5, 31, 21),
    ),
  );

  final userAAfterDelete = await store.snapshot('user_a');
  final userBAfterDelete = await store.snapshot('user_b');
  expectEquals(
    0,
    userAAfterDelete.evidenceLedger.length,
    'deleting user A row removes only user A same-id row',
  );
  expectEquals(
    1,
    userBAfterDelete.evidenceLedger.length,
    'deleting user A row preserves user B same-id row',
  );
}

Future<void> memoryGuardrails() async {
  final store = InMemoryUserMemoryStore();
  final provenance = _provenance();

  await store.writeEvidence(
    EvidenceLedgerEntry(
      rowId: 'row_z',
      userId: 'user_ordered',
      provenance: provenance,
      claim: 'Later row sorts after earlier row.',
      strengthBand: 'medium',
    ),
  );
  await store.writeEvidence(
    EvidenceLedgerEntry(
      rowId: 'row_a',
      userId: 'user_ordered',
      provenance: provenance,
      claim: 'Earlier row sorts before later row.',
      strengthBand: 'medium',
    ),
  );
  await store.writeTargetMatrix(
    TargetMatrixCell(
      rowId: 'target_1',
      userId: 'user_ordered',
      provenance: provenance,
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      priority: 1,
    ),
  );

  final snapshot = await store.snapshot('user_ordered');
  expectEquals(
    <String>['row_a', 'row_z'],
    snapshot.evidenceLedger.map((row) => row.rowId).toList(),
    'memory snapshots are deterministic by row id',
  );
  expectEquals(1, snapshot.targetMatrix.length, 'target matrix row persisted');

  expectThrows(
    () => TargetMatrixCell(
      rowId: 'target_bad_priority',
      userId: 'user_ordered',
      provenance: provenance,
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      priority: 0,
    ),
    'target matrix priority must be positive',
  );
  expectThrows(
    () => EvidenceLedgerEntry(
      rowId: 'empty_claim',
      userId: 'user_ordered',
      provenance: provenance,
      claim: ' ',
      strengthBand: 'strong',
    ),
    'empty evidence claims rejected',
  );
  expectThrows(
    () => GapLedgerEntry(
      rowId: 'empty_hint',
      userId: 'user_ordered',
      provenance: provenance,
      gapLabel: 'Quantify memory overhead',
      severityBand: 'medium',
      remediationHint: ' ',
    ),
    'empty gap remediation hints rejected',
  );
  expectThrows(
    () => HistoryEvent(
      rowId: 'empty_event',
      userId: 'user_ordered',
      provenance: provenance,
      eventType: ' ',
      summary: 'Evaluated answer.',
    ),
    'empty history event types rejected',
  );
  expectThrows(
    () => SpeakingProfile(
      rowId: 'bad_delivery',
      userId: 'user_ordered',
      provenance: provenance,
      wordsPerMinute: 132.5,
      pauseCount: 1,
      fillerRatio: 1.1,
    ),
    'speaking profile filler ratio must be bounded',
  );
  expectThrows(
    () => DeletionTombstone(
      rowId: 'empty_deleted_row',
      userId: 'user_ordered',
      provenance: provenance,
      deletedTable: UserMemoryTable.evidenceLedger.tableName,
      deletedRowId: ' ',
      deletedAt: DateTime.utc(2026, 5, 31),
    ),
    'tombstones must identify the deleted row',
  );

  await expectThrowsAsync(
    () => store.tombstone(
      userId: 'user_ordered',
      tableName: UserMemoryTable.evidenceLedger.tableName,
      rowId: 'row_a',
      tombstone: DeletionTombstone(
        rowId: 'bad_user_tombstone',
        userId: 'another_user',
        provenance: provenance,
        deletedTable: UserMemoryTable.evidenceLedger.tableName,
        deletedRowId: 'row_a',
        deletedAt: DateTime.utc(2026, 5, 31),
      ),
    ),
    'tombstone user mismatch rejected',
  );
  await expectThrowsAsync(
    () => store.tombstone(
      userId: 'user_ordered',
      tableName: 'unknown_table',
      rowId: 'row_a',
      tombstone: DeletionTombstone(
        rowId: 'bad_table_tombstone',
        userId: 'user_ordered',
        provenance: provenance,
        deletedTable: 'unknown_table',
        deletedRowId: 'row_a',
        deletedAt: DateTime.utc(2026, 5, 31),
      ),
    ),
    'unknown memory table rejected',
  );
}

Future<void> memoryRowCodecContract() async {
  final codec = UserMemoryRowCodec();
  const sqlPlan = UserMemorySqlPlan();
  final provenance = Provenance(
    sourceId: 'judgment_codec',
    sourceType: 'interview_content_judgment',
    schemaVersion: UserMemorySchema.schemaVersion,
    corpusBundleVersion: 'corpus_bundle_v001',
    createdAt: DateTime.utc(2026, 5, 31, 20, 15),
    evidenceSpans: <CorpusEvidenceSpan>[
      CorpusEvidenceSpan(
        recordId: 'rubric_hash_map_tradeoffs',
        startOffset: 0,
        endOffset: 75,
        text:
            'Strong answers compare hash maps with ordered indexes and name collision handling.',
        corpusBundleVersion: 'corpus_bundle_v001',
        score: 2.5,
      ),
    ],
    metadata: const <String, String>{
      'z_lane': 'eval_cluster',
      'a_owner': 'module_05',
    },
  );

  final rows = <UserMemoryRow>[
    TargetMatrixCell(
      rowId: 'target_1',
      userId: 'user_codec',
      provenance: provenance,
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      priority: 1,
    ),
    EvidenceLedgerEntry(
      rowId: 'evidence_1',
      userId: 'user_codec',
      provenance: provenance,
      claim: 'Names collision handling.',
      strengthBand: 'strong',
    ),
    GapLedgerEntry(
      rowId: 'gap_1',
      userId: 'user_codec',
      provenance: provenance,
      gapLabel: 'Quantify memory overhead',
      severityBand: 'medium',
      remediationHint: 'Add measured constraints.',
    ),
    HistoryEvent(
      rowId: 'history_1',
      userId: 'user_codec',
      provenance: provenance,
      eventType: 'interview_evaluated',
      summary: 'Evaluated hash map tradeoff answer.',
    ),
    SpeakingProfile(
      rowId: 'speaking_1',
      userId: 'user_codec',
      provenance: provenance,
      wordsPerMinute: 132.5,
      pauseCount: 1,
      fillerRatio: 0.0123,
    ),
    DeletionTombstone(
      rowId: 'tombstone_1',
      userId: 'user_codec',
      provenance: provenance,
      deletedTable: UserMemoryTable.gapLedger.tableName,
      deletedRowId: 'gap_1',
      deletedAt: DateTime.utc(2026, 5, 31, 20, 20),
    ),
  ];

  for (final row in rows) {
    final encoded = codec.encode(row);
    final tablePlan = sqlPlan.tablePlan(encoded.table);
    expectEquals(
      UserMemorySchema.requiredColumns(encoded.table),
      encoded.values.keys.toList(),
      '${encoded.tableName} encoded columns match schema order',
    );
    expectEquals(
      encoded.values.keys.toList(),
      tablePlan.columns.toList(),
      '${encoded.tableName} SQL plan columns match encoded order',
    );
    expectEquals(
      encoded.values.values.toList(),
      encoded.arguments,
      '${encoded.tableName} insert arguments match encoded order',
    );
    expectEquals(
      encoded.arguments.length,
      '?'.allMatches(tablePlan.upsertSql).length,
      '${encoded.tableName} upsert placeholders match encoded arguments',
    );
    expect(
      tablePlan.createTableSql.contains('PRIMARY KEY (user_id, row_id)'),
      '${encoded.tableName} DDL scopes primary key by user and row',
    );
    expect(
      !tablePlan.createTableSql.contains('row_id TEXT NOT NULL PRIMARY KEY'),
      '${encoded.tableName} DDL does not make row_id globally unique',
    );
    expect(
      tablePlan.upsertSql.contains('ON CONFLICT(user_id, row_id)'),
      '${encoded.tableName} upsert conflict target is user-scoped',
    );
    expect(
      tablePlan.createUserIndexSql.contains('user_id'),
      '${encoded.tableName} DDL has a user index',
    );

    final provenanceJson =
        jsonDecode(encoded.values['provenance_json']! as String)
            as Map<String, Object?>;
    expectEquals(
      <String>['a_owner', 'z_lane'],
      (provenanceJson['metadata']! as Map<String, Object?>).keys.toList(),
      '${encoded.tableName} provenance metadata is deterministic',
    );
    expectEquals(
      'user_memory_schema_v001',
      provenanceJson['schema_version'],
      '${encoded.tableName} provenance carries schema version',
    );
  }

  expectEquals(
    UserMemoryTable.targetMatrix.tableName,
    codec.encode(rows.first).tableName,
    'target matrix table name exported for Storage Sync',
  );
  expectEquals(
    UserMemoryTable.values.length,
    sqlPlan.tables.length,
    'SQL plan exposes every memory table',
  );
  expect(
    sqlPlan.tablePlan(UserMemoryTable.deletionTombstone).deleteVisibleRowSql ==
        'DELETE FROM deletion_tombstone WHERE user_id = ? AND row_id = ?;',
    'delete SQL stays deterministic',
  );
}

Future<void> interviewE2eSlice() async {
  final corpus = Bm25CorpusRetriever(bundle: _buildCorpusBundle());
  final judge = _FakeStructuredJudge();
  final store = InMemoryUserMemoryStore();
  final engine = InterviewEvaluationEngine(
    corpusRetriever: corpus,
    structuredJudge: judge,
    memoryStore: store,
  );

  expectThrows(
    () => TranscriptSegment(
      segmentId: 'blank_text',
      text: ' ',
      startMillis: 0,
      endMillis: 1,
    ),
    'empty transcript text rejected',
  );
  expectThrows(
    () => TranscriptSegment(
      segmentId: 'zero_duration',
      text: 'answer',
      startMillis: 10,
      endMillis: 10,
    ),
    'zero-duration transcript segment rejected',
  );
  expectThrows(
    () => InterviewAnswer(
      answerId: 'bad_answer',
      userId: 'user_1',
      questionId: 'hash_map_design',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      segments: <TranscriptSegment>[
        TranscriptSegment(
          segmentId: 'seg_late',
          text: 'later',
          startMillis: 1000,
          endMillis: 2000,
        ),
        TranscriptSegment(
          segmentId: 'seg_overlap',
          text: 'overlap',
          startMillis: 1500,
          endMillis: 2500,
        ),
      ],
    ),
    'overlapping transcript segments rejected',
  );
  expectThrows(
    () => InterviewAnswer(
      answerId: ' ',
      userId: 'user_1',
      questionId: 'hash_map_design',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      segments: <TranscriptSegment>[
        TranscriptSegment(
          segmentId: 'seg_1',
          text: 'answer',
          startMillis: 0,
          endMillis: 1000,
        ),
      ],
    ),
    'empty interview answer id rejected',
  );

  final evaluation = await engine.evaluate(
    InterviewAnswer(
      answerId: 'answer_1',
      userId: 'user_1',
      questionId: 'hash_map_design',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      segments: <TranscriptSegment>[
        TranscriptSegment(
          segmentId: 'seg_1',
          text:
              'I would use a hash map with chaining, but explain collision tradeoffs, memory overhead,',
          startMillis: 0,
          endMillis: 6000,
        ),
        TranscriptSegment(
          segmentId: 'seg_2',
          text: 'and when a sorted structure is better for range queries.',
          startMillis: 7200,
          endMillis: 11000,
        ),
      ],
    ),
  );

  expectEquals(1, judge.calls, 'StructuredJudge must be called exactly once');
  expectEquals(
    'hash_map_design',
    judge.lastRequest?.questionId,
    'StructuredJudge request carries Schema Core question id',
  );
  expectEquals(
    'interview_rubric_v001',
    judge.lastRequest?.rubricVersion,
    'StructuredJudge request carries Schema Core rubric version',
  );
  expect(
    evaluation.corpus.records.isNotEmpty,
    'evaluation must include a fixed corpus subset',
  );
  expect(
    evaluation.renderedJudgment.contains('## Evidence'),
    'rendered judgment includes evidence section',
  );

  final snapshot = await store.snapshot('user_1');
  expectEquals(1, snapshot.targetMatrix.length, 'target matrix persisted');
  expectEquals(
    <Object?>['backend_engineer', 'software', 'senior', 'product_saas', 3],
    <Object?>[
      snapshot.targetMatrix.single.roleId,
      snapshot.targetMatrix.single.domain,
      snapshot.targetMatrix.single.levelBand,
      snapshot.targetMatrix.single.companyArchetype,
      snapshot.targetMatrix.single.priority,
    ],
    'target matrix mirrors answer context and calibrated band priority',
  );
  expectEquals(1, snapshot.historyEvents.length, 'history event persisted');
  expectEquals(1, snapshot.evidenceLedger.length, 'evidence ledger persisted');
  expectEquals(1, snapshot.gapLedger.length, 'gap ledger persisted');
  expectEquals(
    1,
    snapshot.speakingProfiles.length,
    'delivery profile persisted',
  );
}

Future<void> interviewMissingRubricFailsClosed() async {
  final corpus = Bm25CorpusRetriever(bundle: _buildNoRubricBundle());
  final judge = _FakeStructuredJudge();
  final store = InMemoryUserMemoryStore();
  final engine = InterviewEvaluationEngine(
    corpusRetriever: corpus,
    structuredJudge: judge,
    memoryStore: store,
  );

  await expectThrowsAsync(
    () => engine.evaluate(
      InterviewAnswer(
        answerId: 'answer_no_rubric',
        userId: 'user_no_rubric',
        questionId: 'hash_map_design',
        roleId: 'backend_engineer',
        domain: 'software',
        levelBand: 'senior',
        companyArchetype: 'product_saas',
        segments: <TranscriptSegment>[
          TranscriptSegment(
            segmentId: 'seg_1',
            text:
                'I would discuss hash map collision tradeoffs and memory overhead.',
            startMillis: 0,
            endMillis: 5000,
          ),
        ],
      ),
    ),
    'corpus subsets without a rubric_slice must fail before judging',
  );
  expectEquals(
    0,
    judge.calls,
    'StructuredJudge is not called without a rubric_slice scaffold',
  );
  final snapshot = await store.snapshot('user_no_rubric');
  expectEquals(
    0,
    snapshot.historyEvents.length,
    'no judgment history persists when rubric_slice is missing',
  );
}

Future<void> interviewMalformedEvidenceFailsClosed() async {
  final corpus = Bm25CorpusRetriever(bundle: _buildCorpusBundle());
  final judge = _TamperedEvidenceStructuredJudge((evidence) {
    return CorpusEvidenceSpan(
      recordId: evidence.recordId,
      startOffset: evidence.startOffset,
      endOffset: evidence.endOffset,
      text: evidence.text,
      corpusBundleVersion: 'corpus_bundle_v999',
      score: evidence.score,
    );
  });
  final store = InMemoryUserMemoryStore();
  final engine = InterviewEvaluationEngine(
    corpusRetriever: corpus,
    structuredJudge: judge,
    memoryStore: store,
  );

  await expectThrowsAsync(
    () => engine.evaluate(
      InterviewAnswer(
        answerId: 'answer_bad_evidence',
        userId: 'user_bad_evidence',
        questionId: 'hash_map_design',
        roleId: 'backend_engineer',
        domain: 'software',
        levelBand: 'senior',
        companyArchetype: 'product_saas',
        segments: <TranscriptSegment>[
          TranscriptSegment(
            segmentId: 'seg_1',
            text:
                'I would compare hash map collision handling and memory overhead.',
            startMillis: 0,
            endMillis: 5000,
          ),
        ],
      ),
    ),
    'malformed evidence spans must fail before memory persistence',
  );
  expectEquals(
    1,
    judge.calls,
    'StructuredJudge is called once before evidence validation rejects output',
  );
  final snapshot = await store.snapshot('user_bad_evidence');
  expectEquals(
    0,
    snapshot.historyEvents.length,
    'no history row persists when evidence validation fails',
  );
  expectEquals(
    0,
    snapshot.targetMatrix.length,
    'no target row persists when evidence validation fails',
  );
}

Future<void> structuredJudgeGatewayEnvelope() async {
  final corpus = await Bm25CorpusRetriever(bundle: _buildCorpusBundle())
      .retrieve(
        CorpusQuery(
          queryText: 'hash map collision memory overhead',
          roleId: 'backend_engineer',
          domain: 'software',
          levelBand: 'senior',
          companyArchetype: 'product_saas',
          requiredTags: const <String>['interview'],
          limit: 4,
        ),
      );
  StructuredJudgeRequest buildGatewayRequest({
    String normalizedAnswer =
        'I compare hash maps, collision handling, and memory overhead.',
    String? routeHash,
  }) {
    return StructuredJudgeRequest(
      answerId: 'answer_gateway',
      questionId: 'hash_map_design',
      normalizedAnswer: normalizedAnswer,
      schemaVersion: 'interview_content_judgment_v001',
      rubricVersion: 'interview_rubric_v001',
      promptVersion: 'interview_prompt_v001',
      corpusBundleVersion: corpus.corpusBundleVersion,
      routingPolicyVersion: 'routing_policy_v001',
      routeHash: routeHash ?? corpus.routeHash,
      fixedCorpusSubset: corpus.records,
    );
  }

  expectThrows(
    () => buildGatewayRequest(routeHash: 'route_gateway'),
    'StructuredJudgeRequest rejects noncanonical route hashes',
  );
  expectThrows(
    () => buildGatewayRequest(normalizedAnswer: ' '),
    'StructuredJudgeRequest requires a normalized answer',
  );

  final request = buildGatewayRequest();
  final envelope = GatewayJudgeRequestEnvelope.fromStructuredJudgeRequest(
    request,
    role: 'Senior backend engineer',
    userContext: const <String, Object?>{'privacy_mode': 'local_only'},
  );
  final json = envelope.toJson();

  expectEquals(
    <String>[
      'schema_version',
      'prompt_version',
      'corpus_bundle_version',
      'routing_policy_version',
      'feature',
      'role',
      'rubric',
      'answer',
      'evidence',
      'user_context',
    ],
    json.keys.toList(),
    'gateway JudgeRequest keys match Fork 03 strict model',
  );
  expectEquals(
    'interview_content',
    json['feature'],
    'gateway feature stays interview_content',
  );
  expect(
    !json.containsKey('model_id'),
    'gateway request does not smuggle product model ids',
  );
  final rubric = json['rubric']! as Map<String, Object?>;
  expectEquals(
    request.routeHash,
    rubric['route_hash'],
    'gateway rubric carries Eval Cluster route hash',
  );
  expect(
    RegExp(r'^[0-9a-f]{64}$').hasMatch(request.routeHash),
    'gateway rubric route hash stays 64-character hex',
  );
  expectEquals(
    'hash_map_design',
    rubric['question_id'],
    'gateway rubric carries Schema Core question id',
  );
  expectEquals(
    'interview_rubric_v001',
    rubric['rubric_version'],
    'gateway rubric carries Schema Core rubric version',
  );
  expectEquals(
    corpus.records.map((record) => record.record.recordId).toList(),
    (rubric['records']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((record) => record['record_id'])
        .toList(),
    'gateway rubric preserves fixed corpus subset order',
  );
  expectEquals(
    1,
    (rubric['rubric_slices']! as List<Object?>).length,
    'gateway rubric includes the required rubric_slice scaffold',
  );
  final evidence = (json['evidence']! as List<Object?>)
      .cast<Map<String, Object?>>();
  expect(evidence.isNotEmpty, 'gateway evidence is non-empty');
  expectEquals(
    <String>['source_id', 'start', 'end', 'text'],
    evidence.first.keys.toList(),
    'gateway evidence keys match Fork 03 strict model',
  );
  expectEquals(
    corpus.evidenceSpans.map((span) => span.recordId).toList(),
    evidence.map((item) => item['source_id']).toList(),
    'gateway evidence comes only from fixed corpus subset spans',
  );

  expectThrows(
    () => GatewayEvidenceInput(
      sourceId: 'bad',
      start: 3,
      end: 3,
      text: 'bad offset',
    ),
    'gateway evidence rejects zero-length offsets',
  );
}

Future<void> judgmentRenderingGolden() async {
  final renderer = JudgmentRenderer();
  const goldenRouteHash =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
  InterviewContentJudgment buildJudgment(
    String routeHash, {
    String judgmentId = 'judgment_golden',
    String summary =
        'The answer explains tradeoffs and anchors its claim in the rubric slice.',
    Iterable<String> strengths = const <String>['Clear tradeoff framing'],
    Iterable<String> gaps = const <String>[
      'Add measurable latency constraints',
    ],
  }) => InterviewContentJudgment(
    judgmentId: judgmentId,
    answerId: 'answer_golden',
    schemaVersion: 'interview_content_judgment_v001',
    promptVersion: 'interview_prompt_v001',
    corpusBundleVersion: 'corpus_bundle_v001',
    routingPolicyVersion: 'routing_policy_v001',
    modelId: 'gpt-5.4-mini',
    routeHash: routeHash,
    band: 'strong',
    summary: summary,
    strengths: strengths,
    gaps: gaps,
    evidenceSpans: <CorpusEvidenceSpan>[
      CorpusEvidenceSpan(
        recordId: 'rubric_hash_map_tradeoffs',
        startOffset: 0,
        endOffset: 75,
        text:
            'Strong answers compare hash maps with ordered indexes and name collision handling.',
        corpusBundleVersion: 'corpus_bundle_v001',
        score: 2.5,
      ),
    ],
  );

  expectThrows(
    () => buildJudgment('route_golden'),
    'judgment route hash must be Gateway-compatible',
  );
  expectThrows(
    () => buildJudgment(goldenRouteHash, judgmentId: ' '),
    'judgment id must be non-empty',
  );
  expectThrows(
    () => buildJudgment(goldenRouteHash, summary: ' '),
    'judgment summary must be non-empty',
  );
  expectThrows(
    () => buildJudgment(goldenRouteHash, strengths: const <String>[]),
    'judgment strengths must be non-empty',
  );
  expectThrows(
    () => buildJudgment(goldenRouteHash, gaps: const <String>[' ']),
    'judgment gaps cannot contain blanks',
  );

  final rendered = renderer.render(
    buildJudgment(goldenRouteHash),
    InterviewDeliveryProfile(
      answerId: 'answer_golden',
      wordsPerMinute: 132.5,
      pauseCount: 1,
      fillerRatio: 0.0123,
      durationMillis: 12000,
    ),
  );

  final golden = File(
    'test/goldens/interview_judgment.md',
  ).readAsStringSync().trimRight();
  expectEquals(golden, rendered, 'judgment rendering golden');

  expectThrows(
    () => InterviewDeliveryProfile(
      answerId: 'answer_bad_delivery',
      wordsPerMinute: 132.5,
      pauseCount: 1,
      fillerRatio: -0.1,
      durationMillis: 12000,
    ),
    'delivery profile filler ratio must be bounded',
  );
}

Future<void> adjudicationSet() async {
  final set = AdjudicationSetFactory().build200AnswerSet();
  expectEquals(200, set.length, 'adjudication set size');
  expectEquals(
    200,
    set.map((item) => item.caseId).toSet().length,
    'adjudication case ids unique',
  );
  expect(
    set.every((item) => item.seniorReviewerLabels.length == 2),
    'each adjudication case must have two senior reviewer labels',
  );
}

final class _FakeStructuredJudge implements StructuredJudge {
  int calls = 0;
  StructuredJudgeRequest? lastRequest;

  @override
  Future<InterviewContentJudgment> judgeInterviewContent(
    StructuredJudgeRequest request,
  ) async {
    calls += 1;
    lastRequest = request;
    final evidence = request.fixedCorpusSubset.first.evidenceSpans.first;
    return InterviewContentJudgment(
      judgmentId: '${request.answerId}:judgment',
      answerId: request.answerId,
      schemaVersion: request.schemaVersion,
      promptVersion: request.promptVersion,
      corpusBundleVersion: request.corpusBundleVersion,
      routingPolicyVersion: request.routingPolicyVersion,
      modelId: 'gpt-5.4-mini',
      routeHash: request.routeHash,
      band: 'strong',
      summary:
          'The answer names tradeoffs and connects them to operational constraints.',
      strengths: const <String>[
        'Explains the hash map tradeoff instead of reciting syntax.',
      ],
      gaps: const <String>['Quantify memory and latency under load.'],
      evidenceSpans: <CorpusEvidenceSpan>[evidence],
    );
  }
}

final class _TamperedEvidenceStructuredJudge implements StructuredJudge {
  _TamperedEvidenceStructuredJudge(this.tamper);

  final CorpusEvidenceSpan Function(CorpusEvidenceSpan evidence) tamper;
  int calls = 0;

  @override
  Future<InterviewContentJudgment> judgeInterviewContent(
    StructuredJudgeRequest request,
  ) async {
    calls += 1;
    final evidence = tamper(
      request.fixedCorpusSubset.first.evidenceSpans.first,
    );
    return InterviewContentJudgment(
      judgmentId: '${request.answerId}:judgment',
      answerId: request.answerId,
      schemaVersion: request.schemaVersion,
      promptVersion: request.promptVersion,
      corpusBundleVersion: request.corpusBundleVersion,
      routingPolicyVersion: request.routingPolicyVersion,
      modelId: 'gpt-5.4-mini',
      routeHash: request.routeHash,
      band: 'strong',
      summary: 'The answer has malformed evidence that must be rejected.',
      strengths: const <String>['Mentions tradeoffs.'],
      gaps: const <String>['Evidence is malformed.'],
      evidenceSpans: <CorpusEvidenceSpan>[evidence],
    );
  }
}

CorpusBundle _buildCorpusBundle() {
  final records = <CorpusRecord>[
    CorpusRecord(
      recordId: 'rubric_hash_map_tradeoffs',
      kind: CorpusRecordKind.rubricSlice,
      title: 'Hash map tradeoff rubric',
      body:
          'Strong answers compare hash maps with ordered indexes, describe collision handling, '
          'and quantify memory overhead before choosing the data structure.',
      corpusBundleVersion: 'corpus_bundle_v001',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      tags: const <String>['interview', 'data_structures'],
    ),
    CorpusRecord(
      recordId: 'benchmark_hash_map_answer',
      kind: CorpusRecordKind.benchmarkAnswer,
      title: 'Benchmark answer for hash map design',
      body:
          'A calibrated answer discusses collision strategy, load factor, resizing costs, '
          'and when a tree or sorted index is more appropriate.',
      corpusBundleVersion: 'corpus_bundle_v001',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      tags: const <String>['interview', 'benchmark'],
    ),
    CorpusRecord(
      recordId: 'glossary_load_factor',
      kind: CorpusRecordKind.glossaryTerm,
      title: 'Load factor',
      body:
          'Load factor is the ratio of stored entries to buckets; it drives collision rate and resize policy.',
      corpusBundleVersion: 'corpus_bundle_v001',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      tags: const <String>['interview', 'glossary'],
    ),
  ];
  final draft = CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: '',
    records: records,
  );
  return CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: draft.expectedSignature,
    records: records,
  );
}

CorpusBundle _buildTieBundle() {
  final records = <CorpusRecord>[
    CorpusRecord(
      recordId: 'tie_b',
      kind: CorpusRecordKind.rubricSlice,
      title: 'Tie B',
      body: 'Tie breaker identical evidence for retrieval order.',
      corpusBundleVersion: 'corpus_bundle_v001',
      tags: const <String>['interview'],
    ),
    CorpusRecord(
      recordId: 'tie_a',
      kind: CorpusRecordKind.rubricSlice,
      title: 'Tie A',
      body: 'Tie breaker identical evidence for retrieval order.',
      corpusBundleVersion: 'corpus_bundle_v001',
      tags: const <String>['interview'],
    ),
  ];
  final draft = CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: '',
    records: records,
  );
  return CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: draft.expectedSignature,
    records: records,
  );
}

CorpusBundle _buildNoRubricBundle() {
  final records = <CorpusRecord>[
    CorpusRecord(
      recordId: 'benchmark_without_rubric',
      kind: CorpusRecordKind.benchmarkAnswer,
      title: 'Benchmark without rubric',
      body:
          'A calibrated answer discusses hash map collision strategy and memory overhead.',
      corpusBundleVersion: 'corpus_bundle_v001',
      roleId: 'backend_engineer',
      domain: 'software',
      levelBand: 'senior',
      companyArchetype: 'product_saas',
      tags: const <String>['interview', 'benchmark'],
    ),
  ];
  final draft = CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: '',
    records: records,
  );
  return CorpusBundle(
    bundleVersion: 'corpus_bundle_v001',
    signature: draft.expectedSignature,
    records: records,
  );
}

CorpusRecord _minimalRecord(String recordId) {
  return CorpusRecord(
    recordId: recordId,
    kind: CorpusRecordKind.rubricSlice,
    title: 'Minimal $recordId',
    body: 'Minimal record body for guardrail tests.',
    corpusBundleVersion: 'corpus_bundle_v001',
    tags: const <String>['interview'],
  );
}

RubricScenario _rubricScenarioFrom(BackendRubricScenario scenario) {
  return RubricScenario(
    questionId: scenario.questionId,
    title: scenario.title,
    prompt: scenario.prompt,
    criteria: <RubricCriterion>[
      for (final dimension in scenario.dimensions)
        RubricCriterion(
          criterionId: dimension.dimensionId,
          label: dimension.label,
          judgmentFocus: dimension.judgmentFocus,
          l5Anchor: dimension.l5Anchor,
          l6Anchor: dimension.l6Anchor,
          downLevelSignals: dimension.downLevelSignals,
          expectedSignals: dimension.expectedSignals,
          advancedSignals: dimension.advancedSignals,
          minimumFix: dimension.minimumFix,
        ),
    ],
  );
}

Provenance _provenance() {
  return Provenance(
    sourceId: 'judgment_1',
    sourceType: 'interview_content_judgment',
    schemaVersion: UserMemorySchema.schemaVersion,
    corpusBundleVersion: 'corpus_bundle_v001',
    createdAt: DateTime.utc(2026, 5, 31),
    evidenceSpans: <CorpusEvidenceSpan>[
      CorpusEvidenceSpan(
        recordId: 'rubric_hash_map_tradeoffs',
        startOffset: 0,
        endOffset: 75,
        text:
            'Strong answers compare hash maps with ordered indexes and name collision handling.',
        corpusBundleVersion: 'corpus_bundle_v001',
        score: 2.5,
      ),
    ],
  );
}

void expect(bool condition, String message) {
  if (!condition) {
    throw StateError('Expectation failed: $message');
  }
}

void expectEquals(Object? expected, Object? actual, String message) {
  final matches = expected is Iterable && actual is Iterable
      ? _iterableEquals(expected.toList(), actual.toList())
      : expected == actual;
  if (!matches) {
    throw StateError(
      'Expectation failed: $message\nExpected: $expected\nActual:   $actual',
    );
  }
}

bool _iterableEquals(List<Object?> expected, List<Object?> actual) {
  if (expected.length != actual.length) return false;
  for (var index = 0; index < expected.length; index += 1) {
    if (expected[index] != actual[index]) return false;
  }
  return true;
}

void expectThrows(void Function() callback, String message) {
  try {
    callback();
  } catch (_) {
    return;
  }
  throw StateError('Expectation failed: $message');
}

Future<void> expectThrowsAsync(
  Future<void> Function() callback,
  String message,
) async {
  try {
    await callback();
  } catch (_) {
    return;
  }
  throw StateError('Expectation failed: $message');
}
