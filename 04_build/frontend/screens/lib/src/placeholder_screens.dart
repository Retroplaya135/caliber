import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:caliber_app_shell/app_shell.dart';
import 'package:caliber_design_system/design_system.dart';
import 'package:caliber_interview/interview.dart';
import 'package:caliber_prep_brief/prep_brief.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'funnel_event_transport.dart';
import 'product_spine_view_models.dart';

const _defaultAnonProfileId = 'anonymous-local-profile';

typedef FunnelEventPoster =
    Future<bool> Function(Uri endpoint, Map<String, Object?> payload);

final class PrepBriefDemandSignalRecord {
  const PrepBriefDemandSignalRecord({
    required this.eventType,
    required this.anonProfileId,
    required this.occurredAt,
    required this.sourceHash,
    required this.questionId,
    required this.corpusBundleVersion,
  });

  factory PrepBriefDemandSignalRecord.fromEvent({
    required PrepBriefEvent event,
    required String anonProfileId,
    required DateTime occurredAt,
  }) {
    return PrepBriefDemandSignalRecord(
      eventType: event.type,
      anonProfileId: anonProfileId,
      occurredAt: occurredAt,
      sourceHash: event.sourceHash,
      questionId: event.questionId,
      corpusBundleVersion: event.corpusBundleVersion,
    );
  }

  factory PrepBriefDemandSignalRecord.fromJson(Map<String, Object?> json) {
    final wireName = json['event_type'];
    final eventType = PrepBriefEventType.values.firstWhere(
      (type) => type.wireName == wireName,
      orElse: () => throw FormatException('unknown event_type $wireName'),
    );
    return PrepBriefDemandSignalRecord(
      eventType: eventType,
      anonProfileId: json['anon_profile_id']! as String,
      occurredAt: DateTime.parse(json['ts']! as String).toUtc(),
      sourceHash: json['source_hash']! as String,
      questionId: json['question_id'] as String?,
      corpusBundleVersion: json['corpus_bundle_version']! as String,
    );
  }

  final PrepBriefEventType eventType;
  final String anonProfileId;
  final DateTime occurredAt;
  final String sourceHash;
  final String? questionId;
  final String corpusBundleVersion;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'event_type': eventType.wireName,
      'anon_profile_id': anonProfileId,
      'ts': occurredAt.toUtc().toIso8601String(),
      'source_hash': sourceHash,
      'question_id': questionId,
      'corpus_bundle_version': corpusBundleVersion,
    };
  }
}

