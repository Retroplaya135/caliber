import 'package:caliber_app_shell/src/glass_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell glass tokens bridge a Glass Kit-shaped theme extension', (
    tester,
  ) async {
    late GlassChromeTokens resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            _FakeCaliberTokens(
              glass: _FakeGlassTokens(
                blur: 24,
                fillColor: Color(0xB8FFFFFF),
                borderColor: Color(0x47FFFFFF),
              ),
            ),
          ],
        ),
        home: Builder(
          builder: (context) {
            resolved = GlassChromeTokens.resolve(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved.blurSigma, 24);
    expect(resolved.surfaceOpacity, closeTo(0.72, 0.01));
    expect(resolved.borderOpacity, closeTo(0.28, 0.01));
  });
}

@immutable
final class _FakeCaliberTokens extends ThemeExtension<_FakeCaliberTokens> {
  const _FakeCaliberTokens({required this.glass});

  final _FakeGlassTokens glass;

  @override
  _FakeCaliberTokens copyWith({_FakeGlassTokens? glass}) {
    return _FakeCaliberTokens(glass: glass ?? this.glass);
  }

  @override
  _FakeCaliberTokens lerp(
    covariant ThemeExtension<_FakeCaliberTokens>? other,
    double t,
  ) {
    return this;
  }
}

@immutable
final class _FakeGlassTokens {
  const _FakeGlassTokens({
    required this.blur,
    required this.fillColor,
    required this.borderColor,
  });

  final double blur;
  final Color fillColor;
  final Color borderColor;
}
