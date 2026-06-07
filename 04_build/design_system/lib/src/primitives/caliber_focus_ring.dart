import 'package:flutter/material.dart';

import '../tokens/caliber_tokens.dart';

class CaliberFocusRing extends StatelessWidget {
  const CaliberFocusRing({
    required this.child,
    required this.visible,
    super.key,
  });

  final Widget child;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    return AnimatedContainer(
      duration: tokens.motion.fast,
      curve: tokens.motion.standardCurve,
      decoration: BoxDecoration(
        borderRadius: tokens.radii.focus,
        border: Border.all(
          color: visible ? tokens.colors.focus : tokens.colors.clear,
          width: tokens.glass.borderWidth + tokens.glass.borderWidth,
        ),
      ),
      child: child,
    );
  }
}
