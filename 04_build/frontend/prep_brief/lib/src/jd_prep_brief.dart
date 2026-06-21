import 'dart:collection';
import 'dart:convert';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as backend;
import 'package:caliber_interview/interview.dart';

final class PrepBriefInput {
  PrepBriefInput({
    required this.jobDescription,
    this.resumeText,
    this.targetLevel = 'Senior',
  }) {
    _checkNotEmpty(jobDescription, 'jobDescription');
    _checkNotEmpty(targetLevel, 'targetLevel');
  }

  final String jobDescription;
  final String? resumeText;
  final String targetLevel;
}

final class PrepBrief {
  const PrepBrief({
    required this.sourceHash,
    required this.corpusBundleVersion,
    required this.rubricVersion,
    required this.targetLevel,
    required this.jdSignals,
    required this.roundMixForecast,
    required this.likelyQuestions,
    required this.rubricScaffolds,
    required this.downLevelRiskNotes,
    required this.ctaLabel,
    required this.practiceQuestion,
  });

  final String sourceHash;
  final String corpusBundleVersion;
  final String rubricVersion;
  final String targetLevel;
  final JdSignals jdSignals;
  final List<RoundMixForecast> roundMixForecast;
  final List<LikelyQuestion> likelyQuestions;
  final List<RubricScaffold> rubricScaffolds;
  final List<DownLevelRiskNote> downLevelRiskNotes;
  final String ctaLabel;
  final InterviewPracticeQuestion practiceQuestion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'source_hash': sourceHash,
      'corpus_bundle_version': corpusBundleVersion,
      'rubric_version': rubricVersion,
      'target_level': targetLevel,
      'jd_signals': jdSignals.toJson(),
      'round_mix_forecast': <Object?>[
        for (final item in roundMixForecast) item.toJson(),
      ],
      'likely_questions': <Object?>[
        for (final item in likelyQuestions) item.toJson(),
      ],
      'rubric_scaffolds': <Object?>[
        for (final item in rubricScaffolds) item.toJson(),
      ],
      'down_level_risk_notes': <Object?>[
        for (final item in downLevelRiskNotes) item.toJson(),
      ],
      'cta_label': ctaLabel,
      'practice_question_id': practiceQuestion.questionId,
    };
  }
}

final class JdSignals {
  const JdSignals({
    required this.normalizedTitle,
    required this.senioritySignals,
    required this.backendSignals,
    required this.deliverySignals,
    required this.optionalResumeSignals,
  });

  final String normalizedTitle;
  final List<String> senioritySignals;
  final List<String> backendSignals;
  final List<String> deliverySignals;
  final List<String> optionalResumeSignals;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'normalized_title': normalizedTitle,
      'seniority_signals': senioritySignals,
      'backend_signals': backendSignals,
      'delivery_signals': deliverySignals,
      'optional_resume_signals': optionalResumeSignals,
    };
  }
}

final class RoundMixForecast {
  const RoundMixForecast({
    required this.label,
    required this.rationale,
    required this.questionIds,
  });

  final String label;
  final String rationale;
  final List<String> questionIds;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'label': label,
      'rationale': rationale,
      'question_ids': questionIds,
    };
  }
}

final class LikelyQuestion {
  const LikelyQuestion({
    required this.rank,
    required this.questionId,
    required this.scenarioId,
    required this.title,
    required this.prompt,
    required this.rationale,
    required this.probes,
  });

  final int rank;
  final String questionId;
  final String scenarioId;
  final String title;
  final String prompt;
  final String rationale;
  final List<String> probes;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'rank': rank,
      'question_id': questionId,
      'scenario_id': scenarioId,
      'title': title,
      'prompt': prompt,
      'rationale': rationale,
      'probes': probes,
    };
  }
}

final class RubricScaffold {
  const RubricScaffold({
    required this.questionId,
    required this.title,
    required this.criteria,
  });

  final String questionId;
  final String title;
  final List<RubricCriterionScaffold> criteria;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'criteria': <Object?>[for (final item in criteria) item.toJson()],
    };
  }
}

final class RubricCriterionScaffold {
  const RubricCriterionScaffold({
    required this.label,
    required this.seniorBar,
    required this.staffSignal,
  });

