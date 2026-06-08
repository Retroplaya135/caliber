// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:caliber_design_system/widgetbook/glass_kit_use_cases.dart'
    as _caliber_design_system_widgetbook_glass_kit_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CaliberAnalysisPanel',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'analysis',
            builder: _caliber_design_system_widgetbook_glass_kit_use_cases
                .analysisPanelUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliberConfirmSheet',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'confirmation',
            builder: _caliber_design_system_widgetbook_glass_kit_use_cases
                .confirmSheetUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliberInfoCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'default',
            builder: _caliber_design_system_widgetbook_glass_kit_use_cases
                .infoCardUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'primitives',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CaliberGlassSurface',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'reduced transparency',
            builder: _caliber_design_system_widgetbook_glass_kit_use_cases
                .reducedTransparencyUseCase,
          ),
        ],
      ),
    ],
  ),
];
