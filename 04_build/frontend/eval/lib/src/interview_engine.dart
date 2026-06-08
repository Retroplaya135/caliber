import 'package:caliber_eval_backend/caliber_eval_backend.dart';
import 'package:caliber_eval_database/caliber_eval_database.dart';

import 'interview_delivery_profile.dart';
import 'interview_models.dart';
import 'judgment_renderer.dart';
import 'structured_judge.dart';

final class InterviewEvaluationEngine {
  InterviewEvaluationEngine({
    required CorpusRetriever corpusRetriever,
    required StructuredJudge structuredJudge,
    required UserMemoryStore memoryStore,
    InterviewDeliveryProfiler? deliveryProfiler,
    JudgmentRenderer? renderer,
    this.schemaVersion = 'interview_content_judgment_v001',
    this.rubricVersion = 'interview_rubric_v001',
    this.promptVersion = 'interview_prompt_v001',
    this.routingPolicyVersion = 'routing_policy_v001',
  }) : _corpusRetriever = corpusRetriever,
       _structuredJudge = structuredJudge,
       _memoryStore = memoryStore,
       _deliveryProfiler = deliveryProfiler ?? InterviewDeliveryProfiler(),
       _renderer = renderer ?? JudgmentRenderer();

  final CorpusRetriever _corpusRetriever;
  final StructuredJudge _structuredJudge;
  final UserMemoryStore _memoryStore;
  final InterviewDeliveryProfiler _deliveryProfiler;
  final JudgmentRenderer _renderer;
  final String schemaVersion;
  final String rubricVersion;
  final String promptVersion;
  final String routingPolicyVersion;

  Future<InterviewEvaluation> evaluate(InterviewAnswer answer) async {
    final corpus = await _corpusRetriever.retrieve(
      CorpusQuery(
        queryText: _rubricQuery(answer),
        roleId: answer.roleId,
        domain: answer.domain,
        levelBand: answer.levelBand,
        companyArchetype: answer.companyArchetype,
        requiredTags: const <String>['interview'],
        limit: 4,
      ),
    );
    if (corpus.records.isEmpty) {
      throw StateError(
        'No corpus records retrieved for answer ${answer.answerId}; no provenance, no judgment.',
      );
    }
    if (!corpus.records.any(
      (record) => record.record.kind == CorpusRecordKind.rubricSlice,
    )) {
      throw StateError(
        'No rubric_slice retrieved for answer ${answer.answerId}; deterministic scaffold is incomplete.',
      );
    }

    final request = StructuredJudgeRequest(
      answerId: answer.answerId,
      questionId: answer.questionId,
      normalizedAnswer: answer.normalizedText,
      schemaVersion: schemaVersion,
      rubricVersion: rubricVersion,
      promptVersion: promptVersion,
      corpusBundleVersion: corpus.corpusBundleVersion,
      routingPolicyVersion: routingPolicyVersion,
      routeHash: corpus.routeHash,
      fixedCorpusSubset: corpus.records,
    );
    final judgment = await _structuredJudge.judgeInterviewContent(request);
    _validateJudgment(judgment: judgment, corpus: corpus, answer: answer);

    final deliveryProfile = _deliveryProfiler.profile(answer);
    await _persist(
      answer: answer,
      judgment: judgment,
      deliveryProfile: deliveryProfile,
    );
    final rendered = _renderer.render(judgment, deliveryProfile);
    return InterviewEvaluation(
      answer: answer,
      corpus: corpus,
      contentJudgment: judgment,
      deliveryProfile: deliveryProfile,
      renderedJudgment: rendered,
    );
  }

  String _rubricQuery(InterviewAnswer answer) {
    return '${answer.questionId} ${answer.roleId} ${answer.domain} ${answer.levelBand} '
        '${answer.companyArchetype} ${answer.normalizedText}';
  }

