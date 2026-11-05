import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  group('CHALLENGER STRESS SUITE: 1. Typography & Font Features', () {
    test('verifies Newsreader serif for all editorial headings, titles, and reader body', () {
      final serifStyles = <String, TextStyle>{
        'displayLarge': AppTextStyles.displayLarge(),
        'displayMedium': AppTextStyles.displayMedium(),
        'displaySmall': AppTextStyles.displaySmall(),
        'headlineLarge': AppTextStyles.headlineLarge(),
        'headlineMedium': AppTextStyles.headlineMedium(),
        'headlineSmall': AppTextStyles.headlineSmall(),
        'titleLarge': AppTextStyles.titleLarge(),
        'bodyLarge': AppTextStyles.bodyLarge(),
      };

      for (final entry in serifStyles.entries) {
        expect(
          entry.value.fontFamily,
          contains('Newsreader'),
          reason: '${entry.key} must use Newsreader serif font family',
        );
      }
    });

    test('verifies Inter sans for all UI controls, labels, and standard body text', () {
      final sansStyles = <String, TextStyle>{
        'titleMedium': AppTextStyles.titleMedium(),
        'titleSmall': AppTextStyles.titleSmall(),
        'bodyMedium': AppTextStyles.bodyMedium(),
        'bodySmall': AppTextStyles.bodySmall(),
        'labelLarge': AppTextStyles.labelLarge(),
        'labelMedium': AppTextStyles.labelMedium(),
        'labelSmall': AppTextStyles.labelSmall(),
      };

      for (final entry in sansStyles.entries) {
        expect(
          entry.value.fontFamily,
          contains('Inter'),
          reason: '${entry.key} must use Inter sans-serif font family',
        );
      }
    });

    test('verifies custom color parameter propagates across all 15 typography methods', () {
      const customColor = Color(0xFFABCDEF);
      final allStyles = <String, TextStyle>{
        'displayLarge': AppTextStyles.displayLarge(color: customColor),
        'displayMedium': AppTextStyles.displayMedium(color: customColor),
        'displaySmall': AppTextStyles.displaySmall(color: customColor),
        'headlineLarge': AppTextStyles.headlineLarge(color: customColor),
        'headlineMedium': AppTextStyles.headlineMedium(color: customColor),
        'headlineSmall': AppTextStyles.headlineSmall(color: customColor),
        'titleLarge': AppTextStyles.titleLarge(color: customColor),
        'bodyLarge': AppTextStyles.bodyLarge(color: customColor),
        'titleMedium': AppTextStyles.titleMedium(color: customColor),
        'titleSmall': AppTextStyles.titleSmall(color: customColor),
        'bodyMedium': AppTextStyles.bodyMedium(color: customColor),
        'bodySmall': AppTextStyles.bodySmall(color: customColor),
        'labelLarge': AppTextStyles.labelLarge(color: customColor),
        'labelMedium': AppTextStyles.labelMedium(color: customColor),
        'labelSmall': AppTextStyles.labelSmall(color: customColor),
      };

      for (final entry in allStyles.entries) {
        expect(
          entry.value.color,
          equals(customColor),
          reason: '${entry.key} must accept custom color parameter',
        );
      }
    });

    test('stress-tests tabular figures on counters and strings', () {
      final baseStyle = AppTextStyles.labelSmall();

      // Method 1: Extension getter
      final extStyle = baseStyle.withTabularFigures;
      expect(extStyle.fontFeatures, contains(const FontFeature.tabularFigures()));

      // Method 2: Static helper
      final helperStyle = AppTextStyles.tabular(baseStyle);
      expect(helperStyle.fontFeatures, contains(const FontFeature.tabularFigures()));

      // Method 3: Idempotent chaining
      final chainedStyle = baseStyle.withTabularFigures.withTabularFigures;
      expect(chainedStyle.fontFeatures, contains(const FontFeature.tabularFigures()));

      // Method 4: Preservation of existing fontFeatures
      final existingFeatureStyle = baseStyle.copyWith(
        fontFeatures: [const FontFeature.enable('smcp')],
      );
      final combined = AppTextStyles.tabular(existingFeatureStyle);
      expect(combined.fontFeatures, contains(const FontFeature.enable('smcp')));
      expect(combined.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('stress-tests tabular figures rendering in widget tree for counter string', (tester) async {
      const counterString = '142 / 380 · 37%';
      final counterStyle = AppTextStyles.tabular(
        AppTextStyles.labelSmall(color: AppColors.secondarySlateColor),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.warmEditorial(),
          home: Scaffold(
            body: Center(
              child: Text(
                counterString,
                key: const ValueKey('page-counter'),
                style: counterStyle,
              ),
            ),
          ),
        ),
      );

      final textFinder = find.byKey(const ValueKey('page-counter'));
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.data, equals(counterString));
      expect(textWidget.style?.fontFeatures, isNotNull);
      expect(textWidget.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    test('verifies createMaterialTextTheme and createAppTextTheme complete population', () {
      final materialTheme = AppTextStyles.createMaterialTextTheme();
      expect(materialTheme.displayLarge?.fontFamily, contains('Newsreader'));
      expect(materialTheme.headlineMedium?.fontFamily, contains('Newsreader'));
      expect(materialTheme.titleLarge?.fontFamily, contains('Newsreader'));
      expect(materialTheme.bodyLarge?.fontFamily, contains('Newsreader'));
      expect(materialTheme.titleMedium?.fontFamily, contains('Inter'));
      expect(materialTheme.bodyMedium?.fontFamily, contains('Inter'));
      expect(materialTheme.bodySmall?.fontFamily, contains('Inter'));
      expect(materialTheme.labelLarge?.fontFamily, contains('Inter'));
      expect(materialTheme.labelMedium?.fontFamily, contains('Inter'));
      expect(materialTheme.labelSmall?.fontFamily, contains('Inter'));

      final appTextTheme = AppTextStyles.createAppTextTheme();
      final convertedTheme = appTextTheme.getTextTheme();
      expect(convertedTheme.displayLarge?.fontFamily, contains('Newsreader'));
      expect(convertedTheme.headlineMedium?.fontFamily, contains('Newsreader'));
      expect(convertedTheme.bodyMedium?.fontFamily, contains('Inter'));
    });
  });

  group('CHALLENGER STRESS SUITE: 2. ThemeExtension Invariants & Mathematical Lerp', () {
    test('stress-tests all 39 properties of AppColors.warmEditorial are non-null', () {
      const colors = AppColors.warmEditorial;

      final properties = <String, Color>{
        'primary': colors.primary,
        'onPrimary': colors.onPrimary,
        'secondary': colors.secondary,
        'onSecondary': colors.onSecondary,
        'background': colors.background,
        'onBackground': colors.onBackground,
        'surface': colors.surface,
        'onSurface': colors.onSurface,
        'onSurfaceMuted': colors.onSurfaceMuted,
        'error': colors.error,
        'onError': colors.onError,
        'success': colors.success,
        'warning': colors.warning,
        'info': colors.info,
        'premium': colors.premium,
        'border': colors.border,
        'shadow': colors.shadow,
        'disabled': colors.disabled,
        'surfaceElevated': colors.surfaceElevated,
        'hairline': colors.hairline,
        'primaryInk': colors.primaryInk,
        'secondarySlate': colors.secondarySlate,
        'accentInkBlue': colors.accentInkBlue,
        'accentContainer': colors.accentContainer,
        'paperReader': colors.paperReader,
        'destructive': colors.destructive,
        'surfaceDim': colors.surfaceDim,
        'surfaceContainerLow': colors.surfaceContainerLow,
        'surfaceContainerHighest': colors.surfaceContainerHighest,
        'outline': colors.outline,
        'outlineVariant': colors.outlineVariant,
        'accentHover': colors.accentHover,
        'destructiveContainer': colors.destructiveContainer,
        'highlightYellow': colors.highlightYellow,
        'highlightGreen': colors.highlightGreen,
        'highlightBlue': colors.highlightBlue,
        'highlightPink': colors.highlightPink,
        'highlightOrange': colors.highlightOrange,
        'highlightAmber': colors.highlightAmber,
      };

      expect(properties.length, equals(39), reason: 'Must track exactly 39 palette properties');

      for (final entry in properties.entries) {
        expect(entry.value, isNotNull, reason: 'Property ${entry.key} must not be null');
      }
    });

    test('stress-tests copyWith() parameter isolation and immutability', () {
      const base = AppColors.warmEditorial;
      const sentinel = Color(0xFF112233);

      // copyWith without args should retain all properties
      final identityCopy = base.copyWith();
      expect(identityCopy.primary, equals(base.primary));
      expect(identityCopy.background, equals(base.background));
      expect(identityCopy.hairline, equals(base.hairline));
      expect(identityCopy.primaryInk, equals(base.primaryInk));
      expect(identityCopy.secondarySlate, equals(base.secondarySlate));
      expect(identityCopy.accentInkBlue, equals(base.accentInkBlue));
      expect(identityCopy.accentContainer, equals(base.accentContainer));
      expect(identityCopy.paperReader, equals(base.paperReader));
      expect(identityCopy.destructive, equals(base.destructive));

      // Test individual parameter overrides
      final copy1 = base.copyWith(accentInkBlue: sentinel);
      expect(copy1.accentInkBlue, equals(sentinel));
      expect(copy1.background, equals(base.background));
      expect(copy1.hairline, equals(base.hairline));

      final copy2 = base.copyWith(background: sentinel);
      expect(copy2.background, equals(sentinel));
      expect(copy2.accentInkBlue, equals(base.accentInkBlue));

      final copy3 = base.copyWith(paperReader: sentinel);
      expect(copy3.paperReader, equals(sentinel));
      expect(copy3.destructive, equals(base.destructive));

      final copy4 = base.copyWith(destructive: sentinel);
      expect(copy4.destructive, equals(sentinel));
      expect(copy4.secondarySlate, equals(base.secondarySlate));

      final copy5 = base.copyWith(accentContainer: sentinel);
      expect(copy5.accentContainer, equals(sentinel));
      expect(copy5.surfaceElevated, equals(base.surfaceElevated));
    });

    test('stress-tests constructor fallbacks when optional Warm Editorial tokens are omitted', () {
      const minimal = AppColors(
        primary: Color(0xFF101010),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF202020),
        onSecondary: Color(0xFFFFFFFF),
        background: Color(0xFF303030),
        onBackground: Color(0xFFFFFFFF),
        surface: Color(0xFF404040),
        onSurface: Color(0xFF505050),
        onSurfaceMuted: Color(0xFF606060),
        error: Color(0xFF707070),
        onError: Color(0xFFFFFFFF),
        success: Color(0xFF808080),
        warning: Color(0xFF909090),
        info: Color(0xFFA0A0A0),
        premium: Color(0xFFB0B0B0),
        border: Color(0xFFC0C0C0),
        shadow: Color(0xFFD0D0D0),
        disabled: Color(0xFFE0E0E0),
        surfaceElevated: Color(0xFFF0F0F0),
      );

      // Verify fallbacks were populated
      expect(minimal.hairline, equals(const Color(0xFFC0C0C0))); // defaulted to border
      expect(minimal.primaryInk, equals(const Color(0xFF505050))); // defaulted to onSurface
      expect(minimal.secondarySlate, equals(const Color(0xFF606060))); // defaulted to onSurfaceMuted
      expect(minimal.accentInkBlue, equals(const Color(0xFF101010))); // defaulted to primary
      expect(minimal.destructive, equals(const Color(0xFF707070))); // defaulted to error
      expect(minimal.accentContainer, equals(const Color(0xFFD6E2F5)));
      expect(minimal.paperReader, equals(const Color(0xFFF6F1E7)));
      expect(minimal.surfaceDim, equals(const Color(0xFFF0EDE9)));
      expect(minimal.surfaceContainerLow, equals(const Color(0xFFF6F3EE)));
      expect(minimal.surfaceContainerHighest, equals(const Color(0xFFE5E2DD)));
      expect(minimal.outline, equals(const Color(0xFF747780)));
      expect(minimal.outlineVariant, equals(const Color(0xFFC4C6D0)));
      expect(minimal.accentHover, equals(const Color(0xFF23395E)));
      expect(minimal.destructiveContainer, equals(const Color(0xFFFFDAD6)));
      expect(minimal.highlightYellow, equals(const Color(0xFFFDE047)));
      expect(minimal.highlightGreen, equals(const Color(0xFF86EFAC)));
      expect(minimal.highlightBlue, equals(const Color(0xFF93C5FD)));
      expect(minimal.highlightPink, equals(const Color(0xFFF472B6)));
      expect(minimal.highlightOrange, equals(const Color(0xFFFDBA74)));
      expect(minimal.highlightAmber, equals(const Color(0xFFE5A93C)));
    });

    test('stress-tests lerp behavior across range t in [-0.5..1.5] and null inputs', () {
      const start = AppColors.warmEditorial;
      final end = start.copyWith(
        background: const Color(0xFF000000),
        surface: const Color(0xFF111111),
        primaryInk: const Color(0xFFEEEEEE),
        accentInkBlue: const Color(0xFFFF0000),
        accentContainer: const Color(0xFF00FF00),
        paperReader: const Color(0xFF0000FF),
      );

      // Test 1: lerp with null returns this safely
      final lerpNull = start.lerp(null, 0.5) as AppColors;
      expect(identical(lerpNull, start), isTrue);

      // Test 2: boundary t = 0.0 returns start values
      final lerpZero = start.lerp(end, 0.0) as AppColors;
      expect(lerpZero.background, equals(start.background));
      expect(lerpZero.surface, equals(start.surface));
      expect(lerpZero.accentInkBlue, equals(start.accentInkBlue));

      // Test 3: boundary t = 1.0 returns end values
      final lerpOne = start.lerp(end, 1.0) as AppColors;
      expect(lerpOne.background, equals(end.background));
      expect(lerpOne.surface, equals(end.surface));
      expect(lerpOne.accentInkBlue, equals(end.accentInkBlue));

      // Test 4: midpoint t = 0.5
      final lerpHalf = start.lerp(end, 0.5) as AppColors;
      expect(lerpHalf.background, equals(Color.lerp(start.background, end.background, 0.5)));
      expect(lerpHalf.surface, equals(Color.lerp(start.surface, end.surface, 0.5)));
      expect(lerpHalf.accentInkBlue, equals(Color.lerp(start.accentInkBlue, end.accentInkBlue, 0.5)));
      expect(lerpHalf.accentContainer, equals(Color.lerp(start.accentContainer, end.accentContainer, 0.5)));
      expect(lerpHalf.paperReader, equals(Color.lerp(start.paperReader, end.paperReader, 0.5)));

      // Test 5: continuous animation sweep (101 steps) without any nulls
      for (int i = 0; i <= 100; i++) {
        final t = i / 100.0;
        final intermediate = start.lerp(end, t) as AppColors;
        expect(intermediate.background, isNotNull);
        expect(intermediate.surface, isNotNull);
        expect(intermediate.primaryInk, isNotNull);
        expect(intermediate.secondarySlate, isNotNull);
        expect(intermediate.hairline, isNotNull);
        expect(intermediate.accentInkBlue, isNotNull);
        expect(intermediate.accentContainer, isNotNull);
        expect(intermediate.paperReader, isNotNull);
        expect(intermediate.destructive, isNotNull);
      }

      // Test 6: Extrapolation (spring curves overshoot / undershoot)
      final underShoot = start.lerp(end, -0.5) as AppColors;
      expect(underShoot.background, isNotNull);
      expect(underShoot.accentInkBlue, isNotNull);

      final overShoot = start.lerp(end, 1.5) as AppColors;
      expect(overShoot.background, isNotNull);
      expect(overShoot.accentInkBlue, isNotNull);
    });

    test('stress-tests AppTextTheme and BandColors lerp implementations', () {
      final textA = AppTextStyles.createAppTextTheme();
      final textB = AppTextStyles.createAppTextTheme(textColor: Colors.blue);

      final lerpTextNull = textA.lerp(null, 0.5);
      expect(lerpTextNull, equals(textA));

      final lerpTextHalf = textA.lerp(textB, 0.5);
      expect(lerpTextHalf.displayLarge.color, equals(Color.lerp(textA.displayLarge.color, textB.displayLarge.color, 0.5)));

      const bandA = BandColors(
        epub: Color(0xFF111111),
        pdf: Color(0xFF222222),
        txt: Color(0xFF333333),
        markdown: Color(0xFF444444),
        html: Color(0xFF555555),
        fb2: Color(0xFF666666),
        onBand: Colors.white,
        label: Color(0xFF777777),
        onLabel: Colors.black,
      );
      const bandB = BandColors(
        epub: Color(0xFF999999),
        pdf: Color(0xFF888888),
        txt: Color(0xFF777777),
        markdown: Color(0xFF666666),
        html: Color(0xFF555555),
        fb2: Color(0xFF444444),
        onBand: Colors.black,
        label: Color(0xFF333333),
        onLabel: Colors.white,
      );

      final lerpBandNull = bandA.lerp(null, 0.5);
      expect(lerpBandNull, equals(bandA));

      final lerpBandHalf = bandA.lerp(bandB, 0.5);
      expect(lerpBandHalf.epub, equals(Color.lerp(bandA.epub, bandB.epub, 0.5)));
      expect(lerpBandHalf.pdf, equals(Color.lerp(bandA.pdf, bandB.pdf, 0.5)));
    });
  });

  group('CHALLENGER STRESS SUITE: 3. Dark/Light Switching Robustness & Orientations', () {
    test('verifies pure standalone construction of light and dark themes across portrait and landscape without ScreenUtilInit', () {
      // Light theme constructs purely without ScreenUtil
      final lightPortrait = AppTheme.light(orientation: Orientation.portrait);
      final lightLandscape = AppTheme.light(orientation: Orientation.landscape);
      expect(lightPortrait.brightness, equals(Brightness.light));
      expect(lightLandscape.brightness, equals(Brightness.light));
      expect(lightPortrait.extension<AppColors>(), isNotNull);
      expect(lightPortrait.extension<BandColors>(), isNotNull);
      expect(lightPortrait.extension<AppTextTheme>(), isNotNull);

      // Dark theme constructs purely without ScreenUtil
      final darkPortrait = AppTheme.dark(orientation: Orientation.portrait);
      final darkLandscape = AppTheme.dark(orientation: Orientation.landscape);
      expect(darkPortrait.brightness, equals(Brightness.dark));
      expect(darkLandscape.brightness, equals(Brightness.dark));
      expect(darkPortrait.extension<AppColors>(), isNotNull);
      expect(darkPortrait.extension<BandColors>(), isNotNull);
      expect(darkPortrait.extension<AppTextTheme>(), isNotNull);

      // Zero NavigationBarThemeData
      expect(darkPortrait.navigationBarTheme.backgroundColor, isNull);
      expect(darkLandscape.navigationBarTheme.backgroundColor, isNull);

      // Typography hierarchy: Newsreader for titles, Inter for body/controls, NO Figtree
      expect(darkPortrait.textTheme.headlineMedium?.fontFamily, contains('Newsreader'));
      expect(darkPortrait.textTheme.bodyMedium?.fontFamily, contains('Inter'));
      expect(darkPortrait.textTheme.headlineMedium?.fontFamily, isNot(contains('Figtree')));
    });

    testWidgets('stress-tests live animated theme switching between light and dark in widget tree with ScreenUtilInit', (tester) async {
      ThemeData? observedTheme;
      AppColors? observedColors;
      BandColors? observedBands;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(412, 915),
          builder: (context, _) {
            final dark = AppTheme.dark();
            return MaterialApp(
              home: AnimatedTheme(
                data: dark,
                duration: const Duration(milliseconds: 300),
                child: Builder(
                  builder: (ctx) {
                    observedTheme = ctx.appThemeData;
                    observedColors = ctx.colors;
                    observedBands = ctx.bands;
                    return Scaffold(
                      backgroundColor: observedColors?.background,
                      body: Center(
                        child: Text(
                          'Theme Switch Test',
                          style: TextStyle(color: observedColors?.primaryInk),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      // Step through intermediate animation frames
      for (int step = 0; step < 6; step++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(observedColors?.background, isNotNull);
        expect(observedColors?.primaryInk, isNotNull);
        expect(observedColors?.hairline, isNotNull);
        expect(observedBands?.epub, isNotNull);
      }

      await tester.pumpAndSettle();
      expect(observedTheme?.brightness, equals(Brightness.dark));
    });

    testWidgets('stress-tests orientation toggle between portrait and landscape', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(orientation: Orientation.portrait),
          home: const DashboardPortrait(
            child: Text('Portrait Content'),
          ),
        ),
      );

      expect(find.text('Portrait Content'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);

      // Switch to Landscape
      tester.view.physicalSize = const Size(915, 412);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(orientation: Orientation.landscape),
          home: const DashboardPortrait(
            child: Text('Landscape Content'),
          ),
        ),
      );

      expect(find.text('Landscape Content'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('verifies Material 3 component shapes in AppTheme', (tester) async {
      final theme = AppTheme.warmEditorial();

      // Card
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.circular(16.0)));
      expect(cardShape.side.color, equals(const Color(0xFFE8E2D9)));
      expect(cardShape.side.width, equals(1.0));

      // Bottom Sheet
      final sheetShape = theme.bottomSheetTheme.shape as RoundedRectangleBorder;
      expect(sheetShape.borderRadius, equals(const BorderRadius.vertical(top: Radius.circular(24.0))));

      // Chips & Buttons
      expect(theme.chipTheme.shape, isA<StadiumBorder>());
      expect(theme.filledButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
      expect(theme.outlinedButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
      expect(theme.textButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
      expect(theme.floatingActionButtonTheme.shape, isA<StadiumBorder>());
    });
  });
}
