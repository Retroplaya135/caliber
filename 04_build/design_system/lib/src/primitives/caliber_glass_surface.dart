import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/caliber_tokens.dart';

enum CaliberGlassRole {
  chrome,
  panel,
  modal,
}

class CaliberGlassSurface extends StatelessWidget {
  const CaliberGlassSurface({
    required this.child,
    this.role = CaliberGlassRole.panel,
    this.padding,
    this.reducedTransparency = false,
    super.key,
  });

  final Widget child;
  final CaliberGlassRole role;
  final EdgeInsetsGeometry? padding;
  final bool reducedTransparency;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    final glass = tokens.glass;
    final borderRadius = switch (role) {
      CaliberGlassRole.chrome => tokens.radii.control,
      CaliberGlassRole.panel => tokens.radii.panel,
      CaliberGlassRole.modal => tokens.radii.sheet,
    };
    final decoration = BoxDecoration(
      color: reducedTransparency
          ? glass.reducedTransparencyFillColor
          : glass.fillColor,
      borderRadius: borderRadius,
      border: Border.all(
        color: reducedTransparency ? tokens.colors.divider : glass.borderColor,
        width: glass.borderWidth,
      ),
      boxShadow: reducedTransparency ? tokens.elevation.panel : glass.elevation,
    );
    final content = DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: padding ?? tokens.spacing.insetPanel,
        child: child,
      ),
    );

    if (reducedTransparency) {
      return content;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glass.blur,
          sigmaY: glass.blur,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: glass.contrastOverlay),
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}
