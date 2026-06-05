import 'corpus_models.dart';
import 'signed_corpus_bundle.dart';

const kBackendDepthRubricVersion = 'backend_depth_l5_l6_seed.v0.1';
const kBackendDepthPromptVersion = 'backend_depth_verdict_prompt.v0.2';
const kBackendDepthCorpusBundleVersion = 'backend_depth_corpus_seed.v0.2';
const kBackendDepthReplacePolicy = 'replace-never-mutate';

final class BackendInterviewRubric {
  const BackendInterviewRubric({
    required this.rubricVersion,
    required this.promptVersion,
    required this.replacePolicy,
    required this.scenarios,
  });

  final String rubricVersion;
  final String promptVersion;
  final String replacePolicy;
  final List<BackendRubricScenario> scenarios;

  BackendRubricScenario scenarioForQuestion(String questionId) {
    return scenarios.firstWhere(
      (scenario) => scenario.questionId == questionId,
      orElse: () => scenarios.first,
    );
  }
}

final class BackendRubricScenario {
  const BackendRubricScenario({
    required this.scenarioId,
    required this.questionId,
    required this.title,
    required this.prompt,
    required this.probes,
    required this.commonDownLevelTraps,
    required this.redFlags,
    required this.strongExemplarSketch,
    required this.weakExemplarSketch,
    required this.dimensions,
    required this.sourceEvidence,
  });

  final String scenarioId;
  final String questionId;
  final String title;
  final String prompt;
  final List<String> probes;
  final List<String> commonDownLevelTraps;
  final List<String> redFlags;
  final String strongExemplarSketch;
  final String weakExemplarSketch;
  final List<BackendRubricDimension> dimensions;
  final List<String> sourceEvidence;

  List<String> get glossary {
    return <String>{
      for (final probe in probes) ..._tokenTerms(probe),
      for (final trap in commonDownLevelTraps) ..._tokenTerms(trap),
      for (final flag in redFlags) ..._tokenTerms(flag),
      for (final dimension in dimensions) ...dimension.expectedSignals,
      for (final dimension in dimensions) ...dimension.advancedSignals,
    }.toList()..sort();
  }
}

final class BackendRubricDimension {
  const BackendRubricDimension({
    required this.dimensionId,
    required this.label,
    required this.judgmentFocus,
    required this.l5Anchor,
    required this.l6Anchor,
    required this.downLevelSignals,
    required this.strongExcerpt,
    required this.weakExcerpt,
    required this.expectedSignals,
    required this.advancedSignals,
    required this.minimumFix,
  });

  final String dimensionId;
  final String label;
  final String judgmentFocus;
  final String l5Anchor;
  final String l6Anchor;
  final List<String> downLevelSignals;
  final String strongExcerpt;
  final String weakExcerpt;
  final List<String> expectedSignals;
  final List<String> advancedSignals;
  final String minimumFix;
}

