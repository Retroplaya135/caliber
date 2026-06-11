import 'package:flutter/material.dart';

import '../primitives/caliber_glass_surface.dart';
import '../tokens/caliber_tokens.dart';
import 'caliber_status_badge.dart';

class CaliberAnalysisPanel extends StatelessWidget {
  const CaliberAnalysisPanel({
    required this.heading,
    required this.summary,
    this.status,
    this.metrics = const [],
    this.detail,
    this.reducedTransparency = false,
    super.key,
  });

  final Widget heading;
  final Widget summary;
  final CaliberStatusBadge? status;
  final List<Widget> metrics;
  final Widget? detail;
  final bool reducedTransparency;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return CaliberGlassSurface(
      reducedTransparency: reducedTransparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTextStyle.merge(
                  style: tokens.typography.title.copyWith(
                    color: tokens.colors.onSurface,
                  ),
                  child: heading,
                ),
              ),
              if (status != null) ...[
                SizedBox(width: tokens.spacing.md),
                status!,
              ],
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          DefaultTextStyle.merge(
            style: tokens.typography.body.copyWith(
              color: tokens.colors.onSurface,
            ),
            child: summary,
          ),
          if (metrics.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.lg),
            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children: metrics,
            ),
          ],
          if (detail != null) ...[
            SizedBox(height: tokens.spacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.colors.surfaceSunken,
                borderRadius: tokens.radii.control,
                border: Border.all(color: tokens.colors.divider),
              ),
              child: Padding(
                padding: tokens.spacing.insetPanel,
                child: DefaultTextStyle.merge(
                  style: tokens.typography.body.copyWith(
                    color: tokens.colors.onSurfaceMuted,
                  ),
                  child: detail!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
