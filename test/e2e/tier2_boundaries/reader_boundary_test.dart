import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/appearance_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app_harness.dart';
import '../tier1_features/reader_and_overlays_test.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAll(() {
    // Register fallback values if needed
  });

  group('Tier 2: Reader Presentation Layer Stress & Boundaries', () {
    testWidgets('Stress 1: Rapid toggle between Zen Mode and Visible Chrome', (tester) async {
      await tester.pumpHarness(
        const ReaderScreenContractWidget(
          title: 'The Shadow of the Wind',
          chapterTitle: 'Chapter Four: The Silent Harbour',
          pageText: 'The mist rose slowly over the cobblestones...',
          initialChromeVisible: true,
        ),
      );

      // Verify initial state: Chrome visible
      expect(find.byKey(const Key('brightness_rail_capsule')), findsOneWidget);

      final tapTarget = find.byKey(const Key('reader_viewport_tap_target'));

      // Perform 30 rapid taps without waiting for settle (interrupting animations)
      for (int i = 0; i < 30; i++) {
        await tester.tap(tapTarget);
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Settle animations
      await tester.pumpAndSettle();

      // State should be deterministic (30 toggles from true returns to true)
      expect(find.byKey(const Key('brightness_rail_capsule')), findsOneWidget);

      // Perform 1 more toggle -> Zen mode
      await tester.tap(tapTarget);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('brightness_rail_capsule')), findsNothing);
      expect(find.byKey(const Key('zen_mode_page_counter')), findsOneWidget);
      expect(find.byKey(const Key('reader_bookmark_ribbon')), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Stress 2: Rapid adjustments of font size, line spacing, margins, and brightness', (tester) async {
      final List<SettingsEntity> emittedSettings = [];

      await tester.pumpHarness(
        AppearanceSheet(
          settings: const SettingsEntity(),
          onChanged: (s) => emittedSettings.add(s),
        ),
      );

      final fontSlider = find.byKey(const Key('appearance_font_slider'));
      expect(fontSlider, findsOneWidget);

      // Rapidly drag font size slider left and right 15 times
      for (int i = 0; i < 15; i++) {
        final offset = i.isEven ? const Offset(30, 0) : const Offset(-30, 0);
        await tester.drag(fontSlider, offset);
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();
      expect(emittedSettings, isNotEmpty);

      // Find all visible Sliders in AppearanceSheet
      final sliders = find.byType(Slider);
      expect(sliders, findsAtLeastNWidgets(3));

      // Rapid drag across visible sliders in sequence
      for (final sliderFinder in [sliders.at(0), sliders.at(1), sliders.at(2)]) {
        for (int i = 0; i < 6; i++) {
          final offset = i.isEven ? const Offset(40, 0) : const Offset(-40, 0);
          await tester.drag(sliderFinder, offset);
          await tester.pump(const Duration(milliseconds: 10));
        }
      }
      await tester.pumpAndSettle();

      // Scroll to bottom display brightness controls
      final systemBrightnessSwitch = find.byKey(const Key('switch_follow_system_brightness'));
      await tester.scrollUntilVisible(
        systemBrightnessSwitch,
        50,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(systemBrightnessSwitch, findsOneWidget);

      for (int i = 0; i < 6; i++) {
        await tester.tap(systemBrightnessSwitch);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Edge 3: Extreme boundary values on sliders clamp safely without crash', (tester) async {
      SettingsEntity currentSettings = const SettingsEntity(
        fontSize: 12.0,
        lineSpacing: 1.1,
        margin: 12.0,
      );

      await tester.pumpHarness(
        StatefulBuilder(
          builder: (context, setState) {
            return AppearanceSheet(
              settings: currentSettings,
              onChanged: (s) => setState(() => currentSettings = s),
            );
          },
        ),
      );

      // Verify minimum values rendered
      expect(find.text('12 pt'), findsOneWidget);
      expect(find.text('1.1×'), findsOneWidget);
      expect(find.text('12 px'), findsOneWidget);

      // Drag font slider far to the left (beyond min 12)
      final fontSlider = find.byKey(const Key('appearance_font_slider'));
      await tester.dragFrom(tester.getTopLeft(fontSlider) + const Offset(24, 24), const Offset(-50, 0));
      await tester.pumpAndSettle();
      expect(currentSettings.fontSize, inInclusiveRange(12.0, 13.0));

      // Drag font slider far to the right (beyond max 28)
      await tester.drag(fontSlider, const Offset(150, 0));
      await tester.pumpAndSettle();
      expect(currentSettings.fontSize, inInclusiveRange(27.0, 28.0));
      expect(find.text('28 pt'), findsOneWidget);

      // Reset back to defaults
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(currentSettings.fontSize, equals(18.0));
      expect(currentSettings.lineSpacing, equals(1.5));
      expect(currentSettings.margin, equals(16.0));
    });

    testWidgets('Stress 4: Theme switching across all 6 swatches in rapid succession', (tester) async {
      final List<String> selectedThemes = [];
      final List<SettingsEntity> receivedSettings = [];

      await tester.pumpHarness(
        AppearanceSheet(
          selectedTheme: 'Paper',
          onThemeSelected: (name) => selectedThemes.add(name),
          settings: const SettingsEntity(),
          onChanged: (s) => receivedSettings.add(s),
        ),
      );

      final swatches = ['Paper', 'White', 'Sepia', 'Grey', 'Night', 'OLED'];

      // Rapidly cycle through all swatches 4 full cycles (24 taps)
      for (int cycle = 0; cycle < 4; cycle++) {
        for (final swatchName in swatches) {
          final swatchKey = Key('swatch_$swatchName');
          await tester.tap(find.byKey(swatchKey));
          await tester.pump(const Duration(milliseconds: 20));
        }
      }

      await tester.pumpAndSettle();

      expect(selectedThemes.length, equals(24));
      expect(receivedSettings.length, equals(24));
      // Final selected theme should be OLED
      expect(selectedThemes.last, equals('OLED'));
      expect(receivedSettings.last.readerTheme, equals(ReaderTheme.nightContrast));
    });

    testWidgets('Stress 5: Small viewport and large text scale factor do not produce RenderFlex overflows', (tester) async {
      await tester.pumpHarness(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568), // Small compact screen
            textScaler: TextScaler.linear(1.5), // 150% accessibility font scale
          ),
          child: const AppearanceSheet(
            settings: SettingsEntity(),
          ),
        ),
        viewport: const Size(320, 568),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byKey(const Key('swatch_Paper')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('appearance_font_slider')),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('appearance_font_slider')), findsOneWidget);

      // Scroll through sheet to find Display Brightness
      await tester.scrollUntilVisible(
        find.text('Display Brightness'),
        50,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Display Brightness'), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });
  });
}
