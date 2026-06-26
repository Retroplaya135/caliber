import 'package:caliber_shared/caliber_shared.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  group('swappable interface contracts', () {
    test('StructuredJudge implementation returns frozen AI outputs', () async {
      final fixtures = loadGoldenFixtures();
      final judge = _FakeStructuredJudge(fixtures);

      final judgment = await judge.judgeInterviewContent(
        profile: ProfileIdentity.fromJson(
          fixtureMap(fixtures, 'profile_identity'),
        ),
        target: TargetRoleCompany.fromJson(
          fixtureMap(fixtures, 'target_role_company'),
        ),
        transcript: Transcript.fromJson(fixtureMap(fixtures, 'transcript')),
        questionId: 'q-1',
        rubricVersion: 'interview-rubric.v1',
        promptVersion: 'interview-content-prompt.v1',
      );
      final bullet = await judge.rewriteResumeBullet(
        document: ResumeDocument.fromJson(
          fixtureMap(fixtures, 'resume_document'),
        ),
        target: TargetRoleCompany.fromJson(
          fixtureMap(fixtures, 'target_role_company'),
        ),
        sourceEvidence: EvidenceAtom.fromJson(
          fixtureMap(fixtures, 'evidence_atom'),
        ),
        rewritePolicyVersion: 'resume-rewrite.v1',
        promptVersion: 'resume-bullet-prompt.v1',
      );
      final ats = await judge.analyzeAts(
        document: ResumeDocument.fromJson(
          fixtureMap(fixtures, 'resume_document'),
        ),
        target: TargetRoleCompany.fromJson(
          fixtureMap(fixtures, 'target_role_company'),
        ),
        atsTestMatrixVersion: 'ats-matrix.v1',
        keywordMatchVersion: 'rapidfuzz-policy.v1',
      );

      expect(judgment.schemaVersion, kInterviewContentJudgmentSchemaVersion);
      expect(bullet.schemaVersion, kResumeBulletSchemaVersion);
      expect(ats.schemaVersion, kAtsReportV2SchemaVersion);
    });

    test('ATSReportV2 contract fixture stays score-free', () {
      final ats = ATSReportV2.fromJson(
        fixtureMap(loadGoldenFixtures(), 'ats_report'),
      );
      final json = ats.toJson();

      expect(ats.schemaVersion, kAtsReportV2SchemaVersion);
      expect(json.keys.where((key) => key.contains('score')), isEmpty);
      expect(ats.extractableFields, isNotEmpty);
      expect(ats.matchedKeywords, isNotEmpty);
      expect(ats.coverageGaps, isNotEmpty);
      expect(ats.reasoning, isNotEmpty);
    });

    test('TranscriptionEngine returns canonical Transcript shape', () async {
      final engine = _FakeTranscriptionEngine(loadGoldenFixtures());
      final transcript = await engine.transcribe(
        file: 'file:///local/interview.wav',
        locale: 'en-US',
        glossary: <String>['API'],
        privacyMode: PrivacyMode.localOnly,
      );

      expect(transcript.engineId, 'whisper-cpp');
      expect(transcript.schemaVersion, kTranscriptSchemaVersion);
    });

    test('CorpusRetriever returns versioned retrieval result', () async {
      final fixtures = loadGoldenFixtures();
      final retriever = _FakeCorpusRetriever(fixtures);
      final result = await retriever.retrieve(
        CorpusQuery.fromJson(fixtureMap(fixtures, 'corpus_query')),
      );

      expect(result.schemaVersion, kCorpusRetrievalResultSchemaVersion);
      expect(result.hits, isNotEmpty);
    });

    test('BillingProvider and EntitlementPolicy remain swappable', () async {
      final fixtures = loadGoldenFixtures();
      final provider = _FakeBillingProvider(fixtures);
      final policy = _FakeEntitlementPolicy(fixtures);

      final entry = await provider.record(
        BillingLedgerEntry.fromJson(
          fixtureMap(fixtures, 'billing_ledger_entry'),
        ),
      );
      final snapshot = await provider.currentEntitlement(userId: 'user-1');
      final decision = policy.evaluate(
        snapshot: snapshot,
        featureKey: 'resume_review',
        policyVersion: 'entitlement-policy.v1',
        evaluatedAt: DateTime.utc(2026, 5, 31, 20, 50),
      );

      expect(entry.schemaVersion, kBillingLedgerEntrySchemaVersion);
      expect(snapshot.schemaVersion, kEntitlementSnapshotSchemaVersion);
      expect(decision.allowed, isTrue);
    });
  });
}

class _FakeStructuredJudge implements StructuredJudge {
  const _FakeStructuredJudge(this.fixtures);

  final Map<String, Object?> fixtures;

  @override
  Future<ATSReportV2> analyzeAts({
    required ResumeDocument document,
    required TargetRoleCompany target,
    required String atsTestMatrixVersion,
    required String keywordMatchVersion,
  }) async => ATSReportV2.fromJson(fixtureMap(fixtures, 'ats_report'));

  @override
  Future<InterviewContentJudgment> judgeInterviewContent({
    required ProfileIdentity profile,
    required TargetRoleCompany target,
    required Transcript transcript,
    required String questionId,
    required String rubricVersion,
    required String promptVersion,
  }) async => InterviewContentJudgment.fromJson(
    fixtureMap(fixtures, 'interview_content_judgment'),
  );

  @override
  Future<ResumeBullet> rewriteResumeBullet({
    required ResumeDocument document,
    required TargetRoleCompany target,
    required EvidenceAtom sourceEvidence,
    required String rewritePolicyVersion,
    required String promptVersion,
  }) async => ResumeBullet.fromJson(fixtureMap(fixtures, 'resume_bullet'));
}

class _FakeTranscriptionEngine implements TranscriptionEngine {
  const _FakeTranscriptionEngine(this.fixtures);

  final Map<String, Object?> fixtures;

  @override
  Future<Transcript> transcribe({
    required String file,
    required String locale,
    required List<String> glossary,
    required PrivacyMode privacyMode,
  }) async => Transcript.fromJson(fixtureMap(fixtures, 'transcript'));
}

class _FakeCorpusRetriever implements CorpusRetriever {
  const _FakeCorpusRetriever(this.fixtures);

  final Map<String, Object?> fixtures;

  @override
  Future<CorpusRetrievalResult> retrieve(CorpusQuery query) async =>
      CorpusRetrievalResult.fromJson(
        fixtureMap(fixtures, 'corpus_retrieval_result'),
      );
}

class _FakeBillingProvider implements BillingProvider {
  const _FakeBillingProvider(this.fixtures);

  final Map<String, Object?> fixtures;

  @override
  Future<EntitlementSnapshot> currentEntitlement({
    required String userId,
  }) async => EntitlementSnapshot.fromJson(
    fixtureMap(fixtures, 'entitlement_snapshot'),
  );

  @override
  Future<BillingLedgerEntry> record(BillingLedgerEntry entry) async => entry;
}

class _FakeEntitlementPolicy implements EntitlementPolicy {
  const _FakeEntitlementPolicy(this.fixtures);

  final Map<String, Object?> fixtures;

  @override
  EntitlementDecision evaluate({
    required EntitlementSnapshot snapshot,
    required String featureKey,
    required String policyVersion,
    required DateTime evaluatedAt,
  }) => EntitlementDecision.fromJson(
    fixtureMap(fixtures, 'entitlement_decision'),
  );
}
