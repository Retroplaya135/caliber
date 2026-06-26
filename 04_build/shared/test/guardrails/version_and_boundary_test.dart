import 'dart:io';

import 'package:caliber_shared/caliber_shared.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  group('schema guardrails', () {
    test('all frozen top-level contracts carry schema_version', () {
      final fixtures = loadGoldenFixtures();
      final versionedKeys = <String>[
        'evidence_span',
        'target_role_company',
        'profile_identity',
        'target_matrix_cell',
        'transcript_segment',
        'transcript_word',
        'glossary_hit',
        'transcript',
        'interview_content_judgment',
        'resume_bullet',
        'ats_report',
        'ats_extractable_field',
        'ats_coverage_gap',
        'evidence_atom',
        'render_contract',
        'resume_section',
        'resume_document',
        'corpus_query',
        'corpus_hit',
        'corpus_retrieval_result',
        'billing_ledger_entry',
        'entitlement_snapshot',
        'entitlement_decision',
      ];

      for (final key in versionedKeys) {
        final json = fixtureMap(fixtures, key);
        expect(
          json['schema_version'],
          isA<String>().having((value) => value, 'non-empty', isNotEmpty),
          reason: '$key must carry schema_version',
        );
      }
    });

    test('strict AI outputs require evidence spans at construction', () {
      final target = TargetRoleCompany.fromJson(
        fixtureMap(loadGoldenFixtures(), 'target_role_company'),
      );

      expect(
        () => InterviewContentJudgment(
          judgmentId: 'bad',
          profileId: 'profile-1',
          target: target,
          questionId: 'q',
          answerTranscriptId: 't',
          rubricVersion: 'rubric.v1',
          promptVersion: 'prompt.v1',
          modelId: 'gpt-5.4-mini',
          levelBand: 'senior',
          evidenceSpans: <EvidenceSpan>[],
          createdAt: DateTime.utc(2026, 5, 31),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ResumeBullet(
          bulletId: 'bad',
          documentId: 'resume-1',
          text: 'Unsupported claim.',
          evidenceAtomIds: <String>[],
          evidenceSpans: <EvidenceSpan>[],
          rewritePolicyVersion: 'rewrite.v1',
          promptVersion: 'prompt.v1',
          modelId: 'gpt-5.4-mini',
          confidence: 0.5,
        ),
        throwsA(isA<AssertionError>()),
      );

      final evidenceSpan = EvidenceSpan.fromJson(
        fixtureMap(loadGoldenFixtures(), 'evidence_span'),
      );
      final extractableField = ATSExtractableField(
        fieldKey: 'backend_api',
        label: 'Backend API evidence',
        value: 'Built APIs',
        evidenceSpans: <EvidenceSpan>[evidenceSpan],
      );
      final coverageGap = ATSCoverageGap(
        gapId: 'gap-1',
        keyword: 'observability',
        reason: 'No explicit observability term appears in the source.',
        severity: 'medium',
        evidenceSpans: <EvidenceSpan>[evidenceSpan],
      );

      expect(
        () => ATSReportV2(
          reportId: 'bad',
          documentId: 'resume-1',
          target: target,
          atsTestMatrixVersion: 'ats.v1',
          keywordMatchVersion: 'rapidfuzz.v1',
          extractableFields: <ATSExtractableField>[],
          coverageGaps: <ATSCoverageGap>[coverageGap],
          reasoning: 'Evidence-only ATS analysis.',
          evidenceSpans: <EvidenceSpan>[evidenceSpan],
          createdAt: DateTime.utc(2026, 5, 31),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ATSReportV2(
          reportId: 'bad',
          documentId: 'resume-1',
          target: target,
          atsTestMatrixVersion: 'ats.v1',
          keywordMatchVersion: 'rapidfuzz.v1',
          extractableFields: <ATSExtractableField>[extractableField],
          coverageGaps: <ATSCoverageGap>[],
          reasoning: 'Evidence-only ATS analysis.',
          evidenceSpans: <EvidenceSpan>[evidenceSpan],
          createdAt: DateTime.utc(2026, 5, 31),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => ATSReportV2(
          reportId: 'bad',
          documentId: 'resume-1',
          target: target,
          atsTestMatrixVersion: 'ats.v1',
          keywordMatchVersion: 'rapidfuzz.v1',
          extractableFields: <ATSExtractableField>[extractableField],
          coverageGaps: <ATSCoverageGap>[coverageGap],
          reasoning: 'Evidence-only ATS analysis.',
          evidenceSpans: <EvidenceSpan>[],
          createdAt: DateTime.utc(2026, 5, 31),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('domain package does not import Flutter', () {
      final files = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in files) {
        final source = file.readAsStringSync();
        expect(
          source,
          isNot(contains("import 'package:flutter/")),
          reason: '${file.path} must stay pure Dart',
        );
      }
    });
  });
}
