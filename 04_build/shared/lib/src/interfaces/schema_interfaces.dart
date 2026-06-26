import '../data_structures/schema_data_structures.dart';
import '../schemas/ai_output_contracts.dart';
import '../schemas/document_contracts.dart';
import '../schemas/profile_contracts.dart';
import '../schemas/target_contracts.dart';
import '../schemas/transcript_contracts.dart';

enum PrivacyMode {
  localOnly,
  cloudOptIn,
}

abstract interface class StructuredJudge {
  Future<InterviewContentJudgment> judgeInterviewContent({
    required ProfileIdentity profile,
    required TargetRoleCompany target,
    required Transcript transcript,
    required String questionId,
    required String rubricVersion,
    required String promptVersion,
  });

  Future<ResumeBullet> rewriteResumeBullet({
    required ResumeDocument document,
    required TargetRoleCompany target,
    required EvidenceAtom sourceEvidence,
    required String rewritePolicyVersion,
    required String promptVersion,
  });

  Future<ATSReportV2> analyzeAts({
    required ResumeDocument document,
    required TargetRoleCompany target,
    required String atsTestMatrixVersion,
    required String keywordMatchVersion,
  });
}

abstract interface class TranscriptionEngine {
  Future<Transcript> transcribe({
    required String file,
    required String locale,
    required List<String> glossary,
    required PrivacyMode privacyMode,
  });
}

abstract interface class CorpusRetriever {
  Future<CorpusRetrievalResult> retrieve(CorpusQuery query);
}

abstract interface class BillingProvider {
  Future<BillingLedgerEntry> record(BillingLedgerEntry entry);

  Future<EntitlementSnapshot> currentEntitlement({
    required String userId,
  });
}

abstract interface class EntitlementPolicy {
  EntitlementDecision evaluate({
    required EntitlementSnapshot snapshot,
    required String featureKey,
    required String policyVersion,
    required DateTime evaluatedAt,
  });
}
