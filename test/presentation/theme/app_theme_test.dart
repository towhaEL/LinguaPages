import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/screen/dashboard/dashboard_portrait.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/app_text_styles.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:lingua_pages/presentation/theme/base/app_text_theme.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Warm Editorial Color Tokens (R1)', () {
    test('verifies exact hex values for all core design palette tokens', () {
      expect(AppColors.canvasColor, const Color(0xFFFAF7F2));
      expect(AppColors.canvasBackground, const Color(0xFFFAF7F2));
      expect(AppColors.cardSurface, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceDimColor, const Color(0xFFF0EDE9));
      expect(AppColors.surfaceContainerLowColor, const Color(0xFFF6F3EE));
      expect(AppColors.surfaceContainerHighestColor, const Color(0xFFE5E2DD));
      expect(AppColors.hairlineColor, const Color(0xFFE8E2D9));
      expect(AppColors.hairlineDivider, const Color(0xFFE8E2D9));
      expect(AppColors.paperReaderColor, const Color(0xFFF6F1E7));
      expect(AppColors.primaryInkColor, const Color(0xFF1C1B1A));
      expect(AppColors.textPrimaryInk, const Color(0xFF1C1B1A));
      expect(AppColors.secondarySlateColor, const Color(0xFF6B655D));
      expect(AppColors.subtitleSecondary, const Color(0xFF6B655D));
      expect(AppColors.accentInkBlueColor, const Color(0xFF2F4A7A));
      expect(AppColors.accentHoverColor, const Color(0xFF23395E));
      expect(AppColors.accentContainerColor, const Color(0xFFD6E2F5));
      expect(AppColors.spokenHighlight, const Color(0xFFD6E2F5));
      expect(AppColors.destructiveColor, const Color(0xFFBA1A1A));
      expect(AppColors.destructiveContainerColor, const Color(0xFFFFDAD6));
    });

    test('verifies highlighting annotations palette tokens', () {
      expect(AppColors.highlightYellowColor, const Color(0xFFFDE047));
      expect(AppColors.highlightGreenColor, const Color(0xFF86EFAC));
      expect(AppColors.highlightBlueColor, const Color(0xFF93C5FD));
      expect(AppColors.highlightPinkColor, const Color(0xFFF472B6));
      expect(AppColors.highlightOrangeColor, const Color(0xFFFDBA74));
      expect(AppColors.highlightAmberColor, const Color(0xFFE5A93C));
    });

    test('verifies AppColors.warmEditorial instance wiring and fallbacks', () {
      const colors = AppColors.warmEditorial;
      expect(colors.background, const Color(0xFFFAF7F2));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.hairline, const Color(0xFFE8E2D9));
      expect(colors.primaryInk, const Color(0xFF1C1B1A));
      expect(colors.secondarySlate, const Color(0xFF6B655D));
      expect(colors.accentInkBlue, const Color(0xFF2F4A7A));
      expect(colors.accentContainer, const Color(0xFFD6E2F5));
      expect(colors.paperReader, const Color(0xFFF6F1E7));
      expect(colors.destructive, const Color(0xFFBA1A1A));
      expect(colors.surfaceDim, const Color(0xFFF0EDE9));
      expect(colors.surfaceContainerLow, const Color(0xFFF6F3EE));
      expect(colors.surfaceContainerHighest, const Color(0xFFE5E2DD));
      expect(colors.accentHover, const Color(0xFF23395E));
      expect(colors.destructiveContainer, const Color(0xFFFFDAD6));
    });

    test('verifies copyWith and lerp methods preserve all tokens', () {
      const colors = AppColors.warmEditorial;
      final copied = colors.copyWith(
        accentInkBlue: const Color(0xFF112233),
      );
      expect(copied.accentInkBlue, const Color(0xFF112233));
      expect(copied.background, colors.background);

      final lerped = colors.lerp(copied, 0.5) as AppColors;
      expect(lerped.background, colors.background);
    });
  });

  group('Typography Hierarchy & Tabular Figures (R1)', () {
    test('verifies Newsreader for headings/titles and Inter for controls/labels', () {
      final display = AppTextStyles.displayLarge();
      expect(display.fontFamily, contains('Newsreader'));

      final headline = AppTextStyles.headlineMedium();
      expect(headline.fontFamily, contains('Newsreader'));

      final title = AppTextStyles.titleMedium();
      expect(title.fontFamily, contains('Inter'));

      final label = AppTextStyles.labelLarge();
      expect(label.fontFamily, contains('Inter'));

      final body = AppTextStyles.bodyMedium();
      expect(body.fontFamily, contains('Inter'));
    });

    test('verifies tabular figures feature for numbers/counters', () {
      final style = AppTextStyles.labelMedium().withTabularFigures;
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));

      final tabularHelper = AppTextStyles.tabular(AppTextStyles.bodySmall());
      expect(tabularHelper.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  group('Shape & Radii System (R1)', () {
    test('verifies card, bottom sheet, and chip theme shapes in AppTheme', () {
      final theme = AppTheme.warmEditorial();

      // Card radius 16.0px and hairline border
      expect(AppTheme.cardRadius, 16.0);
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(16.0));
      expect(cardShape.side.color, const Color(0xFFE8E2D9));
      expect(cardShape.side.width, 1.0);

      // Bottom Sheet radius 24.0px
      expect(AppTheme.bottomSheetRadius, 24.0);
      final sheetShape = theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(
        sheetShape.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(24.0)),
      );

      // Chip & CTA button stadium shape with 1px border
      expect(theme.chipTheme.shape, const StadiumBorder());
      expect(theme.chipTheme.side?.color, const Color(0xFFE8E2D9));
      expect(theme.chipTheme.side?.width, 1.0);
    });
  });

  group('Architectural Mandate: Zero Bottom Navigation Bar (R1)', () {
    testWidgets('DashboardPortrait contains NO NavigationBar or BottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.warmEditorial(),
          home: const DashboardPortrait(
            child: Text('Dashboard Content'),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('Dashboard Content'), findsOneWidget);
    });
  });

  group('Theme Integration & Extensions (R1)', () {
    testWidgets('MaterialApp exposes AppColors, BandColors, and AppTextTheme via context', (tester) async {
      late AppColors colors;
      late BandColors bands;
      late AppTextTheme textStyle;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.warmEditorial(),
          home: Builder(
            builder: (context) {
              colors = context.colors;
              bands = context.bands;
              textStyle = context.textStyle;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.background, const Color(0xFFFAF7F2));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.hairline, const Color(0xFFE8E2D9));
      expect(colors.primaryInk, const Color(0xFF1C1B1A));
      expect(colors.secondarySlate, const Color(0xFF6B655D));
      expect(colors.accentInkBlue, const Color(0xFF2F4A7A));
      expect(colors.accentContainer, const Color(0xFFD6E2F5));
      expect(colors.paperReader, const Color(0xFFF6F1E7));
      expect(colors.destructive, const Color(0xFFBA1A1A));

      expect(bands.label, const Color(0xFFF6F1E7));
      expect(bands.onLabel, const Color(0xFF1C1B1A));

      expect(textStyle.headlineMedium.fontFamily, contains('Newsreader'));
      expect(textStyle.bodyMedium.fontFamily, contains('Inter'));
    });
  });

  group('Dark Warm Editorial Theme & Tokens (M1-I2)', () {
    test('verifies AppColors.darkWarmEditorial token values and invariants', () {
      const colors = AppColors.darkWarmEditorial;
      expect(colors.background, const Color(0xFF111315));
      expect(colors.surface, const Color(0xFF1C1F22));
      expect(colors.surfaceElevated, const Color(0xFF26292D));
      expect(colors.hairline, const Color(0xFF33383D));
      expect(colors.primaryInk, const Color(0xFFFAF7F2));
      expect(colors.secondarySlate, const Color(0xFFA8A59E));
      expect(colors.accentInkBlue, const Color(0xFFA6C8FF));
      expect(colors.accentContainer, const Color(0xFF2F4A7A));
      expect(colors.destructive, const Color(0xFFFFB4AB));
      expect(colors.outline, const Color(0xFF6B7076));
      expect(colors.outlineVariant, const Color(0xFF33383D));
    });

    test('verifies pure standalone construction of AppTheme.dark() without ScreenUtilInit', () {
      final darkPortrait = AppTheme.dark(orientation: Orientation.portrait);
      final darkLandscape = AppTheme.dark(orientation: Orientation.landscape);

      expect(darkPortrait.brightness, Brightness.dark);
      expect(darkLandscape.brightness, Brightness.dark);
      expect(darkPortrait.scaffoldBackgroundColor, const Color(0xFF111315));
      expect(darkLandscape.scaffoldBackgroundColor, const Color(0xFF111315));

      // Extensions
      final colors = darkPortrait.extension<AppColors>();
      final bands = darkPortrait.extension<BandColors>();
      final textTheme = darkPortrait.extension<AppTextTheme>();

      expect(colors, isNotNull);
      expect(bands, isNotNull);
      expect(textTheme, isNotNull);
      expect(colors?.background, const Color(0xFF111315));
      expect(colors?.surface, const Color(0xFF1C1F22));

      // Zero NavigationBarThemeData
      expect(darkPortrait.navigationBarTheme.backgroundColor, isNull);
      expect(darkLandscape.navigationBarTheme.backgroundColor, isNull);

      // Radii invariants
      final cardShape = darkPortrait.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(16.0));
      expect(cardShape.side.color, const Color(0xFF33383D));

      final sheetShape = darkPortrait.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(
        sheetShape.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(24.0)),
      );

      expect(darkPortrait.chipTheme.shape, const StadiumBorder());

      // Typography hierarchy
      expect(darkPortrait.textTheme.headlineMedium?.fontFamily, contains('Newsreader'));
      expect(darkPortrait.textTheme.bodyMedium?.fontFamily, contains('Inter'));
      expect(darkPortrait.textTheme.displayLarge?.fontFamily, contains('Newsreader'));
      expect(darkPortrait.textTheme.labelLarge?.fontFamily, contains('Inter'));
    });

    testWidgets('MaterialApp with AppTheme.dark exposes dark tokens and styles', (tester) async {
      late AppColors colors;
      late BandColors bands;
      late AppTextTheme textStyle;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              colors = context.colors;
              bands = context.bands;
              textStyle = context.textStyle;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.background, const Color(0xFF111315));
      expect(colors.surface, const Color(0xFF1C1F22));
      expect(colors.hairline, const Color(0xFF33383D));
      expect(colors.primaryInk, const Color(0xFFFAF7F2));
      expect(colors.secondarySlate, const Color(0xFFA8A59E));
      expect(colors.accentInkBlue, const Color(0xFFA6C8FF));

      expect(bands.epub, isNotNull);
      expect(bands.onBand, const Color(0xFF111315));

      expect(textStyle.headlineMedium.fontFamily, contains('Newsreader'));
      expect(textStyle.bodyMedium.fontFamily, contains('Inter'));
    });
  });
}