  final String label;
  final String seniorBar;
  final String staffSignal;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'label': label,
      'senior_bar': seniorBar,
      'staff_signal': staffSignal,
    };
  }
}

final class DownLevelRiskNote {
  const DownLevelRiskNote({
    required this.questionId,
    required this.title,
    required this.note,
    required this.traps,
    required this.redFlags,
  });

  final String questionId;
  final String title;
  final String note;
  final List<String> traps;
  final List<String> redFlags;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'question_id': questionId,
      'title': title,
      'note': note,
      'traps': traps,
      'red_flags': redFlags,
    };
  }
}

enum PrepBriefEventType {
  packetCreated,
  briefCompleted,
  emailCapture,
  practiceStartClick,
  firstPaidEvalStarted,
  verdictCompleted,
  inspectOpened,
  retestStarted;

  String get wireName {
    return switch (this) {
      PrepBriefEventType.packetCreated => 'packet_created',
      PrepBriefEventType.briefCompleted => 'brief_completed',
      PrepBriefEventType.emailCapture => 'email_capture',
      PrepBriefEventType.practiceStartClick => 'practice_start_click',
      PrepBriefEventType.firstPaidEvalStarted => 'first_paid_eval_started',
      PrepBriefEventType.verdictCompleted => 'verdict_completed',
      PrepBriefEventType.inspectOpened => 'inspect_opened',
      PrepBriefEventType.retestStarted => 'retest_started',
    };
  }
}

final class PrepBriefEvent {
  const PrepBriefEvent({
    required this.type,
    required this.sourceHash,
    required this.questionId,
    required this.corpusBundleVersion,
  });

  final PrepBriefEventType type;
  final String sourceHash;
  final String? questionId;
  final String corpusBundleVersion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'event': type.wireName,
      'source_hash': sourceHash,
      'question_id': questionId,
      'corpus_bundle_version': corpusBundleVersion,
    };
  }
}

abstract interface class PrepBriefEventSink {
  void record(PrepBriefEvent event);
}

final class InMemoryPrepBriefEventSink implements PrepBriefEventSink {
  final List<PrepBriefEvent> _events = <PrepBriefEvent>[];

  UnmodifiableListView<PrepBriefEvent> get events {
    return UnmodifiableListView<PrepBriefEvent>(_events);
  }

  @override
  void record(PrepBriefEvent event) {
    _events.add(event);
  }
}

final class JdPrepBriefGenerator {
  JdPrepBriefGenerator({
    backend.CorpusBundle? bundle,
    PrepBriefEventSink? eventSink,
  }) : _corpus = backend.BackendCalibrationCorpus(bundle: bundle),
       _eventSink = eventSink ?? InMemoryPrepBriefEventSink();

  final backend.BackendCalibrationCorpus _corpus;
  final PrepBriefEventSink _eventSink;

  Future<PrepBrief> generate(PrepBriefInput input) async {
    final sourceHash = _fingerprint(
      jsonEncode(<String, String>{
        'jd': _normalize(input.jobDescription),
        'resume': _normalize(input.resumeText ?? ''),
        'target_level': input.targetLevel.trim().toLowerCase(),
        'corpus': _corpus.corpusBundleVersion,
      }),
    );
    final signals = _signalsFor(input);
    final scenarios = await _rankScenarios(input.jobDescription);
    final topScenarios = scenarios.take(5).toList(growable: false);
    if (topScenarios.isEmpty) {
      throw StateError(
        'Prep brief cannot start practice without a resolvable corpus archetype.',
      );
    }
    final practiceQuestion = _practiceQuestionFor(topScenarios.first);
    final brief = PrepBrief(
      sourceHash: sourceHash,
      corpusBundleVersion: _corpus.corpusBundleVersion,
      rubricVersion: _corpus.rubricVersion,
      targetLevel: input.targetLevel.trim(),
      jdSignals: signals,
      roundMixForecast: _roundMix(topScenarios),
      likelyQuestions: <LikelyQuestion>[
        for (var index = 0; index < topScenarios.length; index += 1)
          _likelyQuestion(
            rank: index + 1,
            scenario: topScenarios[index],
            jdSignals: signals,
          ),
      ],
      rubricScaffolds: <RubricScaffold>[
        for (final scenario in topScenarios) _scaffoldFor(scenario),
      ],
      downLevelRiskNotes: <DownLevelRiskNote>[
        for (final scenario in topScenarios) _riskNoteFor(scenario),
      ],
      ctaLabel: 'Practice this in Caliber',
      practiceQuestion: practiceQuestion,
    );
    _eventSink.record(
      PrepBriefEvent(
        type: PrepBriefEventType.packetCreated,
        sourceHash: sourceHash,
        questionId: practiceQuestion.questionId,
        corpusBundleVersion: _corpus.corpusBundleVersion,
      ),
    );
    _eventSink.record(
      PrepBriefEvent(
        type: PrepBriefEventType.briefCompleted,
        sourceHash: sourceHash,
        questionId: practiceQuestion.questionId,
        corpusBundleVersion: _corpus.corpusBundleVersion,
      ),
    );
    return brief;
  }

