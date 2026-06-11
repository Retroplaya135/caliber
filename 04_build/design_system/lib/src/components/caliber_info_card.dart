import 'package:flutter/material.dart';

import '../primitives/caliber_glass_surface.dart';
import '../tokens/caliber_tokens.dart';

class CaliberInfoCard extends StatelessWidget {
  const CaliberInfoCard({
    required this.title,
    required this.body,
    this.leading,
    this.actions = const [],
    this.footer,
    this.reducedTransparency = false,
    super.key,
  });

  final Widget title;
  final Widget body;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? footer;
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
              if (leading != null) ...[
                leading!,
                SizedBox(width: tokens.spacing.md),
              ],
              Expanded(
                child: DefaultTextStyle.merge(
                  style: tokens.typography.title.copyWith(
                    color: tokens.colors.onSurface,
                  ),
                  child: title,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          DefaultTextStyle.merge(
            style: tokens.typography.body.copyWith(
              color: tokens.colors.onSurface,
            ),
            child: body,
          ),
          if (actions.isNotEmpty) ...[
            SizedBox(height: tokens.spacing.lg),
            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children: actions,
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: tokens.spacing.lg),
            DefaultTextStyle.merge(
              style: tokens.typography.caption.copyWith(
                color: tokens.colors.onSurfaceMuted,
              ),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
