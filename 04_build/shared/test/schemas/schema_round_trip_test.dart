import 'package:caliber_shared/caliber_shared.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  late Map<String, Object?> fixtures;

  setUpAll(() {
    fixtures = loadGoldenFixtures();
  });

  group('frozen schema golden fixtures', () {
    test('EvidenceSpan round trips', () {
      final json = fixtureMap(fixtures, 'evidence_span');
      expect(EvidenceSpan.fromJson(json).toJson(), equals(json));
    });

    test('TargetRoleCompany round trips', () {
      final json = fixtureMap(fixtures, 'target_role_company');
      expect(TargetRoleCompany.fromJson(json).toJson(), equals(json));
    });

    test('ProfileIdentity round trips', () {
      final json = fixtureMap(fixtures, 'profile_identity');
      expect(ProfileIdentity.fromJson(json).toJson(), equals(json));
    });

    test('TargetMatrixCell round trips', () {
      final json = fixtureMap(fixtures, 'target_matrix_cell');
      expect(TargetMatrixCell.fromJson(json).toJson(), equals(json));
    });

    test('TranscriptSegment round trips', () {
      final json = fixtureMap(fixtures, 'transcript_segment');
      expect(TranscriptSegment.fromJson(json).toJson(), equals(json));
    });

    test('TranscriptWord round trips', () {
      final json = fixtureMap(fixtures, 'transcript_word');
      expect(TranscriptWord.fromJson(json).toJson(), equals(json));
    });

    test('GlossaryHit round trips', () {
      final json = fixtureMap(fixtures, 'glossary_hit');
      expect(GlossaryHit.fromJson(json).toJson(), equals(json));
    });

    test('Transcript round trips', () {
      final json = fixtureMap(fixtures, 'transcript');
      expect(Transcript.fromJson(json).toJson(), equals(json));
    });

    test('InterviewContentJudgment round trips', () {
      final json = fixtureMap(fixtures, 'interview_content_judgment');
      final roundTripped = InterviewContentJudgment.fromJson(json).toJson();

      expect(roundTripped, equals(json));
      expect(roundTripped.keys.where((key) => key.contains('score')), isEmpty);
    });

    test('ResumeBullet round trips', () {
      final json = fixtureMap(fixtures, 'resume_bullet');
      expect(ResumeBullet.fromJson(json).toJson(), equals(json));
    });

    test('ATSExtractableField round trips', () {
      final json = fixtureMap(fixtures, 'ats_extractable_field');
      expect(ATSExtractableField.fromJson(json).toJson(), equals(json));
    });

    test('ATSCoverageGap round trips', () {
      final json = fixtureMap(fixtures, 'ats_coverage_gap');
      expect(ATSCoverageGap.fromJson(json).toJson(), equals(json));
    });

    test('ATSReportV2 round trips score-free', () {
      final json = fixtureMap(fixtures, 'ats_report');
      final roundTripped = ATSReportV2.fromJson(json).toJson();

      expect(roundTripped, equals(json));
      expect(roundTripped.keys.where((key) => key.contains('score')), isEmpty);
    });

    test('EvidenceAtom round trips', () {
      final json = fixtureMap(fixtures, 'evidence_atom');
      expect(EvidenceAtom.fromJson(json).toJson(), equals(json));
    });

    test('RenderContract round trips', () {
      final json = fixtureMap(fixtures, 'render_contract');
      expect(RenderContract.fromJson(json).toJson(), equals(json));
    });

    test('ResumeSection round trips', () {
      final json = fixtureMap(fixtures, 'resume_section');
      expect(ResumeSection.fromJson(json).toJson(), equals(json));
    });

    test('ResumeDocument round trips', () {
      final json = fixtureMap(fixtures, 'resume_document');
      expect(ResumeDocument.fromJson(json).toJson(), equals(json));
    });

    test('CorpusQuery round trips', () {
      final json = fixtureMap(fixtures, 'corpus_query');
      expect(CorpusQuery.fromJson(json).toJson(), equals(json));
    });

    test('CorpusHit round trips', () {
      final json = fixtureMap(fixtures, 'corpus_hit');
      expect(CorpusHit.fromJson(json).toJson(), equals(json));
    });

    test('CorpusRetrievalResult round trips', () {
      final json = fixtureMap(fixtures, 'corpus_retrieval_result');
      expect(CorpusRetrievalResult.fromJson(json).toJson(), equals(json));
    });

    test('BillingLedgerEntry round trips', () {
      final json = fixtureMap(fixtures, 'billing_ledger_entry');
      expect(BillingLedgerEntry.fromJson(json).toJson(), equals(json));
    });

    test('EntitlementSnapshot round trips', () {
      final json = fixtureMap(fixtures, 'entitlement_snapshot');
      expect(EntitlementSnapshot.fromJson(json).toJson(), equals(json));
    });

    test('EntitlementDecision round trips', () {
      final json = fixtureMap(fixtures, 'entitlement_decision');
      expect(EntitlementDecision.fromJson(json).toJson(), equals(json));
    });

    test('EvidenceAtomView round trips', () {
      final json = fixtureMap(fixtures, 'evidence_atom_view');
      expect(EvidenceAtomView.fromJson(json).toJson(), equals(json));
    });
  });
}
