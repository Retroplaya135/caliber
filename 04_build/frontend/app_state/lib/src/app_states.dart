import 'package:caliber_shared/caliber_shared.dart' as schema;

final class ProfileState {
  const ProfileState({required this.profiles, this.activeProfileId});

  const ProfileState.empty()
    : profiles = const <schema.ProfileIdentity>[],
      activeProfileId = null;

  final List<schema.ProfileIdentity> profiles;
  final String? activeProfileId;
}

final class CorpusSearchState {
  const CorpusSearchState({required this.results, this.activeQuery});

  const CorpusSearchState.empty()
    : results = const <schema.CorpusRetrievalResult>[],
      activeQuery = null;

  final List<schema.CorpusRetrievalResult> results;
  final schema.CorpusQuery? activeQuery;
}

final class InterviewSessionState {
  const InterviewSessionState({required this.judgments, this.activeTranscript});

  const InterviewSessionState.empty()
    : judgments = const <schema.InterviewContentJudgment>[],
      activeTranscript = null;

  final List<schema.InterviewContentJudgment> judgments;
  final schema.Transcript? activeTranscript;
}

final class EntitlementState {
  const EntitlementState({this.snapshot, this.lastDecision});

  const EntitlementState.empty() : snapshot = null, lastDecision = null;

  final schema.EntitlementSnapshot? snapshot;
  final schema.EntitlementDecision? lastDecision;
}
