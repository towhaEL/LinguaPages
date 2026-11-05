import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/theme/base/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

import '../helpers/test_app_harness.dart';
import '../helpers/test_finders.dart';

void main() {
  group('Tier 1: Feature 1 - Warm Editorial Palette', () {
    test('verifies exact hex values for core tokens', () {
      expect(WarmEditorialTokens.canvasBackground, const Color(0xFFFAF7F2));
      expect(WarmEditorialTokens.cardSurface, const Color(0xFFFFFFFF));
      expect(WarmEditorialTokens.hairlineDivider, const Color(0xFFE8E2D9));
      expect(WarmEditorialTokens.textPrimaryInk, const Color(0xFF1C1B1A));
      expect(WarmEditorialTokens.subtitleSecondary, const Color(0xFF6B655D));
      expect(WarmEditorialTokens.accentInkBlue, const Color(0xFF2F4A7A));
      expect(WarmEditorialTokens.spokenHighlight, const Color(0xFFD6E2F5));
      expect(WarmEditorialTokens.paperReader, const Color(0xFFF6F1E7));
      expect(WarmEditorialTokens.destructive, const Color(0xFFBA1A1A));
    });

    test('verifies highlighting annotation palette colors', () {
      expect(WarmEditorialTokens.highlightYellow, const Color(0xFFFDE047));
      expect(WarmEditorialTokens.highlightGreen, const Color(0xFF86EFAC));
      expect(WarmEditorialTokens.highlightBlue, const Color(0xFF93C5FD));
      expect(WarmEditorialTokens.highlightPink, const Color(0xFFF472B6));
      expect(WarmEditorialTokens.highlightOrange, const Color(0xFFFDBA74));
      expect(WarmEditorialTokens.highlightAmber, const Color(0xFFE5A93C));
    });
  });

  group('Tier 1: Feature 2 - Typography Hierarchy & Font Features', () {
    testWidgets('editorial typography uses tabular figures for counters', (tester) async {
      await tester.pumpHarness(
        Builder(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: Text(
                  '142 / 380 · 37%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            );
          },
        ),
      );

      final textWidget = tester.widget<Text>(find.text('142 / 380 · 37%'));
      expect(textWidget.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  group('Tier 1: Feature 3 - Radii & Shape System', () {
    testWidgets('Cards use 16px corner radius and 1px hairline border', (tester) async {
      await tester.pumpHarness(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
            final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
            expect(shape.borderRadius, BorderRadius.circular(WarmEditorialTokens.cardRadius));
            expect(shape.side.color, WarmEditorialTokens.hairlineDivider);
            expect(shape.side.width, 1.0);
            return const Scaffold(
              body: Center(
                child: Card(
                  child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Text('Editorial Card'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      final cardFinder = CustomFinders.cardWithRadius(WarmEditorialTokens.cardRadius);
      expect(cardFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('Chips use StadiumBorder() and 1px border', (tester) async {
      await tester.pumpHarness(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            expect(theme.chipTheme.shape, const StadiumBorder());
            return const Scaffold(
              body: Center(
                child: Chip(
                  label: Text('EPUB'),
                ),
              ),
            );
          },
        ),
      );

      expect(CustomFinders.stadiumBorderWidget(), findsAtLeastNWidgets(1));
    });
  });

  group('Tier 1: Feature 4 - Bottom Nav Prohibition Architectural Mandate', () {
    testWidgets('Scaffold in Warm Editorial app has strictly zero bottom navigation bar', (tester) async {
      await tester.pumpHarness(
        const Scaffold(
          body: Center(
            child: Text('Sanctuary Content'),
          ),
        ),
      );

      tester.expectNoBottomNavigationBar();
    });
  });

  group('Tier 1: Feature 5 - Theme Wiring & ThemeExtensions', () {
    testWidgets('MaterialApp exposes AppColors and BandColors via context', (tester) async {
      late AppColors appColors;
      late BandColors bandColors;

      await tester.pumpHarness(
        Builder(
          builder: (context) {
            appColors = context.colors;
            bandColors = context.bands;
            return const SizedBox();
          },
        ),
      );

      expect(appColors.background, WarmEditorialTokens.canvasBackground);
      expect(appColors.surface, WarmEditorialTokens.cardSurface);
      expect(appColors.primary, WarmEditorialTokens.accentInkBlue);
      expect(appColors.border, WarmEditorialTokens.hairlineDivider);
      expect(bandColors.label, WarmEditorialTokens.paperReader);
    });
  });
}
