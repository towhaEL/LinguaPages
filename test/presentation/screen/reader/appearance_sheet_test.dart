import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/appearance_sheet.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('AppearanceSheet Widget Tests', () {
    testWidgets('renders all 6 theme swatches and typography slider', (tester) async {
      String? selectedTheme;
      double? changedSize;

      await tester.pumpHarness(
        AppearanceSheet(
          selectedTheme: 'Paper',
          onThemeSelected: (val) => selectedTheme = val,
          fontSize: 18,
          onFontSizeChanged: (val) => changedSize = val,
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byKey(const Key('swatch_Paper')), findsOneWidget);
      expect(find.byKey(const Key('swatch_White')), findsOneWidget);
      expect(find.byKey(const Key('swatch_Sepia')), findsOneWidget);
      expect(find.byKey(const Key('swatch_Grey')), findsOneWidget);
      expect(find.byKey(const Key('swatch_Night')), findsOneWidget);
      expect(find.byKey(const Key('swatch_OLED')), findsOneWidget);

      await tester.tap(find.byKey(const Key('swatch_Sepia')));
      await tester.pumpAndSettle();
      expect(selectedTheme, equals('Sepia'));

      await tester.drag(find.byKey(const Key('appearance_font_slider')), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(changedSize, isNotNull);
    });

    testWidgets('renders typeface cards and responds to typeface selection', (tester) async {
      SettingsEntity? updatedSettings;

      await tester.pumpHarness(
        AppearanceSheet(
          settings: const SettingsEntity(),
          onChanged: (settings) => updatedSettings = settings,
        ),
      );

      expect(find.text('Typeface'), findsOneWidget);
      expect(find.text('Newsreader'), findsOneWidget);
      expect(find.text('Inter'), findsOneWidget);

      await tester.tap(find.text('Inter'));
      await tester.pumpAndSettle();
      expect(updatedSettings?.readerFont, equals(ReaderFont.sans));
    });

    testWidgets('reset button triggers onReset callback', (tester) async {
      var resetTapped = false;

      await tester.pumpHarness(
        AppearanceSheet(
          onReset: () => resetTapped = true,
        ),
      );

      expect(find.text('Reset'), findsOneWidget);
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(resetTapped, isTrue);
    });
  });
}
