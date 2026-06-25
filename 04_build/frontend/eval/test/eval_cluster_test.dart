import 'package:test/test.dart';

import 'eval_cluster_test_runner.dart' as cases;

void main() {
  group('Eval Cluster', () {
    test(
      'CorpusRetriever contract: deterministic ordering and registry swappability',
      cases.corpusRetrieverContract,
    );

    test(
      'Corpus bundle and schema guardrails',
      cases.corpusBundleAndSchemaGuardrails,
    );

    test(
      'Backend L5/L6 rubric v0.2 loads as signed seed corpus',
      cases.backendRubricSeedLoads,
    );

    test(
      'Backend L5/L6 rubric v0.2 BM25 retrieves expanded bundles',
      cases.backendRubricV02RetrievalSpotChecks,
    );

    test(
      'Generic rubric verdict maps answer spans to criteria',
      cases.rubricMappedVerdictEngineContract,
    );

    test(
      'Corpus SQLite bundle plan: signed manifest, FTS5, BM25 query',
      cases.corpusSqliteBundlePlanContract,
    );

    test(
      'Per-user memory: provenance required and rows are user-visible/deletable',
      cases.memoryStoreContract,
    );

    test(
      'Per-user memory: row ids are isolated by user',
      cases.memoryUserIsolation,
    );

    test(
      'Per-user memory: tombstone and ordering guardrails',
      cases.memoryGuardrails,
    );

    test(
      'Per-user memory row codec: deterministic Storage Sync handoff',
      cases.memoryRowCodecContract,
    );

    test(
      'Interview engine: capture to evaluation to judgment to render',
      cases.interviewE2eSlice,
    );

    test(
      'Interview engine: missing rubric slice fails before StructuredJudge',
      cases.interviewMissingRubricFailsClosed,
    );

    test(
      'Interview engine: malformed evidence fails before memory writes',
      cases.interviewMalformedEvidenceFailsClosed,
    );

    test(
      'StructuredJudge gateway envelope: strict request compatibility',
      cases.structuredJudgeGatewayEnvelope,
    );

    test('Judgment renderer golden output', cases.judgmentRenderingGolden);

    test(
      '200-answer adjudication set is built and runnable',
      cases.adjudicationSet,
    );
  });
}
