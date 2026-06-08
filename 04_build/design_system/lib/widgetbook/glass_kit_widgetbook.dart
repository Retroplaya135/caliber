import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../design_system.dart';
import 'glass_kit_widgetbook.directories.g.dart';

void main() {
  runApp(const GlassKitWidgetbook());
}

@widgetbook.App()
class GlassKitWidgetbook extends StatelessWidget {
  const GlassKitWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Caliber Light',
              data: CaliberTheme.light(),
            ),
            WidgetbookTheme(
              name: 'Caliber Dark',
              data: CaliberTheme.dark(),
            ),
          ],
        ),
      ],
    );
  }
}