final class PersistentPrepBriefEventSink implements PrepBriefEventSink {
  PersistentPrepBriefEventSink({
    required this.anonProfileId,
    this.preferences,
    DateTime Function()? clock,
    this.funnelEndpoint,
    FunnelEventPoster? funnelPoster,
    this.storageKey = defaultStorageKey,
    this.pendingStorageKey = defaultPendingStorageKey,
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       _funnelPoster = funnelPoster ?? postFunnelEvent {
    _loaded = _load();
    unawaited(_loaded.then((_) => _startRemoteFlush()));
  }

  static const defaultStorageKey = 'caliber.prep_brief.events.v1';
  static const defaultPendingStorageKey =
      'caliber.prep_brief.pending_funnel_events.v1';

  final String anonProfileId;
  final SharedPreferences? preferences;
  final DateTime Function() _clock;
  final Uri? funnelEndpoint;
  final FunnelEventPoster _funnelPoster;
  final String storageKey;
  final String pendingStorageKey;
  final List<PrepBriefDemandSignalRecord> _records =
      <PrepBriefDemandSignalRecord>[];
  final List<PrepBriefDemandSignalRecord> _pendingRemoteRecords =
      <PrepBriefDemandSignalRecord>[];
  late final Future<void> _loaded;
  Future<void>? _pendingLocalWrite;
  Future<void>? _pendingRemoteBufferWrite;
  Future<void>? _pendingRemoteFlush;
  bool _remoteFlushInFlight = false;

  UnmodifiableListView<PrepBriefDemandSignalRecord> get records {
    return UnmodifiableListView<PrepBriefDemandSignalRecord>(_records);
  }

  Iterable<PrepBriefDemandSignalRecord> query({PrepBriefEventType? type}) {
    return _records.where((record) {
      return type == null || record.eventType == type;
    });
  }

  Future<void> get ready => _loaded;

  Future<void> flush() async {
    await _loaded;
    await _pendingLocalWrite;
    await _pendingRemoteBufferWrite;
    await _pendingRemoteFlush;
    if (funnelEndpoint != null && _pendingRemoteRecords.isNotEmpty) {
      _startRemoteFlush();
      await _pendingRemoteFlush;
    }
    await _pendingRemoteBufferWrite;
  }

  @override
  void record(PrepBriefEvent event) {
    final record = PrepBriefDemandSignalRecord.fromEvent(
      event: event,
      anonProfileId: anonProfileId,
      occurredAt: _clock().toUtc(),
    );
    _records.add(record);
    _pendingRemoteRecords.add(record);
    _pendingLocalWrite = _writeRecords();
    _pendingRemoteBufferWrite = _writePendingRemoteRecords();
    unawaited(_pendingLocalWrite);
    unawaited(_pendingRemoteBufferWrite);
    _startRemoteFlush();
  }

  Future<void> _load() async {
    final pending = List<PrepBriefDemandSignalRecord>.of(_records);
    final pendingRemote = List<PrepBriefDemandSignalRecord>.of(
      _pendingRemoteRecords,
    );
    final preferences = await _resolvePreferences();
    final stored = _decodeRecords(preferences.getStringList(storageKey));
    final storedRemote = _decodeRecords(
      preferences.getStringList(pendingStorageKey),
    );
    _records
      ..clear()
      ..addAll(stored.where((record) => record.anonProfileId == anonProfileId))
      ..addAll(pending)
      ..sort(_compareDemandRecords);
    _pendingRemoteRecords
      ..clear()
      ..addAll(
        storedRemote.where((record) => record.anonProfileId == anonProfileId),
      )
      ..addAll(pendingRemote)
      ..sort(_compareDemandRecords);
  }

  Future<void> _writeRecords() async {
    await _loaded;
    final preferences = await _resolvePreferences();
    final stored = _decodeRecords(preferences.getStringList(storageKey));
    final merged = <PrepBriefDemandSignalRecord>[
      for (final record in stored)
        if (record.anonProfileId != anonProfileId) record,
      ..._records,
    ]..sort(_compareDemandRecords);
    await preferences.setStringList(storageKey, <String>[
      for (final record in merged) jsonEncode(record.toJson()),
    ]);
  }

  Future<void> _writePendingRemoteRecords() async {
    await _loaded;
    final preferences = await _resolvePreferences();
    final stored = _decodeRecords(preferences.getStringList(pendingStorageKey));
    final merged = <PrepBriefDemandSignalRecord>[
      for (final record in stored)
        if (record.anonProfileId != anonProfileId) record,
      ..._pendingRemoteRecords,
    ]..sort(_compareDemandRecords);
    await preferences.setStringList(pendingStorageKey, <String>[
      for (final record in merged) jsonEncode(record.toJson()),
    ]);
  }

  Future<void> _flushRemote() async {
    await _loaded;
    await _pendingRemoteBufferWrite;
    final endpoint = funnelEndpoint;
    if (endpoint == null || _pendingRemoteRecords.isEmpty) {
      return;
    }
    while (_pendingRemoteRecords.isNotEmpty) {
      final beforeFlush = List<PrepBriefDemandSignalRecord>.of(
        _pendingRemoteRecords,
      );
      final remaining = <PrepBriefDemandSignalRecord>[];
      var blocked = false;
      for (var index = 0; index < beforeFlush.length; index += 1) {
        final record = beforeFlush[index];
        final accepted = await _funnelPoster(endpoint, record.toJson());
        if (accepted) continue;
        remaining.addAll(beforeFlush.skip(index));
        blocked = true;
        break;
      }
      final appendedDuringFlush = _pendingRemoteRecords
          .skip(beforeFlush.length)
          .toList(growable: false);
      _pendingRemoteRecords
        ..clear()
        ..addAll(remaining)
        ..addAll(appendedDuringFlush);
      _pendingRemoteBufferWrite = _writePendingRemoteRecords();
      unawaited(_pendingRemoteBufferWrite);
      if (blocked) {
        return;
      }
    }
  }

  void _startRemoteFlush() {
    if (funnelEndpoint == null || _remoteFlushInFlight) {
      return;
    }
    _remoteFlushInFlight = true;
    _pendingRemoteFlush = _flushRemote().whenComplete(() {
      _remoteFlushInFlight = false;
    });
    unawaited(_pendingRemoteFlush);
  }

  Future<SharedPreferences> _resolvePreferences() async {
    return preferences ?? SharedPreferences.getInstance();
  }
}

List<PrepBriefDemandSignalRecord> _decodeRecords(List<String>? values) {
  if (values == null || values.isEmpty) {
    return <PrepBriefDemandSignalRecord>[];
  }
  final records = <PrepBriefDemandSignalRecord>[];
  for (final value in values) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, Object?>) {
        records.add(PrepBriefDemandSignalRecord.fromJson(decoded));
      }
    } on Object {
      continue;
    }
  }
  records.sort(_compareDemandRecords);
  return records;
}

int _compareDemandRecords(
  PrepBriefDemandSignalRecord left,
  PrepBriefDemandSignalRecord right,
) {
  final byTime = left.occurredAt.compareTo(right.occurredAt);
  if (byTime != 0) return byTime;
  final byProfile = left.anonProfileId.compareTo(right.anonProfileId);
  if (byProfile != 0) return byProfile;
  return left.eventType.wireName.compareTo(right.eventType.wireName);
}

Widget buildScreenForDestination(
  BuildContext context,
  ShellDestination dest, {
  InterviewFeedbackAccess interviewFeedbackAccess =
      InterviewFeedbackAccess.full,
  String anonProfileId = _defaultAnonProfileId,
  PrepBriefEventSink? prepBriefEventSink,
  InterviewRoundFn? runRound,
}) {
  return switch (dest.lane) {
    CaliberLane.home => HomeScreen(
      destination: dest,
      interviewFeedbackAccess: interviewFeedbackAccess,
      anonProfileId: anonProfileId,
      eventSink: prepBriefEventSink,
      runRound: runRound,
    ),
    CaliberLane.profile => ProfileScreen(destination: dest),
    CaliberLane.corpus => CorpusScreen(destination: dest),
    CaliberLane.interview => InterviewScreen(
      destination: dest,
      feedbackAccess: interviewFeedbackAccess,
    ),
    CaliberLane.resume => ResumeScreen(destination: dest),
    CaliberLane.audio => AudioScreen(destination: dest),
    CaliberLane.storage => StorageScreen(destination: dest),
    CaliberLane.billing => BillingScreen(destination: dest),
    CaliberLane.settings => SettingsScreen(destination: dest),
  };
}

