import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:lingua_pages/presentation/theme/base/app_text_theme.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Milestone 1 Iteration 2: Empirical Dark Theme Stress Tests', () {
    test(
      'Requirement 1: AppTheme.dark instantiates cleanly in portrait & landscape without ScreenUtilInit',
      () {
        // Explicitly running in standalone isolate without ScreenUtilInit or any widget pump
        expect(
          () => AppTheme.dark(orientation: Orientation.portrait),
          returnsNormally,
          reason: 'AppTheme.dark(orientation: Orientation.portrait) must not throw',
        );
        expect(
          () => AppTheme.dark(orientation: Orientation.landscape),
          returnsNormally,
          reason: 'AppTheme.dark(orientation: Orientation.landscape) must not throw',
        );

        final darkPortrait = AppTheme.dark(orientation: Orientation.portrait);
        final darkLandscape = AppTheme.dark(orientation: Orientation.landscape);

        expect(darkPortrait, isNotNull);
        expect(darkLandscape, isNotNull);
        expect(darkPortrait.brightness, equals(Brightness.dark));
        expect(darkLandscape.brightness, equals(Brightness.dark));
      },
    );

    test(
      'Requirement 1 (Empirical Isolation): Instantiates in a separate fresh Dart Isolate without ScreenUtilInit',
      () async {
        final isolateReport = await Isolate.run(() {
          GoogleFonts.config.allowRuntimeFetching = false;

          final portrait = AppTheme.dark(orientation: Orientation.portrait);
          final landscape = AppTheme.dark(orientation: Orientation.landscape);

          return {
            'portraitBrightness': portrait.brightness.name,
            'landscapeBrightness': landscape.brightness.name,
            'portraitNavBgIsNull': portrait.navigationBarTheme.backgroundColor == null,
            'landscapeNavBgIsNull': landscape.navigationBarTheme.backgroundColor == null,
            'portraitHeadlineMediumFont': portrait.textTheme.headlineMedium?.fontFamily ?? '',
            'portraitBodyMediumFont': portrait.textTheme.bodyMedium?.fontFamily ?? '',
            'landscapeHeadlineMediumFont': landscape.textTheme.headlineMedium?.fontFamily ?? '',
            'landscapeBodyMediumFont': landscape.textTheme.bodyMedium?.fontFamily ?? '',
          };
        });

        expect(isolateReport['portraitBrightness'], equals('dark'));
        expect(isolateReport['landscapeBrightness'], equals('dark'));
        expect(isolateReport['portraitNavBgIsNull'], isTrue);
        expect(isolateReport['landscapeNavBgIsNull'], isTrue);
        expect(isolateReport['portraitHeadlineMediumFont'], contains('Newsreader'));
        expect(isolateReport['portraitHeadlineMediumFont'], isNot(contains('Figtree')));
        expect(isolateReport['portraitBodyMediumFont'], contains('Inter'));
        expect(isolateReport['portraitBodyMediumFont'], isNot(contains('Figtree')));
        expect(isolateReport['landscapeHeadlineMediumFont'], contains('Newsreader'));
        expect(isolateReport['landscapeHeadlineMediumFont'], isNot(contains('Figtree')));
        expect(isolateReport['landscapeBodyMediumFont'], contains('Inter'));
        expect(isolateReport['landscapeBodyMediumFont'], isNot(contains('Figtree')));
      },
    );

    test(
      'Requirement 2: NavigationBarThemeData.backgroundColor is strictly null (zero bottom nav theme)',
      () {
        final portrait = AppTheme.dark(orientation: Orientation.portrait);
        final landscape = AppTheme.dark(orientation: Orientation.landscape);

        // Portrait assertions
        expect(
          portrait.navigationBarTheme.backgroundColor,
          isNull,
          reason: 'portrait.navigationBarTheme.backgroundColor must be null',
        );

        // Landscape assertions
        expect(
          landscape.navigationBarTheme.backgroundColor,
          isNull,
          reason: 'landscape.navigationBarTheme.backgroundColor must be null',
        );
      },
    );

    test(
      'Requirement 3 & 4: Typography hierarchy Newsreader & Inter (zero Figtree)',
      () {
        final orientations = [Orientation.portrait, Orientation.landscape];

        for (final orientation in orientations) {
          final theme = AppTheme.dark(orientation: orientation);

          // Requirement 3: headlineMedium contains Newsreader and NOT Figtree
          final headlineMediumFont = theme.textTheme.headlineMedium?.fontFamily;
          expect(
            headlineMediumFont,
            isNotNull,
            reason: 'headlineMedium fontFamily must be defined for $orientation',
          );
          expect(
            headlineMediumFont,
            contains('Newsreader'),
            reason: 'headlineMedium must use Newsreader font family ($orientation)',
          );
          expect(
            headlineMediumFont,
            isNot(contains('Figtree')),
            reason: 'headlineMedium must NOT contain Figtree ($orientation)',
          );

          // Requirement 4: bodyMedium contains Inter and NOT Figtree
          final bodyMediumFont = theme.textTheme.bodyMedium?.fontFamily;
          expect(
            bodyMediumFont,
            isNotNull,
            reason: 'bodyMedium fontFamily must be defined for $orientation',
          );
          expect(
            bodyMediumFont,
            contains('Inter'),
            reason: 'bodyMedium must use Inter font family ($orientation)',
          );
          expect(
            bodyMediumFont,
            isNot(contains('Figtree')),
            reason: 'bodyMedium must NOT contain Figtree ($orientation)',
          );
        }
      },
    );

    test(
      'Exhaustive Typography Audit: All serif & sans styles in dark theme have zero Figtree references',
      () {
        final theme = AppTheme.dark();
        final textTheme = theme.textTheme;

        final serifStyles = {
          'displayLarge': textTheme.displayLarge,
          'displayMedium': textTheme.displayMedium,
          'displaySmall': textTheme.displaySmall,
          'headlineLarge': textTheme.headlineLarge,
          'headlineMedium': textTheme.headlineMedium,
          'headlineSmall': textTheme.headlineSmall,
          'titleLarge': textTheme.titleLarge,
          'bodyLarge': textTheme.bodyLarge,
        };

        for (final entry in serifStyles.entries) {
          expect(
            entry.value?.fontFamily,
            contains('Newsreader'),
            reason: '${entry.key} in dark theme textTheme must use Newsreader',
          );
          expect(
            entry.value?.fontFamily,
            isNot(contains('Figtree')),
            reason: '${entry.key} in dark theme textTheme must NOT contain Figtree',
          );
        }

        final sansStyles = {
          'titleMedium': textTheme.titleMedium,
          'titleSmall': textTheme.titleSmall,
          'bodyMedium': textTheme.bodyMedium,
          'bodySmall': textTheme.bodySmall,
          'labelLarge': textTheme.labelLarge,
          'labelMedium': textTheme.labelMedium,
          'labelSmall': textTheme.labelSmall,
        };

        for (final entry in sansStyles.entries) {
          expect(
            entry.value?.fontFamily,
            contains('Inter'),
            reason: '${entry.key} in dark theme textTheme must use Inter',
          );
          expect(
            entry.value?.fontFamily,
            isNot(contains('Figtree')),
            reason: '${entry.key} in dark theme textTheme must NOT contain Figtree',
          );
        }
      },
    );

    test(
      'Dark Warm Editorial Tokens & Extensions Integrity',
      () {
        final theme = AppTheme.dark();

        expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF111315)));
        expect(theme.canvasColor, equals(const Color(0xFF111315)));

        final colors = theme.extension<AppColors>();
        expect(colors, isNotNull);
        expect(colors?.background, equals(const Color(0xFF111315)));
        expect(colors?.surface, equals(const Color(0xFF1C1F22)));
        expect(colors?.hairline, equals(const Color(0xFF33383D)));
        expect(colors?.primaryInk, equals(const Color(0xFFFAF7F2)));
        expect(colors?.secondarySlate, equals(const Color(0xFFA8A59E)));
        expect(colors?.accentInkBlue, equals(const Color(0xFFA6C8FF)));
        expect(colors?.accentContainer, equals(const Color(0xFF2F4A7A)));
        expect(colors?.destructive, equals(const Color(0xFFFFB4AB)));

        final bands = theme.extension<BandColors>();
        expect(bands, isNotNull);
        expect(bands?.epub, equals(const Color(0xFFA6C8FF)));
        expect(bands?.onBand, equals(const Color(0xFF111315)));

        final appTextTheme = theme.extension<AppTextTheme>();
        expect(appTextTheme, isNotNull);
        expect(appTextTheme?.headlineMedium.fontFamily, contains('Newsreader'));
        expect(appTextTheme?.headlineMedium.fontFamily, isNot(contains('Figtree')));
        expect(appTextTheme?.bodyMedium.fontFamily, contains('Inter'));
        expect(appTextTheme?.bodyMedium.fontFamily, isNot(contains('Figtree')));
      },
    );

    test(
      'Shape & Radii Invariants in Dark Theme',
      () {
        final theme = AppTheme.dark();

        // Card radius 16.0 with dark hairline border
        final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
        expect(cardShape.borderRadius, equals(BorderRadius.circular(16.0)));
        expect(cardShape.side.color, equals(const Color(0xFF33383D)));
        expect(cardShape.side.width, equals(1.0));

        // BottomSheet radius 24.0
        final sheetShape = theme.bottomSheetTheme.shape as RoundedRectangleBorder;
        expect(
          sheetShape.borderRadius,
          equals(const BorderRadius.vertical(top: Radius.circular(24.0))),
        );

        // Chip & Buttons shape invariants
        expect(theme.chipTheme.shape, isA<StadiumBorder>());
        expect(theme.filledButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
        expect(theme.outlinedButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
        expect(theme.textButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
        expect(theme.floatingActionButtonTheme.shape, isA<StadiumBorder>());
      },
    );
  });
}
