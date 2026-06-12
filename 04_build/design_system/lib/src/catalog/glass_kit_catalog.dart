import 'package:flutter/material.dart';

import '../components/caliber_analysis_panel.dart';
import '../components/caliber_confirm_sheet.dart';
import '../components/caliber_info_card.dart';
import '../components/caliber_status_badge.dart';
import '../tokens/caliber_tokens.dart';

typedef GlassKitCatalogBuilder = Widget Function(BuildContext context);

@immutable
class GlassKitCatalogEntry {
  const GlassKitCatalogEntry({
    required this.name,
    required this.description,
    required this.builder,
  });

  final String name;
  final String description;
  final GlassKitCatalogBuilder builder;
}

abstract final class GlassKitCatalog {
  static List<GlassKitCatalogEntry> entries() {
    return [
      GlassKitCatalogEntry(
        name: 'InfoCard',
        description: 'Slot-based information card for repeated insight blocks.',
        builder: (context) {
          final tokens = context.caliberTokens;
          return CaliberInfoCard(
            title: const Text('Target-role signal'),
            body: const Text(
              'Your backend examples are strongest when they include measurable latency or scale constraints.',
            ),
            leading: const CaliberStatusBadge(
              label: 'Focus',
              tone: CaliberStatusTone.neutral,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Review'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Later'),
              ),
            ],
            footer: Text(
              'Uses ${tokens.glass.blur.toStringAsFixed(0)} blur token.',
            ),
          );
        },
      ),
      GlassKitCatalogEntry(
        name: 'AnalysisPanel',
        description: 'Focused glass panel for evaluator findings and metrics.',
        builder: (context) {
          return const CaliberAnalysisPanel(
            heading: Text('Interview readiness'),
            summary: Text(
              'Evidence quality is high, but system-design examples need clearer tradeoffs.',
            ),
            status: CaliberStatusBadge(
              label: 'Warn',
              tone: CaliberStatusTone.warning,
            ),
            metrics: [
              CaliberStatusBadge(label: 'Scope 82'),
              CaliberStatusBadge(
                label: 'Evidence 91',
                tone: CaliberStatusTone.success,
              ),
            ],
            detail: Text(
              'Next response should name the bottleneck, the fallback, and the decision boundary.',
            ),
          );
        },
      ),
      GlassKitCatalogEntry(
        name: 'ConfirmSheet',
        description: 'Slot-based confirmation surface for interruptive choices.',
        builder: (context) {
          return CaliberConfirmSheet(
            title: const Text('Discard draft?'),
            body: const Text(
              'This removes the current practice answer from local history.',
            ),
            primaryAction: ElevatedButton(
              onPressed: () {},
              child: const Text('Keep editing'),
            ),
            secondaryAction: OutlinedButton(
              onPressed: () {},
              child: const Text('Discard'),
            ),
          );
        },
      ),
      GlassKitCatalogEntry(
        name: 'ReducedTransparencyFallback',
        description: 'Opaque fallback for users who avoid transparency.',
        builder: (context) {
          return const CaliberInfoCard(
            reducedTransparency: true,
            title: Text('Reduced transparency'),
            body: Text(
              'The surface uses opaque semantic tokens instead of blur while preserving hierarchy.',
            ),
            actions: [],
          );
        },
      ),
    ];
  }
}