final kBackendDepthRubric = BackendInterviewRubric(
  rubricVersion: kBackendDepthRubricVersion,
  promptVersion: kBackendDepthPromptVersion,
  replacePolicy: kBackendDepthReplacePolicy,
  scenarios: <BackendRubricScenario>[
    _scenario(
      scenarioId: 'distributed_logging_rate_limiting',
      questionId: 'backend_depth_rate_limiter_l5_l6_v0_1',
      title: 'Distributed logging and rate limiting',
      prompt:
          'Design a distributed rate limiter for a public API. Cover requirements, algorithm and storage choices, failure modes, rollout, and staff-level ownership.',
      artifact:
          'a public API rate limiter with request logs, abuse controls, and tenant quotas',
      coreConcepts: const <String>[
        'tenant',
        'burst',
        'quota',
        'token bucket',
        'sliding window',
        'redis',
        'fail open',
        'fail closed',
        'shadow',
        'rollout',
      ],
      advancedConcepts: const <String>[
        'policy',
        'multi-tenant',
        'platform contract',
        'regional isolation',
        'abuse escalation',
      ],
      probes: const <String>[
        'How do hard abuse caps differ from soft product quotas?',
        'Which endpoints fail open and which fail closed?',
        'What happens when the hot tenant exceeds Redis capacity?',
        'How would you shadow, migrate, and measure enforcement?',
      ],
      traps: const <String>[
        'Jumping to Redis counters before defining tenant fairness.',
        'Ignoring fail-open versus fail-closed semantics.',
        'Treating abuse control as a single-service implementation task.',
      ],
      redFlags: const <String>[
        'No burst or quota policy.',
        'No failure behavior for the limiter dependency.',
        'No rollout or ownership boundary.',
      ],
      strong:
          'Splits hard abuse caps from soft quotas, compares token bucket with sliding windows, defines endpoint-specific failure behavior, and rolls out in shadow mode with a platform contract.',
      weak:
          'Uses Redis counters and blocks after a threshold without tenant keys, failure behavior, or migration plan.',
    ),
    _scenario(
      scenarioId: 'ticketing_reservation',
      questionId: 'backend_depth_idempotency_l5_l6_v0_1',
      title: 'Ticketing and reservation systems',
      prompt:
          'Design a ticketing or reservation backend for scarce inventory. Cover holds, payment, consistency, retries, release, and customer-visible contracts.',
      artifact:
          'a reservation system for scarce seats, inventory holds, and payment completion',
      coreConcepts: const <String>[
        'hold',
        'inventory',
        'expiration',
        'payment',
        'idempotency key',
        'transaction',
        'unique constraint',
        'reconciliation',
      ],
      advancedConcepts: const <String>[
        'fairness',
        'anti-bot',
        'ledger',
        'provider callback',
        'capacity release',
      ],
      probes: const <String>[
        'What invariant prevents overselling?',
        'How do holds expire without losing paid reservations?',
        'How do retries and provider callbacks stay idempotent?',
        'Where do you trade fairness, latency, and conversion?',
      ],
      traps: const <String>[
        'Saying a queue prevents duplicate purchases.',
        'Ignoring payment timeout after a charge succeeds.',
        'Skipping release and reconciliation of abandoned holds.',
      ],
      redFlags: const <String>[
        'No oversell invariant.',
        'No idempotency or ledger story.',
        'No timeout and callback race handling.',
      ],
      strong:
          'Defines the inventory invariant, uses durable holds with expiry, commits business effects idempotently, and reconciles provider callbacks against a ledger.',
      weak:
          'Locks a row, takes payment, and retries failures without explaining duplicate requests or partial completion.',
    ),
    _scenario(
      scenarioId: 'chat_messaging',
      questionId: 'backend_depth_chat_messaging_l5_l6_v0_1',
      title: 'Chat and messaging',
      prompt:
          'Design a chat or messaging backend. Cover delivery, ordering, presence, fanout, offline clients, abuse controls, and operational ownership.',
      artifact:
          'a chat backend with ordered conversations, delivery receipts, and offline delivery',
      coreConcepts: const <String>[
        'conversation',
        'ordering',
        'delivery receipt',
        'presence',
        'fanout',
        'offline',
        'push',
        'dedupe',
      ],
      advancedConcepts: const <String>[
        'per-recipient state',
        'end-to-end encryption',
        'abuse moderation',
        'regional routing',
        'backfill',
      ],
      probes: const <String>[
        'What ordering contract exists within and across conversations?',
        'Where do delivery receipts and read state live?',
        'How are offline clients caught up safely?',
        'How do abuse and fanout failures change the design?',
      ],
      traps: const <String>[
        'Confusing real-time transport with durable message storage.',
        'Ignoring duplicate delivery and offline replay.',
        'Treating presence as strongly consistent truth.',
      ],
      redFlags: const <String>[
        'No durable source of truth for messages.',
        'No per-recipient delivery state.',
        'No moderation or abuse boundary.',
      ],
      strong:
          'Separates durable conversation state from websocket delivery, keeps per-recipient cursors, dedupes offline replay, and scopes presence as best effort.',
      weak:
          'Uses websockets and a database table without delivery semantics, replay, or fanout failure handling.',
    ),
    _scenario(
      scenarioId: 'cache_systems',
      questionId: 'backend_depth_cache_systems_l5_l6_v0_1',
      title: 'Cache systems and cache-backed coding',
      prompt:
          'Design a cache-backed service or cache library. Cover keys, invalidation, stampede protection, consistency, failure behavior, and measurement.',
      artifact:
          'a cache-backed backend surface with invalidation, stampede protection, and source-of-truth repair',
      coreConcepts: const <String>[
        'cache key',
        'ttl',
        'invalidation',
        'source of truth',
        'stampede',
        'read-through',
        'write-through',
        'eviction',
      ],
      advancedConcepts: const <String>[
        'freshness SLO',
        'negative cache',
        'warmup',
        'multi-region',
        'drift budget',
      ],
      probes: const <String>[
        'What data can be stale and for how long?',
        'How do keys evolve when the product shape changes?',
        'How do you prevent stampedes during cold start?',
        'What metric proves the cache helps rather than hides faults?',
      ],
      traps: const <String>[
        'Declaring cache as the solution without invalidation.',
        'No source-of-truth or freshness boundary.',
        'Ignoring stampedes, hot keys, and negative caching.',
      ],
      redFlags: const <String>[
        'No TTL or invalidation plan.',
        'No fallback when cache is unavailable.',
        'No hit-rate and latency measurement.',
      ],
      strong:
          'Defines freshness by surface, keys by invariant, protects origin with single-flight and backoff, and measures hit rate, p95 latency, and stale-read harm.',
      weak:
          'Adds Redis in front of the database and clears it when values change.',
    ),
    _scenario(
      scenarioId: 'top_k_leaderboards',
      questionId: 'backend_depth_consistency_l5_l6_v0_1',
      title: 'Top-K, leaderboards, trending, and ranking',
      prompt:
          'Design a Top-K, trending, or leaderboard backend. Cover ingestion, ranking windows, freshness, abuse resistance, backfill, and read latency.',
      artifact:
          'a ranking backend for Top-K items, leaderboards, or trending content',
      coreConcepts: const <String>[
        'top k',
        'leaderboard',
        'window',
        'ranking',
        'heap',
        'sorted set',
        'freshness',
        'backfill',
      ],
      advancedConcepts: const <String>[
        'abuse resistance',
        'decay function',
        'approximation',
        'sharding',
        'explainability',
      ],
      probes: const <String>[
        'What is the ranking window and update frequency?',
        'Where do you trade exactness for latency?',
        'How do you prevent abuse or gaming?',
        'How do you repair a bad ranking rollout?',
      ],
      traps: const <String>[
        'Using one sorted set without sharding or window semantics.',
        'Ignoring bot traffic or replayed events.',
        'No backfill or rollback path for ranking changes.',
      ],
      redFlags: const <String>[
        'No ranking definition.',
        'No abuse or freshness plan.',
        'No repair or audit trail.',
      ],
      strong:
          'Defines the ranking function and time window, compares exact sorted sets with approximate streaming, and keeps replay/backfill for audit and rollback.',
      weak: 'Stores every ranking value in Redis and returns the top rows.',
    ),
    _scenario(
      scenarioId: 'notification_fanout',
      questionId: 'backend_depth_queue_backpressure_l5_l6_v0_1',
      title: 'Notification fanout',
      prompt:
          'Design notification fanout for email, push, or in-app alerts. Cover audience selection, preferences, rate limits, provider failure, retries, and observability.',
      artifact:
          'a notification fanout backend across push, email, and in-app channels',
      coreConcepts: const <String>[
        'fanout',
        'preference',
        'rate limit',
        'unsubscribe',
        'retry',
        'dead letter',
        'provider',
        'dedupe',
      ],
      advancedConcepts: const <String>[
        'channel policy',
        'deliverability',
        'tenant isolation',
        'quiet hours',
        'campaign rollback',
      ],
      probes: const <String>[
        'How are preferences and legal opt-outs enforced?',
        'What makes fanout safe for large tenants?',
        'How do provider failures avoid duplicate notifications?',
        'What dashboard tells operators to stop a bad send?',
      ],
      traps: const <String>[
        'Treating a send queue as the whole system.',
        'No opt-out, quiet-hours, or dedupe contract.',
        'Retrying provider failures into duplicate user messages.',
      ],
      redFlags: const <String>[
        'No preference enforcement.',
        'No dedupe or idempotency.',
        'No provider-failure containment.',
      ],
      strong:
          'Filters audiences through preferences, dedupes per campaign and recipient, rate-limits by tenant/channel, and isolates provider failures with DLQs and operator stop controls.',
      weak:
          'Queues every notification and retries until the provider accepts it.',
    ),
    _scenario(
      scenarioId: 'ad_click_aggregation',
      questionId: 'backend_depth_ad_click_aggregation_l5_l6_v0_1',
      title: 'Ad-click aggregation and event pipelines',
      prompt:
          'Design an ad-click or event aggregation pipeline. Cover ingestion, dedupe, attribution windows, aggregation, late data, correctness, and reporting latency.',
      artifact:
          'an event pipeline for ad clicks, attribution, and aggregate reporting',
      coreConcepts: const <String>[
        'event',
        'dedupe',
        'attribution',
        'window',
        'aggregation',
        'late data',
        'idempotent',
        'watermark',
      ],
      advancedConcepts: const <String>[
        'exactly-once boundary',
        'privacy',
        'replay',
        'auditability',
        'backfill',
      ],
      probes: const <String>[
        'What event identity prevents double counting?',
        'How do late events change reports?',
        'Where is the source of truth for attribution?',
        'How do you replay after a bad aggregation deploy?',
      ],
      traps: const <String>[
        'Assuming stream processing gives exactly once everywhere.',
        'Ignoring late data and attribution-window correction.',
        'No replay or audit plan for customer-facing reports.',
      ],
      redFlags: const <String>[
        'No event id and dedupe boundary.',
        'No late-data policy.',
        'No reconciliation or report correction.',
      ],
      strong:
          'Defines event identity and attribution windows, separates raw immutable events from aggregates, supports watermark correction, and replays reports from durable logs.',
      weak: 'Streams clicks into a counter table and shows dashboard totals.',
    ),
    _scenario(
      scenarioId: 'observability_log_search',
      questionId: 'backend_depth_incident_l5_l6_v0_1',
      title: 'Observability and log-search products',
      prompt:
          'Design log search or observability for production services. Cover ingestion, indexing, query latency, retention, cardinality, cost, and incident workflows.',
      artifact:
          'a log-search and observability backend for production incidents',
      coreConcepts: const <String>[
        'ingestion',
        'index',
        'retention',
        'cardinality',
        'query latency',
        'trace id',
        'sampling',
        'slo',
      ],
      advancedConcepts: const <String>[
        'cost controls',
        'tiered storage',
        'schema evolution',
        'incident workflow',
        'tenant quota',
      ],
      probes: const <String>[
        'Which fields are indexed and which are scanned?',
        'How do cardinality and retention drive cost?',
        'What query must work during an incident?',
        'How do teams migrate logging schemas safely?',
      ],
      traps: const <String>[
        'Indexing everything without cost or cardinality control.',
        'Ignoring ingestion backpressure and dropped logs.',
        'No incident workflow or query SLO.',
      ],
      redFlags: const <String>[
        'No retention and cost policy.',
        'No cardinality protection.',
        'No degraded ingestion behavior.',
      ],
      strong:
          'Defines indexed fields around incident queries, limits cardinality, separates hot and cold retention, and sets ingestion/query SLOs with tenant quotas.',
      weak: 'Ships all logs into Elasticsearch and searches them.',
    ),
    _scenario(
      scenarioId: 'workflow_orchestration',
      questionId: 'backend_depth_workflow_orchestration_l5_l6_v0_1',
      title: 'Workflow orchestration and developer infrastructure',
      prompt:
          'Design a workflow orchestration or developer-infrastructure backend. Cover state machines, retries, idempotency, visibility, cancellation, and platform adoption.',
      artifact:
          'a workflow orchestration backend for durable developer or product workflows',
      coreConcepts: const <String>[
        'state machine',
        'workflow',
        'retry',
        'idempotency',
        'cancellation',
        'timeout',
        'visibility',
        'versioning',
      ],
      advancedConcepts: const <String>[
        'deterministic replay',
        'platform API',
        'migration',
        'operator tooling',
        'backward compatibility',
      ],
      probes: const <String>[
        'What state is durable and what is derived?',
        'How do retries avoid duplicate side effects?',
        'How do you cancel or version a running workflow?',
        'What makes this a platform other teams can adopt?',
      ],
      traps: const <String>[
        'Using cron and queues without durable workflow state.',
        'Ignoring cancellation, versioning, and replay.',
        'No user-facing or operator visibility.',
      ],
      redFlags: const <String>[
        'No state transition model.',
        'No idempotency on side effects.',
        'No workflow versioning story.',
      ],
      strong:
          'Models workflows as durable state machines, isolates side effects behind idempotent activities, exposes visibility and cancellation, and plans versioned adoption.',
      weak: 'Runs steps in background jobs and retries failures.',
    ),
    _scenario(
      scenarioId: 'in_memory_storage',
      questionId: 'backend_depth_in_memory_storage_l5_l6_v0_1',
      title: 'In-memory databases and storage services',
      prompt:
          'Design an in-memory database or storage service. Cover data model, indexes, concurrency, durability, snapshots, eviction, and operational failure modes.',
      artifact:
          'an in-memory storage service with indexing, durability, and eviction',
      coreConcepts: const <String>[
        'index',
        'snapshot',
        'wal',
        'eviction',
        'concurrency',
        'lock',
        'replication',
        'memory budget',
      ],
      advancedConcepts: const <String>[
        'consensus',
        'compaction',
        'crash recovery',
        'hot shard',
        'linearizability',
      ],
      probes: const <String>[
        'What is the durability behavior after process crash?',
        'How do reads and writes coordinate under concurrency?',
        'How are indexes rebuilt and snapshots compacted?',
        'What happens when memory pressure exceeds budget?',
      ],
      traps: const <String>[
        'Keeping data in a map without recovery semantics.',
        'Ignoring concurrent writes and snapshot consistency.',
        'No eviction or memory-pressure behavior.',
      ],
      redFlags: const <String>[
        'No WAL or snapshot plan.',
        'No concurrency control.',
        'No memory budget.',
      ],
      strong:
          'Defines data and index invariants, uses WAL plus snapshots for recovery, protects concurrent access, and has eviction/replication failure behavior.',
      weak:
          'Stores key-value pairs in memory and periodically writes them to disk.',
    ),
    _scenario(
      scenarioId: 'low_level_evolving_requirements',
      questionId: 'backend_depth_lld_evolving_requirements_l5_l6_v0_1',
      title: 'Low-level design under evolving requirements',
      prompt:
          'Work through a low-level backend design as requirements evolve. Cover interfaces, data model, invariants, extensibility, tests, and production migration.',
      artifact:
          'a low-level backend design that survives evolving requirements and production migration',
      coreConcepts: const <String>[
        'interface',
        'invariant',
        'data model',
        'migration',
        'test',
        'versioning',
        'extensibility',
        'contract',
      ],
      advancedConcepts: const <String>[
        'backward compatibility',
        'domain boundary',
        'observability',
        'rollout plan',
        'failure injection',
      ],
      probes: const <String>[
        'What invariant does the interface protect?',
        'Which requirement change would break the first design?',
        'How do tests capture the contract rather than examples?',
        'How is the change rolled into production safely?',
      ],
      traps: const <String>[
        'Jumping to classes without naming invariants.',
        'Over-generalizing before requirements prove the seam.',
        'No migration path from old data or API shape.',
      ],
      redFlags: const <String>[
        'No interface contract.',
        'No invariants or test strategy.',
        'No compatibility plan.',
      ],
      strong:
          'Names the domain invariant, chooses a narrow interface, adds contract tests, and describes migration/versioning as requirements expand.',
      weak:
          'Creates several classes and says more patterns can be added later.',
    ),
    _scenario(
      scenarioId: 'code_review_debugging',
      questionId: 'backend_depth_code_review_debugging_l5_l6_v0_1',
      title: 'Code review and debugging',
      prompt:
          'Review or debug a backend change that caused production risk. Cover hypothesis, evidence, bug class, fix, regression test, rollout, and reviewer judgment.',
      artifact:
          'a backend code review or debugging session with production-risk reasoning',
      coreConcepts: const <String>[
        'hypothesis',
        'reproduction',
        'regression test',
        'rollback',
        'root cause',
        'blast radius',
        'log',
        'metric',
      ],
      advancedConcepts: const <String>[
        'systemic prevention',
        'review standard',
        'ownership',
        'incident learning',
        'tooling',
      ],
      probes: const <String>[
        'What evidence falsifies your first hypothesis?',
        'What regression test would have caught it?',
        'How do you decide patch, rollback, or feature flag?',
        'What review standard prevents this class later?',
      ],
      traps: const <String>[
        'Fixing the local bug without naming the bug class.',
        'No regression test or production validation.',
        'Blaming the author instead of improving the review system.',
      ],
      redFlags: const <String>[
        'No reproduction path.',
        'No regression test.',
        'No rollout or rollback decision.',
      ],
      strong:
          'Starts with evidence and hypotheses, isolates the bug class, patches behind a safe rollout, adds a regression test, and improves review standards.',
      weak: 'Finds the bad line, changes it, and asks for another review.',
    ),
    _scenario(
      scenarioId: 'concurrency_productionization',
      questionId: 'backend_depth_concurrency_productionization_l5_l6_v0_1',
      title: 'Concurrency and productionization follow-ups',
      prompt:
          'Take a working backend solution and productionize it for concurrency. Cover races, locks, idempotency, throughput, observability, and failure testing.',
      artifact:
          'a working backend feature hardened for concurrency, throughput, and production faults',
      coreConcepts: const <String>[
        'race',
        'lock',
        'atomic',
        'idempotent',
        'throughput',
        'load test',
        'timeout',
        'retry',
      ],
      advancedConcepts: const <String>[
        'contention',
        'backpressure',
        'chaos test',
        'isolation level',
        'capacity planning',
      ],
      probes: const <String>[
        'Which race can corrupt state under concurrent requests?',
        'Where do you use locks, atomics, or database constraints?',
        'How do retries and timeouts avoid duplicate side effects?',
        'What production test proves the concurrency claim?',
      ],
      traps: const <String>[
        'Assuming single-threaded examples represent production.',
        'Ignoring retry races and duplicate side effects.',
        'No load test, timeout, or saturation plan.',
      ],
      redFlags: const <String>[
        'No race or contention analysis.',
        'No idempotency boundary.',
        'No production validation.',
      ],
      strong:
          'Names the race, protects the invariant with constraints or locks, bounds retries and timeouts, and verifies with load and failure tests.',
      weak: 'Adds a mutex and says the service is thread-safe.',
    ),
    _scenario(
      scenarioId: 'project_retrospective_defense',
      questionId: 'backend_depth_project_retro_l5_l6_v0_1',
      title: 'Project retrospective and architecture defense',
      prompt:
          'Defend a past backend project. Cover goal, constraints, decisions, trade-offs, failure modes, measured outcome, and what you would change now.',
      artifact:
          'a project retrospective that defends architecture decisions with evidence',
      coreConcepts: const <String>[
        'goal',
        'constraint',
        'tradeoff',
        'metric',
        'failure mode',
        'migration',
        'stakeholder',
        'lesson',
      ],
      advancedConcepts: const <String>[
        'organizational leverage',
        'roadmap tradeoff',
        'operational maturity',
        'scope control',
        'systemic learning',
      ],
      probes: const <String>[
        'What constraint made the winning design non-obvious?',
        'What metric shows the project worked?',
        'What trade-off would a staff engineer challenge?',
        'What would you change with hindsight?',
      ],
      traps: const <String>[
        'Narrating tasks instead of defending decisions.',
        'No measured result or failure-mode ownership.',
        'Claiming impact without a stakeholder or adoption path.',
      ],
      redFlags: const <String>[
        'No decision rationale.',
        'No metric or evidence.',
        'No honest hindsight.',
      ],
      strong:
          'Frames the business constraint, explains rejected alternatives, cites operating metrics, owns failure modes, and shows what changed in team behavior.',
      weak: 'Lists the services they built and says the launch was successful.',
    ),
    _scenario(
      scenarioId: 'ai_in_the_loop_judgment',
      questionId: 'backend_depth_ai_in_the_loop_l5_l6_v0_1',
      title: 'AI-in-the-loop engineering judgment',
      prompt:
          'Design or evaluate an AI-in-the-loop backend workflow. Cover human review, grounding, guardrails, evaluation, fallbacks, logging, and cost controls.',
      artifact:
          'an AI-assisted backend workflow with review, guardrails, and cost controls',
      coreConcepts: const <String>[
        'grounding',
        'human review',
        'guardrail',
        'evaluation',
        'fallback',
        'audit log',
        'cost cap',
        'cache',
      ],
      advancedConcepts: const <String>[
        'model routing',
        'prompt version',
        'content hash',
        'redaction',
        'quality regression',
      ],
      probes: const <String>[
        'Which decisions must stay deterministic or human-reviewed?',
        'How do you evaluate regressions before model changes?',
        'How are prompts, versions, and inputs logged safely?',
        'What caps prevent the workflow from becoming too expensive?',
      ],
      traps: const <String>[
        'Treating the model answer as the source of truth.',
        'No evaluation harness or prompt/version pinning.',
        'No cost cap, cache, fallback, or redaction boundary.',
      ],
      redFlags: const <String>[
        'No human review boundary.',
        'No eval set or regression gate.',
        'No token/cost control.',
      ],
      strong:
          'Grounds model inputs, keeps high-risk decisions human-reviewed, pins prompt/model versions, caches by content hash, and gates releases with eval regressions.',
      weak:
          'Calls an LLM in the request path and asks it to decide if the output is good.',
    ),
    // HUMAN-DECISION: Founder/SME must calibrate whether eventual
    // consistency is acceptable for rate-limit enforcement before final
    // signing.
    _scenario(
      scenarioId: 'distributed_rate_limiter_v0_2',
      questionId: 'backend_depth_distributed_rate_limiter_l5_l6_v0_2',
      title: 'Distributed rate limiter',
      prompt:
          'Design a distributed rate limiting service for API gateways handling 100,000 requests per second. Cover per-client limits, algorithm choice, distributed counters, failure behavior, tiers, and observability.',
      artifact:
          'a multi-gateway rate limiting service with per-client quotas and response headers',
      coreConcepts: const <String>[
        'rate limiter',
        'token bucket',
        'sliding window',
        'fixed window',
        'distributed counter',
        'redis incr',
        'burst handling',
        '429',
        'quota tier',
        'rate limit header',
      ],
      advancedConcepts: const <String>[
        'local approximation',
        'centralized counter',
        'multi-region',
        'counter store load',
        'abuse pattern monitoring',
      ],
      probes: const <String>[
        'Which rate limiting algorithm fits this traffic shape and why?',
        'How do fifty gateways coordinate counter state without adding too much latency?',
        'What happens when a client bursts far beyond its per-second limit?',
        'What is the failure policy when the counter store is unavailable?',
        'How do free, paid, and enterprise tiers change your data model?',
        'How does the design change when a client can hit multiple regions?',
      ],
      traps: const <String>[
        'Designing an in-memory single-server limiter for a distributed gateway fleet.',
        'Picking one algorithm without comparing accuracy, state cost, and burst behavior.',
        'Ignoring stale counters, partitions, or counter-store unavailability.',
        'Using heavyweight consensus or locks for every request check.',
      ],
      redFlags: const <String>[
        'Cannot distinguish token bucket, sliding window, and fixed window behavior.',
        'No estimate for counter-store read/write load.',
        'No answer for counter-store failure behavior.',
        'No product reason for rate limits such as fair use, abuse control, cost, or monetization.',
      ],
      strong:
          'Clarifies per-client scope, latency overhead, and tier policy; compares token bucket with sliding-window options; uses a centralized counter with a local fast path; chooses failure behavior by endpoint risk; estimates counter-store operations; and exposes utilization plus remaining-limit headers.',
      weak:
          'Stores counts in a process map and asks clients to stay on one gateway, with no algorithm comparison, stale-counter handling, load estimate, or operational signal.',
      sourceEvidence: const <String>[
        'system-design-primer README caching, consistency, and estimation sections (CC-BY-4.0, attributed; rewritten expression).',
        'advanced-java high-availability topic taxonomy (CC-BY-SA-4.0, abstract_only; concepts only, no expression copied).',
        'tech-interview-handbook coding-interview-rubrics.md (MIT, attributed; rubric dimensions abstracted).',
        'HUMAN-DECISION: Review whether the strong and weak exemplars calibrate to FAANG L5 or mid-market senior.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must decide whether optimistic locking,
    // pessimistic locking, or queue admission is the expected primary senior
    // path for scarce-inventory booking.
    _scenario(
      scenarioId: 'ticket_booking_concurrency_v0_2',
      questionId: 'backend_depth_ticket_booking_concurrency_l5_l6_v0_2',
      title: 'Ticket booking concurrency',
      prompt:
          'Design a ticket booking backend where many users attempt to reserve limited seats at the same time. Cover the no-oversell invariant, seat holds, payment, timeouts, high-demand admission, and partial failures.',
      artifact:
          'a scarce-inventory booking system with atomic reservations and payment completion',
      coreConcepts: const <String>[
        'ticket booking',
        'reservation',
        'oversell invariant',
        'race condition',
        'optimistic locking',
        'pessimistic locking',
        'version field',
        'reservation timeout',
        'virtual queue',
        'payment failure',
      ],
      advancedConcepts: const <String>[
        'state machine',
        'atomic update',
        'transaction boundary',
        'admission control',
        'multi-seat rollback',
      ],
      probes: const <String>[
        'What race condition exists when two users try to reserve the last seat?',
        'When would you choose optimistic locking versus pessimistic locking?',
        'How do holds expire without losing paid reservations?',
        'How does the design behave under a launch surge?',
        'Which entity or aggregate owns the no-oversell invariant?',
        'How do you handle payment failure in a multi-seat booking?',
      ],
      traps: const <String>[
        'Checking availability in application code and then booking later.',
        'No reservation timeout for abandoned seats.',
        'Locking the entire event inventory for every booking.',
        'Ignoring payment and multi-seat partial failure paths.',
      ],
      redFlags: const <String>[
        'Cannot explain the concurrent race in the last-seat case.',
        'Uses process-level locks for database inventory changes.',
        'No hold state between seat selection and payment completion.',
        'No atomic invariant at the storage or transaction boundary.',
      ],
      strong:
          'Centers the no-oversell invariant, models seats and reservations as explicit states, uses an atomic conditional update or versioned write, expires holds, batches extreme demand through admission control, and separates reservation from payment confirmation with rollback or release behavior.',
      weak:
          'Designs the seat map and payment form first, then checks if a seat is available before marking it booked, with no atomic transition, hold timeout, or high-demand admission plan.',
      sourceEvidence: const <String>[
        'awesome-low-level-design concert ticket booking taxonomy (GPL-3.0, abstract_only; factual problem label only, no solution expression copied).',
        'awesome-low-level-design concurrency taxonomy (GPL-3.0, abstract_only; concept names only).',
        'system-design-primer consistency patterns (CC-BY-4.0, attributed; rewritten expression).',
        'domain-driven-hexagon entity, aggregate, and invariant vocabulary (MIT, attributed; rewritten expression).',
        'tech-interview-handbook coding-interview-rubrics.md (MIT, attributed; rubric dimensions abstracted).',
        'HUMAN-DECISION: Review payment-domain expectations and the acceptable senior answer range for admission control.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must choose the original code sample and
    // calibrate how much domain knowledge the review exercise should require.
    _scenario(
      scenarioId: 'code_review_debugging_v0_2',
      questionId: 'backend_depth_code_review_debugging_l5_l6_v0_2',
      title: 'Code review and debugging',
      prompt:
          'Review a backend service that processes user orders. Start with the most critical concerns, explain why they matter, and describe how you would improve the code safely.',
      artifact:
          'a code review round that prioritizes correctness, architecture, testability, and production risk',
      coreConcepts: const <String>[
        'code review',
        'debugging',
        'domain invariant',
        'race condition',
        'testability',
        'dependency injection',
        'separation of concerns',
        'blast radius',
        'refactoring',
        'n plus one query',
      ],
      advancedConcepts: const <String>[
        'request tracing strategy',
        'aggregate boundary',
        'hard dependency',
        'atomic update',
        'risk-ranked remediation',
      ],
      probes: const <String>[
        'How do you read a new codebase before naming issues?',
        'Which architectural concerns matter more than formatting or naming?',
        'What domain invariant can this service violate?',
        'What makes the code hard to test, and how would you improve that?',
        'Which shared-state or database operation can fail under concurrency?',
        'What would you fix first if you only had two hours?',
      ],
      traps: const <String>[
        'Starting with cosmetic style issues while missing correctness bugs.',
        'Saying code looks wrong without connecting it to a failure mode.',
        'Reviewing syntax and patterns without asking what the domain must protect.',
        'Adding null checks everywhere instead of removing invalid states.',
        'Listing issues without prioritizing by user harm or blast radius.',
      ],
      redFlags: const <String>[
        'Cannot trace request flow through controller, service, repository, and storage.',
        'Misses a check-then-act race in shared state or database updates.',
        'Approves unsafe user input handling without mitigation.',
        'Cannot identify hard dependencies that block unit testing.',
        'Suggests a rewrite without naming the concrete risk being removed.',
      ],
      strong:
          'Reads top-down through the request path, identifies a correctness race before style issues, ties the bug to a domain invariant, proposes an atomic storage change, separates payment, inventory, and persistence responsibilities, and ranks remediation by production blast radius.',
      weak:
          'Comments on naming, indentation, and function length, then says the database will handle concurrency, without identifying the domain invariant, hard dependencies, or a safe first fix.',
      sourceEvidence: const <String>[
        'domain-driven-hexagon entity, aggregate, invariant, and dependency inversion sections (MIT, attributed; rewritten expression).',
        'tech-interview-handbook coding-interview-rubrics.md and interviewer-cheatsheet.md (MIT, attributed; signal taxonomy abstracted).',
        'awesome-low-level-design design-principle taxonomy (GPL-3.0, abstract_only; concept names only).',
        'HUMAN-DECISION: Review the original code sample, exemplar strength, and whether rewrite recommendations are red flags or acceptable when risk is explicit.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate the senior bar for
    // notification fatigue, preference policy, and channel fallback depth.
    _scenario(
      scenarioId: 'notification_system_v0_2',
      questionId: 'backend_depth_notification_system_l5_l6_v0_2',
      title: 'Notification system',
      prompt:
          'Design a notification platform for push, email, and SMS at tens of millions of users. Cover message priority, preferences, templates, delivery failures, retry policy, and user fatigue.',
      artifact:
          'a multi-channel notification platform with priority, preferences, and delivery observability',
      coreConcepts: const <String>[
        'notification',
        'push notification',
        'email',
        'sms',
        'message queue',
        'preference center',
        'template',
        'retry',
        'dead letter queue',
        'delivery receipt',
      ],
      advancedConcepts: const <String>[
        'transactional versus marketing',
        'quiet hours',
        'priority queue',
        'provider fallback',
        'fatigue budget',
      ],
      probes: const <String>[
        'Which notification types require different priority or retry treatment?',
        'How do user preferences and quiet hours enter the send path?',
        'Where do templates and personalization live, and how are they versioned?',
        'What happens when a provider fails or throttles a channel?',
        'How do you detect fatigue or duplicate sends without hiding transactional alerts?',
        'What delivery metrics tell you the system is healthy?',
      ],
      traps: const <String>[
        'Sending notifications synchronously from the product request path.',
        'Treating every message as the same priority and retry class.',
        'Ignoring user preferences, quiet hours, or unsubscribe constraints.',
        'No dead letter path or provider-failure visibility.',
      ],
      redFlags: const <String>[
        'No channel-specific failure handling.',
        'No preference model for user consent and quiet hours.',
        'No idempotency key for duplicate event delivery.',
        'No operational metric beyond provider success responses.',
      ],
      strong:
          'Separates transactional and marketing traffic, uses queues to decouple producers from channel workers, applies preferences before send, versions templates, retries by channel risk, isolates provider failures, and tracks delivery plus fatigue signals.',
      weak:
          'Calls push, email, and SMS providers directly from each product service and retries all failures the same way, with no preference model, template versioning, or duplicate-send guard.',
      sourceEvidence: const <String>[
        'system-design notification topic taxonomy (CC-BY-NC-ND-4.0, idea_only; topic structure only, no expression copied).',
        'system-design-primer asynchronous processing and queue patterns (CC-BY-4.0, attributed; rewritten expression).',
        'tech-interview-handbook coding-interview-rubrics.md (MIT, attributed; rubric dimensions abstracted).',
        'HUMAN-DECISION: Review how much compliance, unsubscribe, and fatigue-policy depth is expected for Backend Senior.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate whether the senior bar
    // expects at-least-once execution plus idempotency, or deeper scheduler HA.
    _scenario(
      scenarioId: 'distributed_task_scheduler_v0_2',
      questionId: 'backend_depth_distributed_task_scheduler_l5_l6_v0_2',
      title: 'Distributed task scheduler',
      prompt:
          'Design a distributed task scheduler that handles millions of delayed and recurring jobs. Cover scheduling, worker leasing, retry behavior, clock skew, recurring rules, and recovery after worker failure.',
      artifact:
          'a distributed scheduler with delayed jobs, recurring jobs, worker leases, and recovery paths',
      coreConcepts: const <String>[
        'task scheduler',
        'job scheduler',
        'cron',
        'delayed queue',
        'worker pool',
        'lease',
        'idempotency',
        'retry',
        'recurring task',
        'clock skew',
      ],
      advancedConcepts: const <String>[
        'leader election',
        'checkpoint',
        'priority queue',
        'fair scheduling',
        'shard ownership',
      ],
      probes: const <String>[
        'How does a worker claim a job without two workers doing the same work?',
        'What happens when a worker dies halfway through a task?',
        'How do you store and query jobs due in the next minute?',
        'How do recurring tasks handle time zones and daylight saving changes?',
        'How does the scheduler scale horizontally without duplicate dispatch?',
        'Which task outcomes are safe to retry?',
      ],
      traps: const <String>[
        'Building one scheduler process that becomes a single operational choke point.',
        'Relying on worker memory for claimed jobs or retry state.',
        'No idempotency requirement for retried task handlers.',
        'Ignoring clock skew, recurring schedule drift, or lease expiry.',
      ],
      redFlags: const <String>[
        'No claim or lease mechanism for worker coordination.',
        'No recovery path for a worker crash.',
        'No way to separate transient failure from poison jobs.',
        'No answer for duplicate dispatch or missed recurring tasks.',
      ],
      strong:
          'Models jobs as durable records, dispatches by due time with shard ownership, claims work with leases, requires idempotent handlers, retries with bounded backoff, routes poison jobs for review, and records scheduler lag plus worker health.',
      weak:
          'Runs cron on one host and pushes work to workers in memory, with no durable claim, retry state, clock-skew plan, or duplicate-dispatch defense.',
      sourceEvidence: const <String>[
        'system-design-primer asynchronous processing and task queue patterns (CC-BY-4.0, attributed; rewritten expression).',
        'awesome-low-level-design concurrency taxonomy (GPL-3.0, abstract_only; concept names only, no expression copied).',
        'advanced-java distributed coordination topic taxonomy (CC-BY-SA-4.0, abstract_only; concepts only).',
        'HUMAN-DECISION: Review expected delivery contract language and scheduler-HA depth for Backend Senior.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate expected payment-domain
    // knowledge, especially compliance boundaries and reconciliation depth.
    _scenario(
      scenarioId: 'payment_transaction_system_v0_2',
      questionId: 'backend_depth_payment_transaction_l5_l6_v0_2',
      title: 'Payment and transaction system',
      prompt:
          'Design a payment processing backend for an e-commerce platform. Cover idempotent checkout, provider calls, partial failures, refunds, reconciliation, currency handling, and compliance boundaries.',
      artifact:
          'a payment workflow with idempotent commands, provider callbacks, refunds, and reconciliation',
      coreConcepts: const <String>[
        'payment',
        'transaction',
        'idempotency key',
        'payment gateway',
        'refund',
        'chargeback',
        'ledger',
        'reconciliation',
        'currency',
        'webhook',
      ],
      advancedConcepts: const <String>[
        'saga',
        'outbox',
        'provider callback',
        'pci boundary',
        'compensating action',
      ],
      probes: const <String>[
        'How do you prevent a retried checkout from charging twice?',
        'What state transitions exist from authorization through capture and refund?',
        'How do you reconcile provider webhooks with your internal ledger?',
        'What happens when payment succeeds but order confirmation fails?',
        'Where do currency conversion and rounding rules live?',
        'Which card data should your system avoid storing?',
      ],
      traps: const <String>[
        'Treating payment as a single CRUD write after checkout.',
        'No idempotency key for checkout retries or provider callbacks.',
        'No durable ledger or reconciliation process.',
        'Mixing card-data handling into ordinary product services.',
      ],
      redFlags: const <String>[
        'Cannot name the duplicate-charge failure mode.',
        'No separation between order state and payment state.',
        'No response to provider callback replay or timeout.',
        'No compliance boundary for sensitive payment data.',
      ],
      strong:
          'Uses idempotent commands for checkout, models payment state separately from order state, records ledger entries, handles provider callbacks as replayable events, reconciles mismatches, and keeps sensitive card handling outside normal services.',
      weak:
          'Charges the card from the checkout request and marks the order paid if the HTTP call returns success, with no idempotency key, ledger, callback handling, or reconciliation path.',
      sourceEvidence: const <String>[
        'Caliber original synthesis for payment-system coverage gap identified in 04_question_taxonomy.md.',
        'system-design-primer consistency and asynchronous-processing patterns (CC-BY-4.0, attributed; rewritten expression).',
        'domain-driven-hexagon aggregate and invariant vocabulary (MIT, attributed; rewritten expression).',
        'HUMAN-DECISION: Review expected PCI, ledger, and reconciliation depth for Backend Senior.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must decide which delivery semantics and
    // ordering depth define senior-level pub-sub answers.
    _scenario(
      scenarioId: 'pub_sub_event_system_v0_2',
      questionId: 'backend_depth_pub_sub_event_system_l5_l6_v0_2',
      title: 'Pub-sub event system',
      prompt:
          'Design a publish-subscribe event system with topic routing, durable subscriptions, consumer retries, ordering constraints, and slow-consumer handling.',
      artifact:
          'a topic-based event broker with durable subscriptions, ordering semantics, and back pressure',
      coreConcepts: const <String>[
        'pub-sub',
        'publish subscribe',
        'event system',
        'message broker',
        'topic',
        'subscription',
        'consumer group',
        'offset',
        'dead letter queue',
        'back pressure',
      ],
      advancedConcepts: const <String>[
        'partition key',
        'ordering scope',
        'deduplication key',
        'slow consumer',
        'retention policy',
      ],
      probes: const <String>[
        'What delivery contract does the broker expose to subscribers?',
        'Where is message ordering required, and what key defines that ordering?',
        'How do consumers resume after failure?',
        'How do you handle a slow consumer without blocking the whole topic?',
        'What gets persisted, and for how long?',
        'How do you prevent duplicate effects in consumers?',
      ],
      traps: const <String>[
        'Describing fire-and-forget callbacks instead of durable events.',
        'Claiming total ordering across all topics without naming the cost.',
        'No offset, retry, or dead-letter model for consumer recovery.',
        'Ignoring back pressure when consumers fall behind.',
      ],
      redFlags: const <String>[
        'No durable subscription state.',
        'No ordering scope or partitioning explanation.',
        'No handling for poison events.',
        'No consumer idempotency story.',
      ],
      strong:
          'Defines topic and subscription state, persists events with retention, orders within a named partition key, tracks consumer offsets, isolates slow consumers, routes poison events, and requires idempotent consumer effects.',
      weak:
          'Calls subscribers directly from the publisher and retries failures in a loop, with no durable subscription, ordering scope, back pressure, or duplicate-effect defense.',
      sourceEvidence: const <String>[
        'awesome-low-level-design pub-sub problem taxonomy (GPL-3.0, abstract_only; factual problem label only).',
        'system-design-primer asynchronous processing and message queue patterns (CC-BY-4.0, attributed; rewritten expression).',
        'advanced-java message-queue topic taxonomy (CC-BY-SA-4.0, abstract_only; concepts only).',
        'HUMAN-DECISION: Review whether Kafka-style partition semantics are required or one of several acceptable senior paths.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate whether dispatch optimization
    // is expected at senior, or whether state-machine correctness is enough.
    _scenario(
      scenarioId: 'food_delivery_dispatch_v0_2',
      questionId: 'backend_depth_food_delivery_dispatch_l5_l6_v0_2',
      title: 'Food delivery dispatch',
      prompt:
          'Design the order matching and dispatch backend for a food delivery service. Cover driver availability, geospatial matching, assignment state, real-time location, cancellation, and delivery-time estimates.',
      artifact:
          'a food delivery dispatch system with geospatial matching, lifecycle state, and cancellation recovery',
      coreConcepts: const <String>[
        'food delivery',
        'dispatch',
        'driver matching',
        'geolocation',
        'geohash',
        'quadtree',
        'real-time tracking',
        'order state',
        'availability',
        'eta',
      ],
      advancedConcepts: const <String>[
        'supply demand balancing',
        'assignment state machine',
        'driver cancellation',
        'location freshness',
        'batching opportunity',
      ],
      probes: const <String>[
        'How do you find nearby available drivers without scanning all drivers?',
        'What state transitions exist from order placed to delivered?',
        'How fresh must driver location be to make a good assignment?',
        'What happens when a driver cancels after pickup or before pickup?',
        'How do restaurants, drivers, and customers see consistent state?',
        'Which signals feed delivery-time estimates?',
      ],
      traps: const <String>[
        'Using naive distance scans over all drivers for every order.',
        'No explicit order and driver state machine.',
        'Ignoring stale location, driver cancellation, or reassignment.',
        'Optimizing distance while ignoring capacity, pickup timing, and fairness.',
      ],
      redFlags: const <String>[
        'No geospatial index or filtering strategy.',
        'No answer for driver cancellation recovery.',
        'No lifecycle invariant for order assignment.',
        'No observability around assignment latency or failed dispatches.',
      ],
      strong:
          'Indexes drivers by location cell, filters by availability and freshness, models order and driver state transitions, handles cancellation through reassignment rules, tracks assignment latency, and keeps ETA as a measured prediction rather than a fixed promise.',
      weak:
          'Finds all drivers in the database, sorts by distance, and writes the chosen driver onto the order, with no state machine, freshness rule, cancellation path, or dispatch metric.',
      sourceEvidence: const <String>[
        'awesome-low-level-design ride-sharing and food-delivery taxonomy (GPL-3.0, abstract_only; factual problem labels only).',
        'system-design ride-sharing case-study structure (CC-BY-NC-ND-4.0, idea_only; topic structure only, no expression copied).',
        'Caliber original synthesis for dispatch lifecycle and senior-bar probes.',
        'HUMAN-DECISION: Review whether route batching and marketplace pricing belong in Backend Senior v1.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate whether cache invalidation
    // and thundering-herd mitigation are mandatory senior signals.
    _scenario(
      scenarioId: 'caching_strategy_deep_dive_v0_2',
      questionId: 'backend_depth_caching_strategy_l5_l6_v0_2',
      title: 'Caching strategy deep-dive',
      prompt:
          'Your API has P99 latency spikes. Walk through diagnosis, then design a caching layer. Cover what to cache, invalidation, consistency, warmup, thundering-herd mitigation, and metrics.',
      artifact:
          'a cache-backed latency remediation plan with invalidation, stampede protection, and measurement',
      coreConcepts: const <String>[
        'caching',
        'cache invalidation',
        'redis',
        'memcached',
        'cache-aside',
        'write-through',
        'ttl',
        'thundering herd',
        'request coalescing',
        'hit rate',
      ],
      advancedConcepts: const <String>[
        'cache warming',
        'stale while revalidate',
        'hot key',
        'versioned key',
        'tail latency',
      ],
      probes: const <String>[
        'What evidence tells you caching is the right fix?',
        'Which data should not be cached, and why?',
        'How do cache-aside and write-through differ for this API?',
        'How do you invalidate or version cached data after writes?',
        'What prevents many requests from stampeding the database on expiry?',
        'Which metrics prove the change helped instead of hiding the issue?',
      ],
      traps: const <String>[
        'Adding Redis before diagnosing the latency source.',
        'No invalidation or staleness model.',
        'No mitigation for hot keys or synchronized TTL expiry.',
        'Reporting average latency while ignoring P99 and cache hit quality.',
      ],
      redFlags: const <String>[
        'Cannot explain stale data risk.',
        'No cache miss path or fallback behavior.',
        'No write-path interaction with cached reads.',
        'No measurement plan beyond checking if Redis is up.',
      ],
      strong:
          'Starts with tracing and metrics, chooses cache targets from access patterns, compares cache-aside and write-through, defines invalidation or versioned keys, mitigates stampedes with coalescing and jitter, and measures P99, hit rate, and database load.',
      weak:
          'Adds Redis with a one-hour TTL to every response and expects latency to improve, without diagnosis, invalidation, hot-key handling, or tail-latency measurement.',
      sourceEvidence: const <String>[
        'system-design-primer caching strategies and cache failure modes (CC-BY-4.0, attributed; rewritten expression).',
        'advanced-java caching topic taxonomy (CC-BY-SA-4.0, abstract_only; concepts only).',
        '05_senior_bar_signals.md data-intensive senior calibration synthesis.',
        'HUMAN-DECISION: Review whether cache-aside is the expected default or one acceptable option among several.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate zero-downtime migration
    // depth, especially whether dual writes are required or conditional.
    _scenario(
      scenarioId: 'database_migration_schema_evolution_v0_2',
      questionId: 'backend_depth_database_migration_l5_l6_v0_2',
      title: 'Database migration and schema evolution',
      prompt:
          'Plan a live database schema migration for a high-traffic backend with no planned downtime. Cover compatibility, rollout, backfill, validation, rollback, and dual-write risk.',
      artifact:
          'a zero-downtime schema evolution plan with validation, rollback, and operational controls',
      coreConcepts: const <String>[
        'database migration',
        'schema evolution',
        'zero downtime',
        'expand contract',
        'backfill',
        'dual write',
        'backwards compatibility',
        'rollback',
        'checksum',
        'data validation',
      ],
      advancedConcepts: const <String>[
        'shadow read',
        'change data capture',
        'feature flag',
        'cutover',
        'strangler pattern',
      ],
      probes: const <String>[
        'What is the first backwards-compatible change you ship?',
        'How do old and new application versions run safely during rollout?',
        'How do you backfill without harming production traffic?',
        'How do you validate migrated data before cutover?',
        'What is your rollback plan after partial migration?',
        'How do you detect and handle dual-write divergence?',
      ],
      traps: const <String>[
        'Scheduling downtime as the primary plan without proving it is acceptable.',
        'Making a breaking schema change before all writers and readers are ready.',
        'No validation beyond spot-checking a few rows.',
        'No rollback path once new writes begin.',
      ],
      redFlags: const <String>[
        'No expand-contract or compatibility strategy.',
        'No backfill throttling or production-safety control.',
        'No integrity check for migrated data.',
        'No owner for the cutover and rollback decision.',
      ],
      strong:
          'Uses expand-contract sequencing, keeps old and new code compatible, backfills with throttling, validates with counts and checksums, shadows reads before cutover, defines rollback windows, and monitors divergence during dual writes.',
      weak:
          'Runs a migration script during a maintenance window and deploys new code afterward, with no compatibility plan, validation, backfill controls, or rollback decision point.',
      sourceEvidence: const <String>[
        'Caliber original synthesis for database-migration coverage gap identified in 04_question_taxonomy.md.',
        'system-design-primer database scaling and consistency patterns (CC-BY-4.0, attributed; rewritten expression).',
        '05_senior_bar_signals.md senior ownership and failure-mode synthesis.',
        'HUMAN-DECISION: Review expected expand-contract, blue-green, and strangler-pattern depth for Backend Senior.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate expected on-call experience
    // and how much incident-command behavior should be required.
    _scenario(
      scenarioId: 'incident_response_debugging_v0_2',
      questionId: 'backend_depth_incident_response_l5_l6_v0_2',
      title: 'Debugging and incident response',
      prompt:
          'Your service returns 500 errors for 5% of production requests. Walk through your investigation, triage, mitigation, communication, and follow-up.',
      artifact:
          'an incident response walkthrough with metrics, logs, traces, mitigation, and learning loop',
      coreConcepts: const <String>[
        'incident response',
        'debugging',
        '500 errors',
        'metrics',
        'logs',
        'traces',
        'blast radius',
        'rollback',
        'postmortem',
        'alerting',
      ],
      advancedConcepts: const <String>[
        'deployment correlation',
        'dependency failure',
        'mitigation first',
        'stakeholder update',
        'action item owner',
      ],
      probes: const <String>[
        'What do you check in the first five minutes?',
        'How do you separate a new deploy issue from a dependency failure?',
        'How do you estimate blast radius and customer impact?',
        'When do you roll back, degrade, or page another owner?',
        'How do you communicate during the incident?',
        'What changes after the incident is resolved?',
      ],
      traps: const <String>[
        'Jumping into code edits before checking metrics, recent deploys, and blast radius.',
        'Debugging only the happy-path request without segmenting impacted traffic.',
        'No mitigation path while root cause is still unknown.',
        'Ending the story at resolution without a learning loop.',
      ],
      redFlags: const <String>[
        'No first-response structure.',
        'No customer-impact or blast-radius estimate.',
        'No escalation or communication threshold.',
        'No post-incident follow-up tied to prevention.',
      ],
      strong:
          'Starts from alert context, checks metrics, logs, traces, deploys, and dependencies, narrows the impacted cohort, chooses mitigation before risky fixes, communicates status, and converts the incident into owned prevention work.',
      weak:
          'Opens the latest code change, guesses where the bug is, and pushes a fix without confirming scope, mitigation, stakeholder updates, or follow-up.',
      sourceEvidence: const <String>[
        'tech-interview-handbook senior behavioral and process signals (MIT, attributed; rubric dimensions abstracted).',
        'devops-exercises incident and monitoring topic taxonomy (CC-BY-NC-ND-3.0, idea_only; topic names only, no expression copied).',
        'Caliber original synthesis for production debugging interview format.',
        'HUMAN-DECISION: Review whether direct on-call ownership is mandatory for Backend Senior candidates.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate how technical leadership
    // stories are weighted against technical design performance.
    _scenario(
      scenarioId: 'technical_leadership_decision_v0_2',
      questionId: 'backend_depth_technical_leadership_l5_l6_v0_2',
      title: 'Senior behavioral technical leadership',
      prompt:
          'Tell me about a significant technical decision you drove that changed your team or organization. Cover context, alternatives, trade-offs, stakeholder alignment, outcome, and hindsight.',
      artifact:
          'a senior behavioral story about technical ownership, decision quality, and measured impact',
      coreConcepts: const <String>[
        'technical leadership',
        'architecture decision',
        'stakeholder alignment',
        'tradeoff',
        'impact',
        'metric',
        'buy-in',
        'hindsight',
        'ownership',
        'decision record',
      ],
      advancedConcepts: const <String>[
        'cross-team influence',
        'risk framing',
        'option analysis',
        'adoption plan',
        'learning loop',
      ],
      probes: const <String>[
        'How did you identify the need for the decision?',
        'What alternatives did you consider, and why did you reject them?',
        'Who disagreed, and how did you handle that disagreement?',
        'What metric or observable outcome changed?',
        'What risk did you miss or underestimate?',
        'What would you do differently with the same constraints?',
      ],
      traps: const <String>[
        'Telling a task-execution story instead of a decision story.',
        'No rejected alternatives or trade-off explanation.',
        'No stakeholder, adoption, or communication path.',
        'No measured outcome or honest hindsight.',
      ],
      redFlags: const <String>[
        'Every key decision was made by someone else.',
        'Blames stakeholders without naming personal learning.',
        'Cannot quantify impact or name a user-visible outcome.',
        'No ownership of the downside of the decision.',
      ],
      strong:
          'Frames the problem, names the decision owner role, compares alternatives, earns alignment with data and trade-offs, measures impact after rollout, and owns what hindsight changed in their technical judgment.',
      weak:
          'Describes implementing a design chosen by a manager and says the team liked it, with no alternatives, disagreement, metric, or personal decision ownership.',
      sourceEvidence: const <String>[
        'tech-interview-handbook behavioral-interview-senior-candidates.md (MIT, attributed; senior signal taxonomy abstracted).',
        'reverse-interview ownership and team-category taxonomy (CC-BY-SA-4.0, abstract_only; category concepts only).',
        '05_senior_bar_signals.md behavioral leadership synthesis.',
        'HUMAN-DECISION: Review behavioral weight ratio and whether ownership language is a hard senior signal.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate REST, GraphQL, and gRPC
    // depth expected for product-backend versus platform-backend roles.
    _scenario(
      scenarioId: 'api_design_tradeoffs_v0_2',
      questionId: 'backend_depth_api_design_tradeoffs_l5_l6_v0_2',
      title: 'API design trade-offs',
      prompt:
          'Design an API surface for a backend used by web, mobile, and partner clients. Compare REST, GraphQL, and gRPC, then cover versioning, pagination, authorization boundaries, errors, and observability.',
      artifact:
          'an API contract with protocol choice, versioning, authorization, errors, and client evolution plan',
      coreConcepts: const <String>[
        'api design',
        'rest',
        'graphql',
        'grpc',
        'versioning',
        'pagination',
        'authorization',
        'error model',
        'schema',
        'backward compatibility',
      ],
      advancedConcepts: const <String>[
        'field-level authorization',
        'schema evolution',
        'contract testing',
        'idempotent command',
        'client capability',
      ],
      probes: const <String>[
        'Which client needs drive your protocol choice?',
        'How do REST, GraphQL, and gRPC fail differently for mobile and partner clients?',
        'How do you evolve the contract without breaking old clients?',
        'Where do authorization decisions live in the API layer?',
        'What is your pagination and filtering strategy?',
        'How do clients debug errors and request latency?',
      ],
      traps: const <String>[
        'Picking a protocol by preference instead of client and data-access needs.',
        'No versioning or backward-compatibility strategy.',
        'Treating authorization as a controller afterthought.',
        'Returning unstructured errors that clients cannot act on.',
      ],
      redFlags: const <String>[
        'Cannot explain over-fetching, under-fetching, or binary RPC trade-offs.',
        'No schema evolution story.',
        'No pagination or bounded query plan.',
        'No observability for API consumers.',
      ],
      strong:
          'Chooses protocol by client shape and access patterns, defines versioning and contract tests, constrains pagination, maps errors to client actions, enforces authorization at the boundary, and exposes request tracing for partners.',
      weak:
          'Chooses GraphQL because it is flexible and exposes database-shaped objects directly, with no versioning, authorization boundary, pagination cap, or client-error contract.',
      sourceEvidence: const <String>[
        'graphql-spec API schema and execution vocabulary (JDF-Spec-License, attributed; concepts only, no spec text copied).',
        'system-design-primer API, consistency, and data-model tradeoff vocabulary (CC-BY-4.0, attributed; rewritten expression).',
        'tech-interview-handbook coding-interview-rubrics.md (MIT, attributed; rubric dimensions abstracted).',
        'HUMAN-DECISION: Review expected GraphQL/gRPC depth and whether partner-client concerns belong in Backend Senior v1.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate the SRE/platform depth for
    // Backend Senior versus a dedicated SRE interview.
    _scenario(
      scenarioId: 'observability_system_design_v0_2',
      questionId: 'backend_depth_observability_system_l5_l6_v0_2',
      title: 'Observability system design',
      prompt:
          'Design the observability approach for a critical backend service. Cover metrics, logs, traces, alerting, dashboards, sampling, cardinality, and incident feedback loops.',
      artifact:
          'an observability plan with telemetry signals, actionable alerts, dashboards, and incident learning',
      coreConcepts: const <String>[
        'observability',
        'metrics',
        'logs',
        'traces',
        'alerting',
        'dashboard',
        'slo',
        'sli',
        'sampling',
        'cardinality',
      ],
      advancedConcepts: const <String>[
        'trace correlation',
        'error budget',
        'golden signals',
        'high-cardinality label',
        'runbook',
      ],
      probes: const <String>[
        'Which signals tell you user impact before customers complain?',
        'How do logs, metrics, and traces answer different questions?',
        'What alert should page a human, and what should only create a ticket?',
        'How do you prevent high-cardinality labels from hurting the system?',
        'How do you sample traces without losing important failures?',
        'How do incidents change dashboards and runbooks afterward?',
      ],
      traps: const <String>[
        'Collecting telemetry without tying it to user impact or service objectives.',
        'Paging on noisy symptoms instead of actionable conditions.',
        'Logging sensitive request data or unbounded labels.',
        'No trace correlation across service boundaries.',
      ],
      redFlags: const <String>[
        'No distinction between logs, metrics, and traces.',
        'No actionable alert threshold.',
        'No plan for cardinality, sampling, or retention.',
        'No learning loop from incident to instrumentation.',
      ],
      strong:
          'Defines user-facing SLIs, instruments golden-path metrics, correlates traces across services, keeps logs structured and safe, controls cardinality and sampling, pages only actionable alerts, and updates runbooks after incidents.',
      weak:
          'Adds logs around every function and a dashboard for CPU and memory, with no user-impact signal, trace correlation, alert discipline, or cardinality control.',
      sourceEvidence: const <String>[
        'devops-exercises monitoring and alerting topic taxonomy (CC-BY-NC-ND-3.0, idea_only; topic names only, no expression copied).',
        'Caliber original synthesis for backend observability coverage gap identified in 04_question_taxonomy.md.',
        '05_senior_bar_signals.md failure-mode and ownership synthesis.',
        'HUMAN-DECISION: Review how much SLO/error-budget language belongs in the Backend Senior corpus before SRE niche expansion.',
      ],
    ),
    // HUMAN-DECISION: Founder/SME must calibrate people-leadership weight
    // and whether mentoring evidence is mandatory for senior backend.
    _scenario(
      scenarioId: 'people_leadership_v0_2',
      questionId: 'backend_depth_people_leadership_l5_l6_v0_2',
      title: 'Senior behavioral people leadership',
      prompt:
          'Tell me about a time you helped another engineer or team improve. Cover the situation, your role, the coaching or conflict path, the outcome, and what changed afterward.',
      artifact:
          'a senior behavioral story about mentoring, conflict navigation, and durable team improvement',
      coreConcepts: const <String>[
        'people leadership',
        'mentoring',
        'coaching',
        'conflict resolution',
        'feedback',
        'team process',
        'stakeholder',
        'growth',
        'ownership',
        'impact',
      ],
      advancedConcepts: const <String>[
        'psychological safety',
        'calibration',
        'delegation',
        'durable behavior change',
        'team operating model',
      ],
      probes: const <String>[
        'What was the specific growth or conflict problem?',
        'How did you decide whether to coach, pair, document, or escalate?',
        'How did you avoid taking ownership away from the other engineer?',
        'What changed in the person, team, or process afterward?',
        'How did you measure whether the intervention worked?',
        'What would you handle differently next time?',
      ],
      traps: const <String>[
        'Telling a story where they simply did the work for someone else.',
        'No concrete feedback, coaching method, or conflict path.',
        'No durable change beyond one task being completed.',
        'No acknowledgement of their own role in the interpersonal dynamics.',
      ],
      redFlags: const <String>[
        'Frames teammates as obstacles without personal accountability.',
        'Cannot describe a mentoring or feedback example.',
        'No outcome beyond personal heroics.',
        'Uses blame language instead of learning language.',
      ],
      strong:
          'Identifies the growth need, chooses an intervention that preserves ownership, handles disagreement directly, measures durable change in team behavior, and names what they learned about supporting other engineers.',
      weak:
          'Says a junior engineer was stuck, so they rewrote the code and the ticket shipped, with no coaching approach, feedback loop, or durable team improvement.',
      sourceEvidence: const <String>[
        'tech-interview-handbook behavioral-interview-senior-candidates.md (MIT, attributed; senior leadership taxonomy abstracted).',
        'reverse-interview team and process category taxonomy (CC-BY-SA-4.0, abstract_only; category concepts only).',
        '05_senior_bar_signals.md behavioral senior ownership synthesis.',
        'HUMAN-DECISION: Review behavioral weight ratio, mentoring expectations, and staff-readiness boundary.',
      ],
    ),
  ],
);

CorpusBundle backendDepthCorpusBundleV02() {
  final records = <CorpusRecord>[
    for (final scenario in kBackendDepthRubric.scenarios)
      CorpusRecord(
        recordId: 'backend_rubric:${scenario.scenarioId}:l5_l6:v0_2',
        kind: CorpusRecordKind.rubricSlice,
        title: scenario.title,
        body: _scenarioBody(scenario),
        corpusBundleVersion: kBackendDepthCorpusBundleVersion,
        roleId: 'backend_engineer',
        domain: 'Backend',
        levelBand: 'L5/L6',
        companyArchetype: 'growth-stage-product',
        tags: const <String>[
          'interview',
          'backend',
          'l5',
          'l6',
          'rubric',
          'seed_v0_2',
        ],
        metadata: <String, String>{
          'rubric_version': kBackendDepthRubricVersion,
          'prompt_version': kBackendDepthPromptVersion,
          'replace_policy': kBackendDepthReplacePolicy,
          'scenario_id': scenario.scenarioId,
          'seed_status': 'seed_v0.2',
          'source_evidence': scenario.sourceEvidence.join(' | '),
        },
      ),
  ];
  final unsigned = CorpusBundle(
    bundleVersion: kBackendDepthCorpusBundleVersion,
    signature: 'unsigned',
    records: records,
  );
  return CorpusBundle(
    bundleVersion: kBackendDepthCorpusBundleVersion,
    signature: unsigned.expectedSignature,
    records: records,
  );
}

CorpusBundle backendDepthCorpusBundleV01() => backendDepthCorpusBundleV02();

BackendRubricScenario _scenario({
  required String scenarioId,
  required String questionId,
  required String title,
  required String prompt,
  required String artifact,
  required List<String> coreConcepts,
  required List<String> advancedConcepts,
  required List<String> probes,
  required List<String> traps,
  required List<String> redFlags,
  required String strong,
  required String weak,
  List<String> sourceEvidence = const <String>[
    'Caliber backend depth seed v0.1 original synthesis from mined taxonomy and senior-bar notes; HUMAN-DECISION: founder/SME calibration sign-off remains required before final bundle signing.',
  ],
}) {
  return BackendRubricScenario(
    scenarioId: scenarioId,
    questionId: questionId,
    title: title,
    prompt: prompt,
    probes: probes,
    commonDownLevelTraps: traps,
    redFlags: redFlags,
    strongExemplarSketch: strong,
    weakExemplarSketch: weak,
    sourceEvidence: sourceEvidence,
    dimensions: _dimensions(
      artifact: artifact,
      coreConcepts: coreConcepts,
      advancedConcepts: advancedConcepts,
      traps: traps,
      strong: strong,
      weak: weak,
    ),
  );
}

List<BackendRubricDimension> _dimensions({
  required String artifact,
  required List<String> coreConcepts,
  required List<String> advancedConcepts,
  required List<String> traps,
  required String strong,
  required String weak,
}) {
  final core = coreConcepts.take(8).toList(growable: false);
  final advanced = advancedConcepts.take(5).toList(growable: false);
  return <BackendRubricDimension>[
    BackendRubricDimension(
      dimensionId: 'requirements',
      label: 'Requirements and constraints',
      judgmentFocus:
          'Does the answer define the user-visible invariant, traffic shape, correctness boundary, and constraints for $artifact before naming components?',
      l5Anchor:
          'Clarifies scope, invariant, latency/freshness need, data ownership, and customer-visible behavior.',
      l6Anchor:
          'Also separates product policy from platform mechanics and names cross-team adoption or migration constraints.',
      downLevelSignals: <String>[
        traps.first,
        'jumps to tools without defining invariants, constraints, or user harm',
      ],
      strongExcerpt: strong,
      weakExcerpt: weak,
      expectedSignals: core.take(5).toList(growable: false),
      advancedSignals: advanced.take(4).toList(growable: false),
      minimumFix:
          'Open with the invariant, scope, latency/freshness target, and user-visible failure boundary before implementation.',
    ),
    BackendRubricDimension(
      dimensionId: 'tradeoffs',
      label: 'Trade-offs',
      judgmentFocus:
          'Does the answer compare viable designs for $artifact under correctness, latency, operability, and cost pressure?',
      l5Anchor:
          'Compares at least two approaches and states why the chosen path fits the stated constraints.',
      l6Anchor:
          'Also frames the trade-off as a platform or organizational decision with migration and ownership consequences.',
      downLevelSignals: <String>[
        traps.length > 1 ? traps[1] : traps.first,
        'names one tool or pattern without the cost of rejecting alternatives',
      ],
      strongExcerpt: strong,
      weakExcerpt: weak,
      expectedSignals: core.skip(2).take(5).toList(growable: false),
      advancedSignals: advanced.toList(growable: false),
      minimumFix:
          'Compare two designs and state the latency, correctness, and operating cost of the one you recommend.',
    ),
    BackendRubricDimension(
      dimensionId: 'failure_modes',
      label: 'Failure modes',
      judgmentFocus:
          'Does the answer define what fails, how the system degrades, and how operators repair $artifact?',
      l5Anchor:
          'Names retries, timeouts, duplicate effects, backpressure or repair, and the metric that confirms recovery.',
      l6Anchor:
          'Adds blast-radius controls, regional or tenant isolation, runbooks, and durable owners for prevention.',
      downLevelSignals: <String>[
        traps.length > 2 ? traps[2] : traps.first,
        'assumes dependencies and retries always behave safely',
      ],
      strongExcerpt: strong,
      weakExcerpt: weak,
      expectedSignals: <String>[
        ...core.where(
          (term) =>
              term.contains('retry') ||
              term.contains('timeout') ||
              term.contains('fail') ||
              term.contains('failure') ||
              term.contains('dedupe') ||
              term.contains('backfill') ||
              term.contains('reconciliation') ||
              term.contains('idempot'),
        ),
        'fail open',
        'fail closed',
        'rollback',
        'degrade',
        'metric',
      ].take(5).toList(growable: false),
      advancedSignals: <String>[
        ...advanced,
        'blast radius',
        'runbook',
        'isolation',
      ].take(5).toList(growable: false),
      minimumFix:
          'Add one concrete failure case, the degradation behavior, the repair path, and the metric that proves recovery.',
    ),
    BackendRubricDimension(
      dimensionId: 'scope_level_signal',
      label: 'Scope and level signal',
      judgmentFocus:
          'Does the answer read like senior delivery or staff-level ownership for $artifact?',
      l5Anchor:
          'Owns a production-ready service design with rollout, metrics, tests, and operational guardrails.',
      l6Anchor:
          'Owns the reusable contract, stakeholder trade-offs, migration path, and long-term operability across teams.',
      downLevelSignals: <String>[
        'only describes implementation tasks',
        'does not discuss rollout, ownership, migration, or cross-team contract',
      ],
      strongExcerpt: strong,
      weakExcerpt: weak,
      expectedSignals: const <String>[
        'rollout',
        'metric',
        'test',
        'owner',
        'contract',
      ],
      advancedSignals: <String>[
        ...advanced,
        'cross-team',
        'platform',
        'migration',
      ].take(5).toList(growable: false),
      minimumFix:
          'Add the rollout contract, owner boundary, adoption path, and how teams operate the design after launch.',
    ),
    BackendRubricDimension(
      dimensionId: 'communication',
      label: 'Communication',
      judgmentFocus:
          'Does the answer make the decision thread for $artifact easy to inspect under interview pressure?',
      l5Anchor:
          'Uses a clear requirements -> design -> trade-off -> failure mode -> measurement flow.',
      l6Anchor:
          'Also highlights the executive trade-off and what changes with scale, business priority, or organization shape.',
      downLevelSignals: <String>[
        'lists components without a recommendation',
        'omits the final decision, evidence, or success signal',
      ],
      strongExcerpt: strong,
      weakExcerpt: weak,
      expectedSignals: const <String>[
        'because',
        'tradeoff',
        'recommend',
        'measure',
        'success',
      ],
      advancedSignals: const <String>[
        'priority',
        'scale',
        'decision',
        'business',
        'organization',
      ],
      minimumFix:
          'Close with the recommendation, why it beats the alternative, and the measure that would change your mind.',
    ),
  ];
}

String _scenarioBody(BackendRubricScenario scenario) {
  final buffer = StringBuffer()
    ..writeln('Rubric version: $kBackendDepthRubricVersion')
    ..writeln('Corpus bundle version: $kBackendDepthCorpusBundleVersion')
    ..writeln('Replace policy: $kBackendDepthReplacePolicy')
    ..writeln('Seed status: seed v0.2')
    ..writeln('Source evidence: ${scenario.sourceEvidence.join('; ')}')
    ..writeln('Scenario: ${scenario.title}')
    ..writeln('Prompt: ${scenario.prompt}')
    ..writeln('Deterministic probes: ${scenario.probes.join('; ')}')
    ..writeln(
      'Common down-level traps: ${scenario.commonDownLevelTraps.join('; ')}',
    )
    ..writeln('Red flags: ${scenario.redFlags.join('; ')}')
    ..writeln('Strong exemplar sketch: ${scenario.strongExemplarSketch}')
    ..writeln('Weak exemplar sketch: ${scenario.weakExemplarSketch}');
  for (final dimension in scenario.dimensions) {
    buffer
      ..writeln('Dimension: ${dimension.dimensionId} - ${dimension.label}')
      ..writeln('Focus: ${dimension.judgmentFocus}')
      ..writeln('L5 anchor: ${dimension.l5Anchor}')
      ..writeln('L6 anchor: ${dimension.l6Anchor}')
      ..writeln('Down-level signals: ${dimension.downLevelSignals.join('; ')}')
      ..writeln('Strong excerpt: ${dimension.strongExcerpt}')
      ..writeln('Weak excerpt: ${dimension.weakExcerpt}')
      ..writeln('Minimum fix: ${dimension.minimumFix}');
  }
  return buffer.toString().trim();
}

Iterable<String> _tokenTerms(String value) {
  return RegExp(r'[a-z0-9][a-z0-9-]{2,}')
      .allMatches(value.toLowerCase())
      .map((match) => match.group(0)!)
      .where((term) => !_stopTerms.contains(term));
}

const _stopTerms = <String>{
  'and',
  'the',
  'for',
  'with',
  'without',
  'how',
  'what',
  'when',
  'where',
  'which',
  'that',
  'this',
  'from',
  'into',
  'are',
  'you',
  'your',
  'they',
  'them',
};
