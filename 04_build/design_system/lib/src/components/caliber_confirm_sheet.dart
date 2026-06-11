import 'package:flutter/material.dart';

import '../primitives/caliber_glass_surface.dart';
import '../tokens/caliber_tokens.dart';

class CaliberConfirmSheet extends StatelessWidget {
  const CaliberConfirmSheet({
    required this.title,
    required this.body,
    required this.primaryAction,
    this.secondaryAction,
    this.reducedTransparency = false,
    super.key,
  });

  final Widget title;
  final Widget body;
  final Widget primaryAction;
  final Widget? secondaryAction;
  final bool reducedTransparency;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return CaliberGlassSurface(
      role: CaliberGlassRole.modal,
      reducedTransparency: reducedTransparency,
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextStyle.merge(
            style: tokens.typography.title.copyWith(
              color: tokens.colors.onSurface,
            ),
            child: title,
          ),
          SizedBox(height: tokens.spacing.sm),
          DefaultTextStyle.merge(
            style: tokens.typography.body.copyWith(
              color: tokens.colors.onSurfaceMuted,
            ),
            child: body,
          ),
          SizedBox(height: tokens.spacing.lg),
          primaryAction,
          if (secondaryAction != null) ...[
            SizedBox(height: tokens.spacing.sm),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}

Future<T?> showCaliberConfirmSheet<T>({
  required BuildContext context,
  required CaliberConfirmSheetBuilder builder,
}) {
  final tokens = context.caliberTokens;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: tokens.colors.clear,
    barrierColor: tokens.colors.scrim,
    builder: builder,
  );
}

typedef CaliberConfirmSheetBuilder = Widget Function(BuildContext context);
