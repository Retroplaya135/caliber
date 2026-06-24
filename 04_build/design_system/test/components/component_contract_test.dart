import 'package:caliber_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('focus ring renders visible and hidden states', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: const Scaffold(
          body: Column(
            children: [
              CaliberFocusRing(
                visible: true,
                child: Text('focused'),
              ),
              CaliberFocusRing(
                visible: false,
                child: Text('idle'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('focused'), findsOneWidget);
    expect(find.text('idle'), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNWidgets(2));
  });

  testWidgets('confirm sheet helper uses tokenized modal surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showCaliberConfirmSheet<void>(
                  context: context,
                  builder: (context) {
                    return CaliberConfirmSheet(
                      title: const Text('Confirm'),
                      body: const Text('Tokenized modal'),
                      primaryAction: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary'),
                      ),
                    );
                  },
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(CaliberConfirmSheet), findsOneWidget);
    expect(find.text('Tokenized modal'), findsOneWidget);
  });

  testWidgets('status badge renders every semantic tone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CaliberTheme.light(),
        home: const Scaffold(
          body: Wrap(
            children: [
              CaliberStatusBadge(label: 'Neutral'),
              CaliberStatusBadge(
                label: 'Success',
                tone: CaliberStatusTone.success,
              ),
              CaliberStatusBadge(
                label: 'Warning',
                tone: CaliberStatusTone.warning,
              ),
              CaliberStatusBadge(
                label: 'Danger',
                tone: CaliberStatusTone.danger,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CaliberStatusBadge), findsNWidgets(4));
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text('Danger'), findsOneWidget);
  });
}
