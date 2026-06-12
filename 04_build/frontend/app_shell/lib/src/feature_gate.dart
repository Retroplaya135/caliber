enum CaliberFeatureCostClass {
  localFree,
  serverExpensive,
}

enum CaliberFeatureId {
  localCorpusSearch,
  localDeliveryScore,
  localAtsReport,
  gatewayInterviewEval,
  cloudStt,
  resumeRewrite,
}

const Map<CaliberFeatureId, CaliberFeatureCostClass> caliberFeatureCosts = {
  CaliberFeatureId.localCorpusSearch: CaliberFeatureCostClass.localFree,
  CaliberFeatureId.localDeliveryScore: CaliberFeatureCostClass.localFree,
  CaliberFeatureId.localAtsReport: CaliberFeatureCostClass.localFree,
  CaliberFeatureId.gatewayInterviewEval: CaliberFeatureCostClass.serverExpensive,
  CaliberFeatureId.cloudStt: CaliberFeatureCostClass.serverExpensive,
  CaliberFeatureId.resumeRewrite: CaliberFeatureCostClass.serverExpensive,
};

class FeatureGateDecision {
  const FeatureGateDecision({
    required this.featureId,
    required this.allowed,
    required this.reason,
    required this.requiresCredit,
  });

  final CaliberFeatureId featureId;
  final bool allowed;
  final String reason;
  final bool requiresCredit;
}
