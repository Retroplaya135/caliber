import 'package:caliber_app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('glass shell exposes only the five main route tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CaliberGlassShell(
          currentUri: Uri(path: '/resume'),
          child: const SizedBox(),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Packets'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);
    expect(find.text('Corpus'), findsNothing);
    expect(find.text('Audio'), findsNothing);
    expect(find.text('Storage'), findsNothing);
    expect(find.text('Billing'), findsNothing);
  });
}