  void recordEmailCapture(PrepBrief brief) {
    _eventSink.record(
      PrepBriefEvent(
        type: PrepBriefEventType.emailCapture,
        sourceHash: brief.sourceHash,
        questionId: brief.practiceQuestion.questionId,
        corpusBundleVersion: brief.corpusBundleVersion,
      ),
    );
  }

  InterviewPracticeQuestion recordPracticeStartClick(PrepBrief brief) {
    _eventSink.record(
      PrepBriefEvent(
        type: PrepBriefEventType.practiceStartClick,
        sourceHash: brief.sourceHash,
        questionId: brief.practiceQuestion.questionId,
        corpusBundleVersion: brief.corpusBundleVersion,
      ),
    );
    return brief.practiceQuestion;
  }

  void recordFirstPaidEvalStarted(PrepBrief brief) {
    _eventSink.record(
      PrepBriefEvent(
        type: PrepBriefEventType.firstPaidEvalStarted,
        sourceHash: brief.sourceHash,
        questionId: brief.practiceQuestion.questionId,
        corpusBundleVersion: brief.corpusBundleVersion,
      ),
    );
  }

  Future<List<backend.BackendRubricScenario>> _rankScenarios(
    String jobDescription,
  ) async {
    final ranked = await _corpus.rankForPrepBrief(
      jobDescription: jobDescription,
    );
    return ranked.scenarios;
  }
}

JdSignals _signalsFor(PrepBriefInput input) {
  final jd = input.jobDescription.toLowerCase();
  final resume = (input.resumeText ?? '').toLowerCase();
  return JdSignals(
    normalizedTitle: _titleSignal(jd),
    senioritySignals: _matched(jd, const <String>[
      'senior',
      'staff',
      'lead',
      'ownership',
      'mentor',
      'architecture',
      'roadmap',
    ]),
    backendSignals: _matched(jd, const <String>[
      'backend',
      'distributed',
      'api',
      'microservice',
      'database',
      'queue',
      'cache',
      'observability',
      'event',
      'latency',
      'reliability',
    ]),
    deliverySignals: _matched(jd, const <String>[
      'incident',
      'production',
      'debugging',
      'code review',
      'design',
      'scale',
      'stakeholder',
    ]),
    optionalResumeSignals: resume.trim().isEmpty
        ? const <String>[]
        : _matched(resume, const <String>[
            'backend',
            'distributed',
            'incident',
            'migration',
            'observability',
            'queue',
            'cache',
          ]),
  );
}

String _titleSignal(String jd) {
  if (jd.contains('staff')) return 'staff backend engineer';
  if (jd.contains('senior')) return 'senior backend engineer';
  if (jd.contains('platform')) return 'platform backend engineer';
  return 'backend engineer';
}

RoundMixForecast _forecast(
  String label,
  String rationale,
  Iterable<backend.BackendRubricScenario> scenarios,
) {
  return RoundMixForecast(
    label: label,
    rationale: rationale,
    questionIds: <String>[
      for (final scenario in scenarios.take(3)) scenario.questionId,
    ],
  );
}

