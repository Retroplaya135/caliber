import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'entitlement_policy.dart';
import 'glass_chrome.dart';
import 'router_manifest.dart';

typedef ShellPageBuilder =
    Widget Function(BuildContext context, ShellDestination destination);

GoRouter buildCaliberRouter({
  required EntitlementSnapshot serverSnapshot,
  required EntitlementPolicy entitlementPolicy,
  required ShellPageBuilder pageBuilder,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            CaliberGlassShell(currentUri: state.uri, child: child),
        routes: [
          for (final destination in caliberShellDestinations)
            GoRoute(
              path: destination.path,
              builder: (context, state) {
                final decision = entitlementPolicy.decide(
                  serverSnapshot: serverSnapshot,
                  featureId: destination.featureId,
                );
                if (!decision.allowed) {
                  return PaywallGate(
                    destination: destination,
                    reason: decision.reason,
                  );
                }
                return pageBuilder(context, destination);
              },
            ),
        ],
      ),
    ],
  );
}

class CaliberGlassShell extends StatelessWidget {
  const CaliberGlassShell({required this.child, this.currentUri, super.key});

  final Widget child;
  final Uri? currentUri;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassChromeTokens.resolve(context);
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex = _selectedMainTabIndex(currentUri?.path ?? '/');
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: scheme.surface),
        child: child,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: tokens.surfaceOpacity),
          border: Border(
            top: BorderSide(
              color: scheme.outline.withValues(alpha: tokens.borderOpacity),
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.go(_mainShellDestinations[index].path);
            },
            destinations: [
              for (final destination in _mainShellDestinations)
                NavigationDestination(
                  icon: Icon(_iconForLane(destination.lane)),
                  selectedIcon: Icon(_selectedIconForLane(destination.lane)),
                  label: destination.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<ShellDestination> get _mainShellDestinations {
  const mainLanes = {
    CaliberLane.home,
    CaliberLane.profile,
    CaliberLane.interview,
    CaliberLane.corpus,
    CaliberLane.settings,
  };
  return [
    for (final destination in caliberShellDestinations)
      if (mainLanes.contains(destination.lane)) destination,
  ];
}

int _selectedMainTabIndex(String path) {
  final index = _mainShellDestinations.indexWhere((destination) {
    if (destination.path == '/') {
      return path == '/';
    }
    return path == destination.path || path.startsWith('${destination.path}/');
  });
  return index < 0 ? 0 : index;
}

IconData _iconForLane(CaliberLane lane) {
  return switch (lane) {
    CaliberLane.home => Icons.home_outlined,
    CaliberLane.interview => Icons.forum_outlined,
    CaliberLane.profile => Icons.work_outline,
    CaliberLane.corpus => Icons.map_outlined,
    CaliberLane.settings => Icons.settings_outlined,
    CaliberLane.resume => Icons.description_outlined,
    CaliberLane.audio ||
    CaliberLane.storage ||
    CaliberLane.billing => Icons.more_horiz,
  };
}

IconData _selectedIconForLane(CaliberLane lane) {
  return switch (lane) {
    CaliberLane.home => Icons.home,
    CaliberLane.interview => Icons.forum,
    CaliberLane.profile => Icons.work,
    CaliberLane.corpus => Icons.map,
    CaliberLane.settings => Icons.settings,
    CaliberLane.resume => Icons.description,
    CaliberLane.audio ||
    CaliberLane.storage ||
    CaliberLane.billing => Icons.more_horiz,
  };
}

class PaywallGate extends StatelessWidget {
  const PaywallGate({
    required this.destination,
    required this.reason,
    super.key,
  });

  final ShellDestination destination;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                destination.label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(reason, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
