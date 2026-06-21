import 'dart:convert';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as backend;
import 'package:caliber_prep_brief/prep_brief.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Backend corpus seed carries thirty signed replace-never-mutate bundles',
    () {
      final bundle = backend.backendDepthCorpusBundleV02();

      expect(backend.kBackendDepthRubric.scenarios, hasLength(30));
      expect(bundle.records, hasLength(30));
      expect(bundle.verifySignature(), isTrue);
      expect(
        bundle.records.every(
          (record) =>
              record.metadata['replace_policy'] ==
                  backend.kBackendDepthReplacePolicy &&
              record.metadata['seed_status'] == 'seed_v0.2' &&
              record.metadata['source_evidence']!.isNotEmpty,
        ),
        isTrue,
      );
    },
  );

  test('JD-only prep brief is deterministic and grounded in corpus', () async {
    final generator = JdPrepBriefGenerator();
    final input = PrepBriefInput(jobDescription: _backendSeniorJd);

    final first = await generator.generate(input);
    final second = await generator.generate(input);

    expect(jsonEncode(first.toJson()), jsonEncode(second.toJson()));
    expect(first.roundMixForecast, hasLength(3));
    expect(first.likelyQuestions, hasLength(5));
    expect(first.rubricScaffolds, hasLength(5));
    expect(first.downLevelRiskNotes, hasLength(5));
    expect(first.corpusBundleVersion, backend.kBackendDepthCorpusBundleVersion);
    expect(first.rubricVersion, backend.kBackendDepthRubricVersion);
    expect(
      first.likelyQuestions.map((question) => question.questionId).toSet(),
      hasLength(5),
    );
    expect(
      backend.kBackendDepthRubric.scenarios.map(
        (scenario) => scenario.questionId,
      ),
      contains(first.practiceQuestion.questionId),
    );
  });

  test(
    'prep brief bridge preloads the paid eval question and failure modes',
    () async {
      final eventSink = InMemoryPrepBriefEventSink();
      final generator = JdPrepBriefGenerator(eventSink: eventSink);
      final brief = await generator.generate(
        PrepBriefInput(jobDescription: _backendSeniorJd),
      );

      final question = generator.recordPracticeStartClick(brief);

      expect(question.questionId, brief.likelyQuestions.first.questionId);
      expect(question.prompt, contains('Likely failure modes'));
      expect(question.seedRubric, contains('Down-level traps'));
      expect(question.rubricVersion, backend.kBackendDepthRubricVersion);
      expect(
        eventSink.events.map((event) => event.type.wireName),
        containsAllInOrder(<String>[
          'packet_created',
          'brief_completed',
          'practice_start_click',
        ]),
      );
    },
  );

  test(
    'prep brief used for practice has a likely question and resolvable archetype',
    () async {
      final generator = JdPrepBriefGenerator();
      final brief = await generator.generate(
        PrepBriefInput(jobDescription: _backendSeniorJd),
      );
      final scenarioIds = backend.kBackendDepthRubric.scenarios
          .map((scenario) => scenario.scenarioId)
          .toSet();
      final questionIds = backend.kBackendDepthRubric.scenarios
          .map((scenario) => scenario.questionId)
          .toSet();

      expect(brief.likelyQuestions, isNotEmpty);
      expect(brief.practiceQuestion.questionId, isNotEmpty);
      expect(
        brief.practiceQuestion.questionId,
        brief.likelyQuestions.first.questionId,
      );
      for (final question in brief.likelyQuestions) {
        expect(
          scenarioIds,
          contains(question.scenarioId),
          reason: '${question.questionId} must resolve to a corpus archetype',
        );
        expect(
          questionIds,
          contains(question.questionId),
          reason: '${question.questionId} must resolve to a corpus question',
        );
      }
    },
  );

  test('Block 9 product spine events use stable wire names', () async {
    final eventSink = InMemoryPrepBriefEventSink();
    final generator = JdPrepBriefGenerator(eventSink: eventSink);
    final brief = await generator.generate(
      PrepBriefInput(
        jobDescription: _backendSeniorJd,
        resumeText:
            'Built backend queues, cache invalidation, observability, and incident response workflows.',
      ),
    );

    generator
      ..recordEmailCapture(brief)
      ..recordPracticeStartClick(brief)
      ..recordFirstPaidEvalStarted(brief);

    expect(
      eventSink.events.map((event) => event.type.wireName).toList(),
      <String>[
        'packet_created',
        'brief_completed',
        'email_capture',
        'practice_start_click',
        'first_paid_eval_started',
      ],
    );
  });

  test('visible prep brief copy avoids never-list claims', () async {
    final generator = JdPrepBriefGenerator();
    final brief = await generator.generate(
      PrepBriefInput(jobDescription: _backendSeniorJd),
    );
    final encoded = jsonEncode(brief.toJson()).toLowerCase();

    expect(encoded, isNot(contains('ats score')));
    expect(encoded, isNot(contains('87%')));
    expect(encoded, isNot(contains('probability')));
    expect(encoded, isNot(contains('definitely')));
    expect(encoded, isNot(contains('live assist')));
  });
}

const _backendSeniorJd = '''
Senior Backend Engineer, US product team.
Design and operate distributed APIs, queues, cache-backed services, event
pipelines, observability, and production incident response. The role owns
architecture tradeoffs, reliability, latency, code review, debugging, and
stakeholder communication for multi-tenant backend systems.
''';