enum InterviewFeedbackAccess { teaser, full }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.destination,
    this.interviewFeedbackAccess = InterviewFeedbackAccess.full,
    this.anonProfileId = _defaultAnonProfileId,
    this.eventSink,
    this.runRound,
    this.clock,
    super.key,
  });

  final ShellDestination destination;
  final InterviewFeedbackAccess interviewFeedbackAccess;
  final String anonProfileId;
  final PrepBriefEventSink? eventSink;
  final InterviewRoundFn? runRound;
  final DateTime Function()? clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _jdController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentLevelController = TextEditingController(
    text: 'Mid-level',
  );
  final TextEditingController _targetLevelController = TextEditingController(
    text: 'Senior',
  );
  final TextEditingController _timelineController = TextEditingController(
    text: '90-day pass',
  );
  final List<CalibrationEngagementEvent> _engagementEvents =
      <CalibrationEngagementEvent>[];
  late final PrepBriefEventSink _eventSink;
  late final JdPrepBriefGenerator _generator;
  late final InterviewRoundMemoryStore _memoryStore;
  PrepBrief? _brief;
  JobPacketViewModel? _jobPacketViewModel;
  PrepBriefViewModel? _prepBriefViewModel;
  PracticeRoomViewModel? _practiceRoomViewModel;
  VerdictArtifactViewModel? _verdictArtifactViewModel;
  EvidenceInspectViewModel? _evidenceInspectViewModel;
  RetestPlanViewModel? _retestPlanViewModel;
  BackendMapViewModel? _backendMapViewModel;
  InterviewPracticeQuestion? _practiceQuestion;
  InterviewContentJudgment? _latestJudgment;
  String? _statusMessage;
  bool _isGenerating = false;
  bool _firstPaidEvalRecorded = false;
  bool _verdictCompletedRecorded = false;
  bool _inspectOpenedRecorded = false;
  int _practiceAttemptOrdinal = 0;

  @override
  void initState() {
    super.initState();
    _eventSink =
        widget.eventSink ??
        PersistentPrepBriefEventSink(
          anonProfileId: widget.anonProfileId,
          clock: widget.clock,
        );
    _generator = JdPrepBriefGenerator(eventSink: _eventSink);
    _memoryStore = InMemoryInterviewRoundMemoryStore();
  }

  @override
  void dispose() {
    _jdController.dispose();
    _resumeController.dispose();
    _emailController.dispose();
    _currentLevelController.dispose();
    _targetLevelController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    final brief = _brief;
    final jobPacket = _jobPacketViewModel;
    final briefViewModel = _prepBriefViewModel;
    final practiceRoom = _practiceRoomViewModel;
    final verdict = _verdictArtifactViewModel;
    final inspect = _evidenceInspectViewModel;
    final retest = _retestPlanViewModel;
    final backendMap = _backendMapViewModel;
    return Material(
      color: tokens.colors.surface,
      child: SafeArea(
        child: ListView(
          padding: tokens.spacing.insetPanel,
          scrollCacheExtent: const ScrollCacheExtent.viewport(4.0),
          children: [
            CaliberInfoCard(
              leading: Icon(
                Icons.home_outlined,
                color: tokens.colors.accent,
                size: tokens.spacing.xl,
              ),
              title: const Text('Next action'),
              body: Semantics(
                label: 'Job packet intake',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _jdController,
                      minLines: 6,
                      maxLines: 10,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Paste Backend Senior JD',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.md),
                    TextField(
                      controller: _resumeController,
                      minLines: 3,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        labelText: 'Optional resume evidence',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Wrap(
                      spacing: tokens.spacing.sm,
                      runSpacing: tokens.spacing.sm,
                      children: [
                        SizedBox(
                          width: tokens.spacing.section * 2.8,
                          child: TextField(
                            controller: _currentLevelController,
                            decoration: const InputDecoration(
                              labelText: 'Current level',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: tokens.spacing.section * 2.8,
                          child: TextField(
                            controller: _targetLevelController,
                            decoration: const InputDecoration(
                              labelText: 'Target level',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: tokens.spacing.section * 2.8,
                          child: TextField(
                            controller: _timelineController,
                            decoration: const InputDecoration(
                              labelText: 'Timeline',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: tokens.spacing.section * 4,
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email for brief',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateBrief,
                  icon: _isGenerating
                      ? SizedBox.square(
                          dimension: tokens.spacing.lg,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.article_outlined),
                  label: Text(
                    _isGenerating ? 'Preparing' : 'Create job packet',
                  ),
                ),
              ],
              footer: _statusMessage == null ? null : Text(_statusMessage!),
            ),
            if (jobPacket != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _JobPacketPanel(packet: jobPacket),
            ],
            if (brief != null && briefViewModel != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _PrepBriefPanel(
                brief: brief,
                viewModel: briefViewModel,
                onPractice: _startPractice,
              ),
            ],
            if (_practiceQuestion case final question?) ...[
              if (practiceRoom != null) ...[
                SizedBox(height: tokens.spacing.lg),
                _PracticeRoomPanel(room: practiceRoom),
              ],
              SizedBox(height: tokens.spacing.lg),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.92,
                child: InterviewScreen(
                  key: ValueKey(_practiceAttemptOrdinal),
                  destination: caliberShellDestinations.firstWhere(
                    (dest) => dest.lane == CaliberLane.interview,
                  ),
                  question: question,
                  feedbackAccess: widget.interviewFeedbackAccess,
                  memoryStore: _memoryStore,
                  onRoundComplete: _handleRoundComplete,
                  runRound: (practiceQuestion, answer) {
                    final currentBrief = _brief;
                    if (currentBrief != null && !_firstPaidEvalRecorded) {
                      _firstPaidEvalRecorded = true;
                      _generator.recordFirstPaidEvalStarted(currentBrief);
                    }
                    final runRound = widget.runRound ?? runInterviewRound;
                    return runRound(practiceQuestion, answer);
                  },
                ),
              ),
            ],
            if (verdict != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _VerdictArtifactPanel(verdict: verdict),
            ],
            if (verdict != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _InspectLauncherPanel(onInspect: _openInspect),
            ],
            if (inspect != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _EvidenceInspectPanel(inspect: inspect),
            ],
            if (retest != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _RetestPlanPanel(plan: retest, onRetest: _startRetest),
            ],
            if (backendMap != null) ...[
              SizedBox(height: tokens.spacing.lg),
              _BackendMapPanel(map: backendMap),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateBrief() async {
    final jd = _jdController.text.trim();
    if (jd.isEmpty) {
      setState(() => _statusMessage = 'Paste a JD before generating a brief.');
      return;
    }
    setState(() {
      _isGenerating = true;
      _statusMessage = null;
      _practiceQuestion = null;
      _jobPacketViewModel = null;
      _prepBriefViewModel = null;
      _practiceRoomViewModel = null;
      _verdictArtifactViewModel = null;
      _evidenceInspectViewModel = null;
      _retestPlanViewModel = null;
      _backendMapViewModel = null;
      _latestJudgment = null;
      _engagementEvents.clear();
      _firstPaidEvalRecorded = false;
      _verdictCompletedRecorded = false;
      _inspectOpenedRecorded = false;
    });
    try {
      final brief = await _generator.generate(
        PrepBriefInput(
          jobDescription: jd,
          resumeText: _resumeController.text.trim().isEmpty
              ? null
              : _resumeController.text,
          targetLevel: _targetLevelController.text.trim().isEmpty
              ? 'Senior'
              : _targetLevelController.text,
        ),
      );
      if (_emailController.text.trim().isNotEmpty) {
        _generator.recordEmailCapture(brief);
      }
      if (!mounted) return;
      setState(() {
        _brief = brief;
        _jobPacketViewModel = JobPacketViewModel.fromBrief(
          brief: brief,
          currentLevel: _currentLevelController.text,
          timeline: _timelineController.text,
          hasResumeEvidence: _resumeController.text.trim().isNotEmpty,
        );
        _prepBriefViewModel = PrepBriefViewModel.fromBrief(brief);
        _statusMessage =
            'Job packet and prep brief saved with ${brief.corpusBundleVersion}.';
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Brief could not be generated.');
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, library: 'caliber_screens'),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _startPractice() {
    final brief = _brief;
    if (brief == null) return;
    final question = _generator.recordPracticeStartClick(brief);
    setState(() {
      _practiceQuestion = question;
      _practiceRoomViewModel = PracticeRoomViewModel.fromQuestion(
        question: question,
        brief: brief,
      );
      _verdictArtifactViewModel = null;
      _evidenceInspectViewModel = null;
      _retestPlanViewModel = null;
      _latestJudgment = null;
      _verdictCompletedRecorded = false;
      _inspectOpenedRecorded = false;
      _practiceAttemptOrdinal += 1;
      _statusMessage = 'Practice loaded from the top brief question.';
    });
  }

  void _handleRoundComplete(
    InterviewContentJudgment judgment,
    InterviewRoundComparison? comparison,
  ) {
    final brief = _brief;
    final question = _practiceQuestion;
    if (brief != null && !_verdictCompletedRecorded) {
      _verdictCompletedRecorded = true;
      _recordBriefEvent(
        PrepBriefEventType.verdictCompleted,
        brief: brief,
        questionId: judgment.questionId,
      );
    }
    final event = CalibrationEngagementEvent.verdictRecorded(
      judgment: judgment,
      comparison: comparison,
    );
    _engagementEvents.add(event);
    final state = buildBackendEngagementState(
      profileId: judgment.profileId,
      events: _engagementEvents,
      now: widget.clock?.call(),
    );
    final verdict = VerdictArtifactViewModel.fromJudgment(
      judgment: judgment,
      comparison: comparison,
    );
    if (!mounted) return;
    setState(() {
      _latestJudgment = judgment;
      _verdictArtifactViewModel = verdict;
      _evidenceInspectViewModel = null;
      _retestPlanViewModel = question == null
          ? null
          : RetestPlanViewModel.fromVerdict(
              question: question,
              verdict: verdict,
            );
      _backendMapViewModel = BackendMapViewModel.fromEngagementState(state);
      _statusMessage =
          'Verdict completed with ${verdict.policy.corpusBundleVersion}.';
    });
  }

  void _openInspect() {
    final brief = _brief;
    final judgment = _latestJudgment;
    if (brief == null || judgment == null) return;
    if (!_inspectOpenedRecorded) {
      _inspectOpenedRecorded = true;
      _recordBriefEvent(
        PrepBriefEventType.inspectOpened,
        brief: brief,
        questionId: judgment.questionId,
      );
    }
    setState(() {
      _evidenceInspectViewModel = EvidenceInspectViewModel.fromJudgment(
        judgment,
      );
      _statusMessage = 'Evidence inspect opened for this verdict.';
    });
  }

  void _startRetest() {
    final brief = _brief;
    final question = _practiceQuestion;
    if (brief == null || question == null) return;
    _recordBriefEvent(
      PrepBriefEventType.retestStarted,
      brief: brief,
      questionId: question.questionId,
    );
    setState(() {
      _practiceAttemptOrdinal += 1;
      _evidenceInspectViewModel = null;
      _latestJudgment = null;
      _verdictCompletedRecorded = false;
      _inspectOpenedRecorded = false;
      _statusMessage = 'Retest ready on the same Backend archetype.';
    });
  }

  void _recordBriefEvent(
    PrepBriefEventType type, {
    required PrepBrief brief,
    String? questionId,
  }) {
    _eventSink.record(
      PrepBriefEvent(
        type: type,
        sourceHash: brief.sourceHash,
        questionId: questionId ?? brief.practiceQuestion.questionId,
        corpusBundleVersion: brief.corpusBundleVersion,
      ),
    );
  }
}

class _JobPacketPanel extends StatelessWidget {
  const _JobPacketPanel({required this.packet});

  final JobPacketViewModel packet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Active job packet',
      child: CaliberAnalysisPanel(
        heading: const Text('Job packet'),
        summary: Text(
          '${packet.normalizedTitle}: ${packet.currentLevel} to ${packet.targetLevel}',
        ),
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline: ${packet.timeline}'),
            Text(
              'Resume evidence: ${packet.hasResumeEvidence ? 'included' : 'not added'}',
            ),
            Text('Corpus: ${packet.corpusBundleVersion}'),
            Text('Rubric: ${packet.rubricVersion}'),
          ],
        ),
      ),
    );
  }
}

class _PrepBriefPanel extends StatelessWidget {
  const _PrepBriefPanel({
    required this.brief,
    required this.viewModel,
    required this.onPractice,
  });

  final PrepBrief brief;
  final PrepBriefViewModel viewModel;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return CaliberAnalysisPanel(
      heading: const Text('Prep brief'),
      summary: Text(
        '${viewModel.normalizedTitle} using ${viewModel.rubricVersion}.',
      ),
      detail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PrepSection(
            title: 'Round mix forecast',
            children: [
              for (final item in brief.roundMixForecast)
                Text('${item.label}: ${item.rationale}'),
            ],
          ),
          _PrepSection(
            title: 'Likely questions',
            children: [
              for (final question in brief.likelyQuestions)
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${question.rank}. ${question.title}'),
                      Text(question.prompt),
                      Text(question.rationale),
                    ],
                  ),
                ),
            ],
          ),
          _PrepSection(
            title: 'What good looks like',
            children: [
              for (final scaffold in brief.rubricScaffolds.take(3))
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scaffold.title),
                      for (final criterion in scaffold.criteria.take(3))
                        Text('${criterion.label}: ${criterion.seniorBar}'),
                    ],
                  ),
                ),
            ],
          ),
          _PrepSection(
            title: 'Down-level risks',
            children: [
              for (final risk in brief.downLevelRiskNotes.take(5))
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(risk.title),
                      Text(risk.note),
                      for (final flag in risk.redFlags.take(2))
                        Text('Red flag: $flag'),
                    ],
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onPractice,
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Start practice'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeRoomPanel extends StatelessWidget {
  const _PracticeRoomPanel({required this.room});

  final PracticeRoomViewModel room;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Semantics(
      label: 'Practice room shell',
      child: CaliberAnalysisPanel(
        heading: const Text('Practice room'),
        summary: Text('${room.title} (${room.levelBand})'),
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.prompt),
            SizedBox(height: tokens.spacing.md),
            _PrepSection(
              title: 'Senior-bar criteria',
              children: [
                for (final criterion in room.seniorBarCriteria.take(5))
                  Text(criterion),
              ],
            ),
            _PrepSection(
              title: 'Vocabulary to use precisely',
              children: [Text(room.glossary.take(8).join(', '))],
            ),
          ],
        ),
      ),
    );
  }
}

class _VerdictArtifactPanel extends StatelessWidget {
  const _VerdictArtifactPanel({required this.verdict});

  final VerdictArtifactViewModel verdict;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verdict artifact',
      child: CaliberAnalysisPanel(
        heading: const Text('Verdict artifact'),
        summary: Text(
          '${verdict.levelBand} using ${verdict.policy.rubricVersion}.',
        ),
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FeedbackSection(
              title: 'Strengths',
              items: verdict.contentStrengths,
            ),
            _FeedbackSection(title: 'Risks', items: verdict.contentRisks),
            _FeedbackSection(
              title: 'Evidence quotes',
              items: verdict.evidenceQuotes,
            ),
            _FeedbackSection(
              title: 'One fix',
              items: [verdict.highestLeverageFix],
            ),
            if (verdict.comparison.isNotEmpty)
              _FeedbackSection(
                title: 'Compared with last attempt',
                items: verdict.comparison,
              ),
            _FeedbackSection(
              title: 'Policy tuple',
              items: [
                'Corpus ${verdict.policy.corpusBundleVersion}',
                'Schema ${verdict.policy.schemaVersion}',
                'Model ${verdict.policy.modelPin}',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectLauncherPanel extends StatelessWidget {
  const _InspectLauncherPanel({required this.onInspect});

  final VoidCallback onInspect;

  @override
  Widget build(BuildContext context) {
    return CaliberInfoCard(
      leading: Icon(
        Icons.fact_check_outlined,
        color: context.caliberTokens.colors.accent,
      ),
      title: const Text('Inspect why'),
      body: const Text(
        'Open the evidence map behind this verdict: exact answer quotes to rubric criteria.',
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: onInspect,
          icon: const Icon(Icons.manage_search_outlined),
          label: const Text('Open evidence inspect'),
        ),
      ],
    );
  }
}

class _EvidenceInspectPanel extends StatelessWidget {
  const _EvidenceInspectPanel({required this.inspect});

  final EvidenceInspectViewModel inspect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Evidence inspect view',
      child: CaliberAnalysisPanel(
        heading: const Text('Evidence inspect'),
        summary: Text('Rubric ${inspect.rubricVersion}.'),
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in inspect.items)
              _PrepSection(
                title: '${item.criterionLabel}: ${item.state}',
                children: [
                  Text(item.finding),
                  if (item.quote.isNotEmpty) Text('Quote: "${item.quote}"'),
                  Text('Down-level reason: ${item.downLevelReason}'),
                  Text('Minimum fix: ${item.minimumFix}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RetestPlanPanel extends StatelessWidget {
  const _RetestPlanPanel({required this.plan, required this.onRetest});

  final RetestPlanViewModel plan;
  final VoidCallback onRetest;

  @override
  Widget build(BuildContext context) {
    return CaliberAnalysisPanel(
      heading: const Text('Retest plan'),
      summary: Text(plan.title),
      detail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.reason),
          Text('Next fix: ${plan.highestLeverageFix}'),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onRetest,
              icon: const Icon(Icons.replay_outlined),
              label: const Text('Retest same archetype'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendMapPanel extends StatelessWidget {
  const _BackendMapPanel({required this.map});

  final BackendMapViewModel map;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Backend map memory',
      child: CaliberAnalysisPanel(
        heading: const Text('Backend map'),
        summary: Text(map.completionLabel),
        detail: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrepSection(
              title: 'Next retest',
              children: [Text(map.nextRetest['reason']! as String)],
            ),
            _PrepSection(
              title: 'Prep sprint',
              children: [Text(map.prepSprint['message']! as String)],
            ),
            if (map.breakthroughs.isNotEmpty)
              _PrepSection(
                title: 'Breakthroughs',
                children: [
                  for (final item in map.breakthroughs)
                    Text(item['message']! as String),
                ],
              ),
            _PrepSection(
              title: 'Map cells',
              children: [
                for (final cell in map.cells.take(5))
                  Text('${cell['title']}: ${cell['level_band']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrepSection extends StatelessWidget {
  const _PrepSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tokens.typography.label),
          SizedBox(height: tokens.spacing.xs),
          ...children,
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.work_outline,
      description:
          'Job packets, saved prep context, and recovery state are organized here.',
    );
  }
}

class CorpusScreen extends StatelessWidget {
  const CorpusScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.map_outlined,
      description:
          'Backend map, attempt memory, and retest priorities are summarized here.',
      footer: _SearchCorpusControl(destination: destination),
    );
  }
}

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({
    required this.destination,
    this.question = kSeedBackendPracticeQuestion,
    this.runRound,
    this.voiceInput = const NoConfiguredInterviewVoiceInput(),
    this.feedbackAccess = InterviewFeedbackAccess.full,
    this.memoryStore,
    this.onRoundComplete,
    this.trailing,
    this.trailingBuilder,
    super.key,
  });

  final ShellDestination destination;
  final InterviewPracticeQuestion question;
  final InterviewRoundFn? runRound;
  final InterviewVoiceInput voiceInput;
  final InterviewFeedbackAccess feedbackAccess;
  final InterviewRoundMemoryStore? memoryStore;
  final void Function(
    InterviewContentJudgment judgment,
    InterviewRoundComparison? comparison,
  )?
  onRoundComplete;
  final Widget? trailing;
  final Widget Function(
    InterviewContentJudgment judgment,
    InterviewRoundComparison? comparison,
  )?
  trailingBuilder;

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  late final InterviewRoundMemoryStore _memoryStore;
  InterviewContentJudgment? _judgment;
  InterviewRoundComparison? _comparison;
  Widget? _roundTrailing;
  String? _statusMessage;
  bool _isRunning = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _memoryStore = widget.memoryStore ?? InMemoryInterviewRoundMemoryStore();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Material(
      color: tokens.colors.surface,
      child: SafeArea(
        child: ListView(
          padding: tokens.spacing.insetPanel,
          scrollCacheExtent: const ScrollCacheExtent.viewport(4.0),
          children: [
            CaliberInfoCard(
              leading: Icon(
                Icons.forum_outlined,
                color: tokens.colors.accent,
                size: tokens.spacing.xl,
              ),
              title: const Text('Practice room'),
              body: Semantics(
                label: 'Targeted Backend to Senior question',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.question.title),
                    SizedBox(height: tokens.spacing.xs),
                    Text(widget.question.prompt),
                    SizedBox(height: tokens.spacing.md),
                    Text('Senior bar', style: tokens.typography.label),
                    SizedBox(height: tokens.spacing.xs),
                    Text(widget.question.seedRubric),
                  ],
                ),
              ),
              footer: Wrap(
                spacing: tokens.spacing.sm,
                runSpacing: tokens.spacing.xs,
                children: [
                  _InlinePill(widget.question.target.domain),
                  _InlinePill(widget.question.target.levelBand),
                  _InlinePill(widget.question.rubricVersion),
                ],
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            CaliberInfoCard(
              title: const Text('Your answer'),
              body: Semantics(
                label: 'Answer capture field',
                textField: true,
                child: TextField(
                  controller: _answerController,
                  minLines: 6,
                  maxLines: 10,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText:
                        'Type your answer here. Mention the bottleneck, tradeoff, failure mode, and measurement.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              actions: [
                OutlinedButton.icon(
                  onPressed: _isRecording || _isRunning ? null : _recordAnswer,
                  icon: _isRecording
                      ? SizedBox.square(
                          dimension: tokens.spacing.lg,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.mic_none),
                  label: Text(_isRecording ? 'Recording' : 'Record'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runRound,
                  icon: _isRunning
                      ? SizedBox.square(
                          dimension: tokens.spacing.lg,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.insights),
                  label: Text(_isRunning ? 'Reviewing' : 'Submit answer'),
                ),
              ],
              footer: _statusMessage == null ? null : Text(_statusMessage!),
            ),
            if (_judgment case final judgment?) ...[
              SizedBox(height: tokens.spacing.lg),
              switch (widget.feedbackAccess) {
                InterviewFeedbackAccess.full => _InterviewFeedbackPanel(
                  judgment: judgment,
                  comparison: _comparison,
                ),
                InterviewFeedbackAccess.teaser => _InterviewFeedbackTeaser(
                  judgment: judgment,
                ),
              },
              if ((_roundTrailing ?? widget.trailing) case final trailing?) ...[
                SizedBox(height: tokens.spacing.lg),
                trailing,
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _recordAnswer() async {
    setState(() {
      _isRecording = true;
      _statusMessage = null;
    });
    try {
      if (!await widget.voiceInput.isAvailable()) {
        setState(() => _statusMessage = widget.voiceInput.unavailableMessage);
        return;
      }
      final text = await widget.voiceInput.recordAndTranscribeAnswer();
      setState(() {
        _answerController.text = text;
        _statusMessage = 'Voice transcript added. Review it before feedback.';
      });
    } on Object catch (error) {
      setState(() {
        _statusMessage = 'Voice input unavailable. Type your answer below.';
      });
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, library: 'caliber_screens'),
      );
    } finally {
      if (mounted) {
        setState(() => _isRecording = false);
      }
    }
  }

  Future<void> _runRound() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      setState(() => _statusMessage = 'Add an answer before submitting.');
      return;
    }
    setState(() {
      _isRunning = true;
      _statusMessage = null;
    });
    try {
      final runRound = widget.runRound ?? runInterviewRound;
      final judgment = await runRound(widget.question, answer);
      final comparison = await rememberInterviewJudgment(
        memoryStore: _memoryStore,
        judgment: judgment,
      );
      widget.onRoundComplete?.call(judgment, comparison);
      final trailing = widget.trailingBuilder?.call(judgment, comparison);
      setState(() {
        _judgment = judgment;
        _comparison = comparison;
        _roundTrailing = trailing;
        _statusMessage = switch (widget.feedbackAccess) {
          InterviewFeedbackAccess.full =>
            'Verdict sheet shown for this local build.',
          InterviewFeedbackAccess.teaser =>
            'Preview shown. Full evidence requires an active pass.',
        };
      });
    } on Object catch (error) {
      setState(() {
        _statusMessage = 'Verdict could not be generated for this answer.';
      });
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, library: 'caliber_screens'),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }
}

class ResumeScreen extends StatelessWidget {
  const ResumeScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.description_outlined,
      description:
          'Resume rewriting and role-targeted evidence assembly will be staged from this route.',
      actions: const [_StartActionButton()],
    );
  }
}

class AudioScreen extends StatelessWidget {
  const AudioScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.mic_none_outlined,
      description:
          'Audio capture and transcript review stay isolated from speech integrations.',
    );
  }
}

class StorageScreen extends StatelessWidget {
  const StorageScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.folder_outlined,
      description:
          'Local storage, sync state, and source-document status will be summarized here.',
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.credit_card_outlined,
      description:
          'Plan and entitlement details will appear here after billing integration.',
      footer: const _CurrentPlanSummary(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.destination, super.key});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      destination: destination,
      icon: Icons.settings_outlined,
      description:
          'Workspace preferences, privacy controls, and app defaults will be configured here.',
    );
  }
}

class _RouteScaffold extends StatelessWidget {
  const _RouteScaffold({
    required this.destination,
    required this.icon,
    required this.description,
    this.actions = const [],
    this.footer,
  });

  final ShellDestination destination;
  final IconData icon;
  final String description;
  final List<Widget> actions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return ColoredBox(
      color: tokens.colors.surface,
      child: SafeArea(
        child: Padding(
          padding: tokens.spacing.insetPanel,
          child: Center(
            child: CaliberInfoCard(
              leading: Icon(
                icon,
                color: tokens.colors.accent,
                size: tokens.spacing.xl,
              ),
              title: Text(destination.label),
              body: Text(description),
              actions: actions,
              footer: footer,
            ),
          ),
        ),
      ),
    );
  }
}

class _StartActionButton extends StatelessWidget {
  const _StartActionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start'),
    );
  }
}

class _InterviewFeedbackPanel extends StatelessWidget {
  const _InterviewFeedbackPanel({required this.judgment, this.comparison});

  final InterviewContentJudgment judgment;
  final InterviewRoundComparison? comparison;

  @override
  Widget build(BuildContext context) {
    final viewModel = InterviewFeedbackViewModel.fromJudgment(judgment);
    return CaliberAnalysisPanel(
      heading: const Text('Verdict sheet'),
      summary: Text('${viewModel.levelRead} using ${viewModel.rubricVersion}.'),
      detail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeedbackSection(
            title: 'Content strengths',
            items: viewModel.contentStrengths,
          ),
          _FeedbackSection(
            title: 'Content risks',
            items: viewModel.contentRisks,
          ),
          _FeedbackSection(
            title: 'Delivery strengths',
            items: viewModel.deliveryStrengths,
          ),
          _FeedbackSection(
            title: 'Delivery risks',
            items: viewModel.deliveryRisks,
          ),
          _FeedbackSection(
            title: 'Next actions',
            items: viewModel.recommendedActions,
          ),
          _RubricMappingSection(mappings: viewModel.rubricMappings),
          if (comparison case final item?)
            _FeedbackSection(
              title: 'Compared with last round',
              items: item.summaryBullets,
            ),
          _QuoteSection(quotes: viewModel.quotes),
        ],
      ),
    );
  }
}

class _RubricMappingSection extends StatelessWidget {
  const _RubricMappingSection({required this.mappings});

  final List<InterviewRubricMappingViewModel> mappings;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    if (mappings.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why we judged this', style: tokens.typography.label),
          SizedBox(height: tokens.spacing.xs),
          for (final mapping in mappings)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${mapping.criterionLabel}: ${mapping.finding}'),
                  if (mapping.quote.isNotEmpty)
                    Text('Evidence: "${mapping.quote}"'),
                  Text('Minimum fix: ${mapping.minimumFix}'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InterviewFeedbackTeaser extends StatelessWidget {
  const _InterviewFeedbackTeaser({required this.judgment});

  final InterviewContentJudgment judgment;

  @override
  Widget build(BuildContext context) {
    final viewModel = InterviewFeedbackViewModel.fromJudgment(judgment);
    final previewItems = <String>[
      if (viewModel.contentStrengths.isNotEmpty)
        viewModel.contentStrengths.first,
      'Full pass keeps cited evidence, risks, next actions, and prior-round comparison.',
    ];
    return CaliberAnalysisPanel(
      heading: const Text('Verdict preview'),
      summary: Text('Preview for ${judgment.levelBand} calibration.'),
      detail: _FeedbackSection(title: 'Preview', items: previewItems),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tokens.typography.label),
          SizedBox(height: tokens.spacing.xs),
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.spacing.xs),
              child: Text('- $item'),
            ),
        ],
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection({required this.quotes});

  final List<String> quotes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    if (quotes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Answer evidence', style: tokens.typography.label),
        SizedBox(height: tokens.spacing.xs),
        for (final quote in quotes)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacing.xs),
            child: Text('"$quote"'),
          ),
      ],
    );
  }
}

