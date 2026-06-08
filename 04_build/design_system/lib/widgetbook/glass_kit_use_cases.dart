import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../design_system.dart';

Widget _catalogFrame(BuildContext context, Widget child) {
  final tokens = context.caliberTokens;
  return ColoredBox(
    color: tokens.colors.surface,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tokens.spacing.section * 6),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xl),
          child: child,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'default', type: CaliberInfoCard)
Widget infoCardUseCase(BuildContext context) {
  return _catalogFrame(
    context,
    GlassKitCatalog.entries().first.builder(context),
  );
}

@widgetbook.UseCase(name: 'analysis', type: CaliberAnalysisPanel)
Widget analysisPanelUseCase(BuildContext context) {
  return _catalogFrame(
    context,
    GlassKitCatalog.entries().elementAt(1).builder(context),
  );
}

@widgetbook.UseCase(name: 'confirmation', type: CaliberConfirmSheet)
Widget confirmSheetUseCase(BuildContext context) {
  return _catalogFrame(
    context,
    GlassKitCatalog.entries().elementAt(2).builder(context),
  );
}

@widgetbook.UseCase(name: 'reduced transparency', type: CaliberGlassSurface)
Widget reducedTransparencyUseCase(BuildContext context) {
  return _catalogFrame(
    context,
    GlassKitCatalog.entries().elementAt(3).builder(context),
  );
}
