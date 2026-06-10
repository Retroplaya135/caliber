import 'feature_gate.dart';

enum CaliberLane {
  home,
  profile,
  corpus,
  interview,
  resume,
  audio,
  storage,
  billing,
  settings,
}

class ShellDestination {
  const ShellDestination({
    required this.lane,
    required this.path,
    required this.label,
    required this.featureId,
  });

  final CaliberLane lane;
  final String path;
  final String label;
  final CaliberFeatureId featureId;
}

const List<ShellDestination> caliberShellDestinations = [
  ShellDestination(
    lane: CaliberLane.home,
    path: '/',
    label: 'Home',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
  ShellDestination(
    lane: CaliberLane.profile,
    path: '/profile',
    label: 'Packets',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
  ShellDestination(
    lane: CaliberLane.corpus,
    path: '/corpus',
    label: 'Progress',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
  ShellDestination(
    lane: CaliberLane.interview,
    path: '/interview',
    label: 'Practice',
    featureId: CaliberFeatureId.localDeliveryScore,
  ),
  ShellDestination(
    lane: CaliberLane.resume,
    path: '/resume',
    label: 'Resume',
    featureId: CaliberFeatureId.resumeRewrite,
  ),
  ShellDestination(
    lane: CaliberLane.audio,
    path: '/audio',
    label: 'Audio',
    featureId: CaliberFeatureId.cloudStt,
  ),
  ShellDestination(
    lane: CaliberLane.storage,
    path: '/storage',
    label: 'Storage',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
  ShellDestination(
    lane: CaliberLane.billing,
    path: '/billing',
    label: 'Billing',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
  ShellDestination(
    lane: CaliberLane.settings,
    path: '/settings',
    label: 'Settings',
    featureId: CaliberFeatureId.localCorpusSearch,
  ),
];