class _InlinePill extends StatelessWidget {
  const _InlinePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colors.surfaceRaised,
        border: Border.all(color: tokens.colors.divider),
        borderRadius: tokens.radii.control,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
        child: Text(label),
      ),
    );
  }
}

class _SearchCorpusControl extends StatelessWidget {
  const _SearchCorpusControl({required this.destination});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return Semantics(
      textField: true,
      label: '${destination.label} search',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.colors.surfaceRaised,
          border: Border.all(color: tokens.colors.divider),
          borderRadius: tokens.radii.control,
        ),
        child: Padding(
          padding: tokens.spacing.insetControl,
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: tokens.colors.onSurfaceMuted,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  'Search corpus',
                  style: tokens.typography.body.copyWith(
                    color: tokens.colors.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentPlanSummary extends StatelessWidget {
  const _CurrentPlanSummary();

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colors.surfaceRaised,
        border: Border.all(color: tokens.colors.divider),
        borderRadius: tokens.radii.control,
      ),
      child: Padding(
        padding: tokens.spacing.insetControl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: tokens.colors.accent,
              size: tokens.spacing.lg,
            ),
            SizedBox(width: tokens.spacing.sm),
            Text(
              'Current plan: Free trial eval',
              style: tokens.typography.label.copyWith(
                color: tokens.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