  void _validateJudgment({
    required InterviewContentJudgment judgment,
    required CorpusRetrievalResult corpus,
    required InterviewAnswer answer,
  }) {
    if (judgment.answerId != answer.answerId) {
      throw StateError(
        'StructuredJudge returned answer ${judgment.answerId}, expected ${answer.answerId}.',
      );
    }
    if (judgment.schemaVersion != schemaVersion ||
        judgment.promptVersion != promptVersion ||
        judgment.corpusBundleVersion != corpus.corpusBundleVersion ||
        judgment.routingPolicyVersion != routingPolicyVersion ||
        judgment.routeHash != corpus.routeHash) {
      throw StateError(
        'StructuredJudge response version tags do not match the deterministic request scaffold.',
      );
    }
    final allowedRecords = <String, CorpusRecord>{
      for (final record in corpus.records)
        record.record.recordId: record.record,
    };
    for (final evidence in judgment.evidenceSpans) {
      final sourceRecord = allowedRecords[evidence.recordId];
      if (sourceRecord == null) {
        throw StateError(
          'Evidence span ${evidence.recordId} was not in the fixed corpus subset.',
        );
      }
      if (evidence.corpusBundleVersion != corpus.corpusBundleVersion) {
        throw StateError(
          'Evidence span ${evidence.recordId} has bundle ${evidence.corpusBundleVersion}, expected ${corpus.corpusBundleVersion}.',
        );
      }
      if (evidence.text.trim().isEmpty ||
          evidence.startOffset < 0 ||
          evidence.endOffset <= evidence.startOffset ||
          evidence.endOffset > sourceRecord.body.length) {
        throw StateError(
          'Evidence span ${evidence.recordId} has invalid offsets or empty text.',
        );
      }
    }
  }

  Future<void> _persist({
    required InterviewAnswer answer,
    required InterviewContentJudgment judgment,
    required InterviewDeliveryProfile deliveryProfile,
  }) async {
    final provenance = Provenance(
      sourceId: judgment.judgmentId,
      sourceType: 'interview_content_judgment',
      schemaVersion: UserMemorySchema.schemaVersion,
      corpusBundleVersion: judgment.corpusBundleVersion,
      createdAt: DateTime.utc(2026, 5, 31),
      evidenceSpans: judgment.evidenceSpans,
      metadata: <String, String>{
        'answer_id': answer.answerId,
        'question_id': answer.questionId,
        'rubric_version': rubricVersion,
        'route_hash': judgment.routeHash,
        'model_id': judgment.modelId,
      },
    );
    await _memoryStore.writeTargetMatrix(
      TargetMatrixCell(
        rowId: '${answer.answerId}:target',
        userId: answer.userId,
        provenance: provenance,
        roleId: answer.roleId,
        domain: answer.domain,
        levelBand: answer.levelBand,
        companyArchetype: answer.companyArchetype,
        priority: _targetPriority(judgment.band),
      ),
    );
    await _memoryStore.writeHistory(
      HistoryEvent(
        rowId: '${answer.answerId}:judgment',
        userId: answer.userId,
        provenance: provenance,
        eventType: 'interview_judgment',
        summary: judgment.summary,
      ),
    );
    for (var index = 0; index < judgment.strengths.length; index += 1) {
      await _memoryStore.writeEvidence(
        EvidenceLedgerEntry(
          rowId: '${answer.answerId}:strength:$index',
          userId: answer.userId,
          provenance: provenance,
          claim: judgment.strengths[index],
          strengthBand: judgment.band,
        ),
      );
    }
    for (var index = 0; index < judgment.gaps.length; index += 1) {
      await _memoryStore.writeGap(
        GapLedgerEntry(
          rowId: '${answer.answerId}:gap:$index',
          userId: answer.userId,
          provenance: provenance,
          gapLabel: judgment.gaps[index],
          severityBand: judgment.band == 'emerging' ? 'high' : 'medium',
          remediationHint:
              'Practice with the fixed corpus rubric slice before the next attempt.',
        ),
      );
    }
    await _memoryStore.writeSpeakingProfile(
      SpeakingProfile(
        rowId: '${answer.answerId}:delivery',
        userId: answer.userId,
        provenance: provenance,
        wordsPerMinute: deliveryProfile.wordsPerMinute,
        pauseCount: deliveryProfile.pauseCount,
        fillerRatio: deliveryProfile.fillerRatio,
      ),
    );
  }

  int _targetPriority(String band) {
    return switch (band) {
      'emerging' || 'below_bar' => 1,
      'solid' || 'approaching' => 2,
      'strong' || 'at_bar' => 3,
      'exceptional' || 'above_bar' => 4,
      _ => throw StateError('Unknown judgment band: $band'),
    };
  }
}