List<RoundMixForecast> _roundMix(
  List<backend.BackendRubricScenario> scenarios,
) {
  final systemDesign = scenarios.where(
    (scenario) =>
        !scenario.scenarioId.contains('code_review') &&
        !scenario.scenarioId.contains('project_retrospective') &&
        !scenario.scenarioId.contains('ai_in_the_loop'),
  );
  final debugging = scenarios.where(
    (scenario) =>
        scenario.scenarioId.contains('code_review') ||
        scenario.scenarioId.contains('concurrency'),
  );
  final project = scenarios.where(
    (scenario) => scenario.scenarioId.contains('project_retrospective'),
  );
  return <RoundMixForecast>[
    _forecast(
      'System design depth',
      'Backend Senior JDs usually test ownership after the candidate has a workable architecture sketch.',
      systemDesign.isEmpty ? scenarios : systemDesign,
    ),
    _forecast(
      'Debugging and code-review depth',
      'Production wording in the JD maps to failure analysis, regression tests, and reviewer judgment.',
      debugging.isEmpty ? scenarios.skip(1) : debugging,
    ),
    _forecast(
      'Project defense depth',
      'Senior loops often ask whether past architecture choices were measured, operated, and honestly revised.',
      project.isEmpty ? scenarios.skip(2) : project,
    ),
  ];
}

LikelyQuestion _likelyQuestion({
  required int rank,
  required backend.BackendRubricScenario scenario,
  required JdSignals jdSignals,
}) {
  final signals = <String>{
    ...jdSignals.backendSignals,
    ...jdSignals.deliverySignals,
    ...jdSignals.senioritySignals,
  }.take(4).toList(growable: false);
  final signalText = signals.isEmpty
      ? 'Backend Senior depth'
      : signals.join(', ');
  return LikelyQuestion(
    rank: rank,
    questionId: scenario.questionId,
    scenarioId: scenario.scenarioId,
    title: scenario.title,
    prompt: scenario.prompt,
    rationale:
        'Useful because the JD signals $signalText and this archetype exposes down-level risk in ${scenario.dimensions.take(2).map((dimension) => dimension.label.toLowerCase()).join(' and ')}.',
    probes: scenario.probes,
  );
}

RubricScaffold _scaffoldFor(backend.BackendRubricScenario scenario) {
  return RubricScaffold(
    questionId: scenario.questionId,
    title: scenario.title,
    criteria: <RubricCriterionScaffold>[
      for (final dimension in scenario.dimensions)
        RubricCriterionScaffold(
          label: dimension.label,
          seniorBar: dimension.l5Anchor,
          staffSignal: dimension.l6Anchor,
        ),
    ],
  );
}

DownLevelRiskNote _riskNoteFor(backend.BackendRubricScenario scenario) {
  return DownLevelRiskNote(
    questionId: scenario.questionId,
    title: scenario.title,
    note:
        'The common down-level pattern is giving a component answer without the rubric-visible invariant, trade-off, failure mode, and ownership boundary.',
    traps: scenario.commonDownLevelTraps,
    redFlags: scenario.redFlags,
  );
}

InterviewPracticeQuestion _practiceQuestionFor(
  backend.BackendRubricScenario scenario,
) {
  return InterviewPracticeQuestion(
    questionId: scenario.questionId,
    title: 'Prep brief practice: ${scenario.title}',
    prompt:
        '${scenario.prompt}\n\nLikely failure modes to prepare: ${scenario.commonDownLevelTraps.join('; ')}.',
    target: kSeedBackendPracticeQuestion.target,
    rubricVersion: backend.kBackendDepthRubricVersion,
    promptVersion: backend.kBackendDepthPromptVersion,
    seedRubric:
        'Backend Senior seed v0.2. Criteria: ${scenario.dimensions.map((dimension) => dimension.label).join(', ')}. Down-level traps: ${scenario.commonDownLevelTraps.join('; ')}.',
    glossary: scenario.glossary,
  );
}

List<String> _matched(String value, Iterable<String> terms) {
  final lower = value.toLowerCase();
  return <String>[
    for (final term in terms)
      if (lower.contains(term.toLowerCase())) term,
  ];
}

String _normalize(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _fingerprint(String value) {
  var hash = 0x811c9dc5;
  for (final unit in utf8.encode(value)) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

void _checkNotEmpty(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
