import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Glass Kit components in light theme', (tester) async {
    await tester.pumpWidget(_GoldenHarness(theme: CaliberTheme.light()));
    await expectLater(
      find.byType(_GoldenSurface),
      matchesGoldenFile('goldens/glass_components_light.png'),
    );
  });

  testWidgets('renders Glass Kit components in dark theme', (tester) async {
    await tester.pumpWidget(_GoldenHarness(theme: CaliberTheme.dark()));
    await expectLater(
      find.byType(_GoldenSurface),
      matchesGoldenFile('goldens/glass_components_dark.png'),
    );
  });

  testWidgets('renders reduced-transparency fallback', (tester) async {
    await tester.pumpWidget(
      _GoldenHarness(
        theme: CaliberTheme.light(),
        reducedTransparencyOnly: true,
      ),
    );
    await expectLater(
      find.byType(_GoldenSurface),
      matchesGoldenFile('goldens/glass_components_reduced_transparency.png'),
    );
  });
}

class _GoldenHarness extends StatelessWidget {
  const _GoldenHarness({
    required this.theme,
    this.reducedTransparencyOnly = false,
  });

  final ThemeData theme;
  final bool reducedTransparencyOnly;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: _GoldenSurface(reducedTransparencyOnly: reducedTransparencyOnly),
    );
  }
}

class _GoldenSurface extends StatelessWidget {
  const _GoldenSurface({required this.reducedTransparencyOnly});

  final bool reducedTransparencyOnly;

  @override
  Widget build(BuildContext context) {
    final tokens = context.caliberTokens;
    final entries = reducedTransparencyOnly
        ? [GlassKitCatalog.entries().last]
        : GlassKitCatalog.entries();

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: tokens.spacing.section * 6,
          child: ListView.separated(
            padding: EdgeInsets.all(tokens.spacing.xl),
            itemBuilder: (context, index) => entries[index].builder(context),
            separatorBuilder: (context, index) {
              return SizedBox(height: tokens.spacing.lg);
            },
            itemCount: entries.length,
          ),
        ),
      ),
    );
  }
}
