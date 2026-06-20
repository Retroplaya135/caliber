import 'package:caliber_eval_backend/caliber_eval_backend.dart' as backend;
import 'package:caliber_shared/caliber_shared.dart' as schema;

final class InterviewPracticeQuestion {
  const InterviewPracticeQuestion({
    required this.questionId,
    required this.title,
    required this.prompt,
    required this.target,
    required this.rubricVersion,
    required this.promptVersion,
    required this.seedRubric,
    required this.glossary,
  });

  final String questionId;
  final String title;
  final String prompt;
  final schema.TargetRoleCompany target;
  final String rubricVersion;
  final String promptVersion;
  final String seedRubric;
  final List<String> glossary;
}

// Block 3 Step C Backend depth slice. Block 4 will add more domains.
const kSeedBackendPracticeQuestion = InterviewPracticeQuestion(
  questionId: 'backend_depth_rate_limiter_l5_l6_v0_1',
  title: 'Backend depth round: distributed rate limiter',
  prompt:
      'Design a distributed rate limiter for a public API. Cover requirements, algorithm and storage choices, failure modes, rollout, and how the design changes for staff-level ownership.',
  target: schema.TargetRoleCompany(
    roleId: 'backend_engineer',
    domain: 'Backend',
    levelBand: 'L5/L6',
    companyArchetype: 'growth-stage-product',
    title: 'Backend Engineer',
    market: 'US',
    seniorityOrder: 5,
    metadata: <String, Object?>{'seed': true},
  ),
  rubricVersion: backend.kBackendDepthRubricVersion,
  promptVersion: backend.kBackendDepthPromptVersion,
  seedRubric:
      'Backend L5/L6 seed v0.2 rubric: requirements, trade-offs, failure modes, scope/level signal, and communication. Strong answers cite tenant/burst semantics, compare algorithms and storage, define fail-open/fail-closed behavior, show rollout ownership, and close with a recommendation plus measurement.',
  glossary: <String>[
    'tenant',
    'burst',
    'token bucket',
    'sliding window',
    'redis',
    'latency',
    'fail open',
    'fail closed',
    'rollback',
    'shadow',
    'migration',
  ],
);

List<InterviewPracticeQuestion> get kBackendDepthPracticeQuestions {
  return <InterviewPracticeQuestion>[
    for (final scenario in backend.kBackendDepthRubric.scenarios)
      InterviewPracticeQuestion(
        questionId: scenario.questionId,
        title: 'Backend depth round: ${scenario.title}',
        prompt: scenario.prompt,
        target: const schema.TargetRoleCompany(
          roleId: 'backend_engineer',
          domain: 'Backend',
          levelBand: 'L5/L6',
          companyArchetype: 'growth-stage-product',
          title: 'Backend Engineer',
          market: 'US',
          seniorityOrder: 5,
          metadata: <String, Object?>{'seed': true},
        ),
        rubricVersion: backend.kBackendDepthRubricVersion,
        promptVersion: backend.kBackendDepthPromptVersion,
        seedRubric:
            'Backend L5/L6 seed v0.2 rubric: requirements, trade-offs, failure modes, scope/level signal, and communication.',
        glossary: scenario.glossary,
      ),
  ];
}

InterviewPracticeQuestion backendDepthPracticeQuestionFor(String questionId) {
  return kBackendDepthPracticeQuestions.firstWhere(
    (question) => question.questionId == questionId,
    orElse: () => kSeedBackendPracticeQuestion,
  );
}
