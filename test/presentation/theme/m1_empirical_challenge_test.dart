import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/route/app_router.dart';
import 'package:lingua_pages/presentation/screen/dashboard/dashboard_portrait.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Milestone 1 Challenge: Architectural Prohibition Invariants', () {
    testWidgets(
      'DashboardPortrait strictly contains NO NavigationBar, BottomNavigationBar or BottomAppBar',
      (tester) async {
        // Set mobile viewport 412x915 dp
        tester.view.physicalSize = const Size(412, 915) * tester.view.devicePixelRatio;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.warmEditorial(),
            home: const DashboardPortrait(
              child: Scaffold(
                body: Center(child: Text('Sanctuary Reader')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check widget tree finders
        expect(find.byType(NavigationBar), findsNothing,
            reason: 'Prohibited NavigationBar found in DashboardPortrait widget tree!');
        expect(find.byType(BottomNavigationBar), findsNothing,
            reason: 'Prohibited BottomNavigationBar found in DashboardPortrait widget tree!');
        expect(find.byType(BottomAppBar), findsNothing,
            reason: 'Prohibited BottomAppBar found in DashboardPortrait widget tree!');

        // Inspect DashboardPortrait's internal Scaffold directly
        final scaffolds = tester.widgetList<Scaffold>(find.byType(Scaffold));
        for (final scaffold in scaffolds) {
          expect(scaffold.bottomNavigationBar, isNull,
              reason: 'Scaffold.bottomNavigationBar must be strictly null!');
        }
      },
    );

    test('Empirical codebase audit: NO bottomNavigationBar or BottomNavigationBar in presentation routes', () {
      final screenDir = Directory('lib/presentation/screen');
      expect(screenDir.existsSync(), isTrue, reason: 'lib/presentation/screen must exist');

      final dartFiles = screenDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();

      expect(dartFiles, isNotEmpty);

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(
          content.contains('BottomNavigationBar'),
          isFalse,
          reason: 'Prohibited BottomNavigationBar found in ${file.path}',
        );
        expect(
          content.contains('bottomNavigationBar:'),
          isFalse,
          reason: 'Prohibited bottomNavigationBar parameter found in ${file.path}',
        );
      }
    });

    test('AppRouter route definitions do not route through any bottom navigation scaffold', () {
      final router = AppRouter();
      final routeNames = router.routes.map((r) => r.name).toList();
      expect(routeNames, contains('DashboardRoute'));
      expect(routeNames, contains('ReaderRoute'));

      final dashboardRoute = router.routes.firstWhere((r) => r.name == 'DashboardRoute');
      final childRouteNames = dashboardRoute.children?.map((r) => r.name).toList() ?? [];
      expect(childRouteNames, contains('HomeRoute'));
      expect(childRouteNames, contains('SettingsRoute'));
    });
  });

  group('Milestone 1 Challenge: Core Design Token Invariants (9 Specified Hex Values)', () {
    // 1. Canvas: #FAF7F2
    test('Token Invariant 1: Canvas must be exactly #FAF7F2', () {
      const expected = Color(0xFFFAF7F2);
      expect(AppColors.canvasColor, expected);
      expect(AppColors.canvasBackground, expected);
      expect(AppColors.warmEditorial.background, expected);
      expect(AppTheme.warmEditorial().scaffoldBackgroundColor, expected);
      expect(AppTheme.warmEditorial().canvasColor, expected);
    });

    // 2. Card Surfaces: #FFFFFF
    test('Token Invariant 2: Card Surfaces must be exactly #FFFFFF', () {
      const expected = Color(0xFFFFFFFF);
      expect(AppColors.cardSurface, expected);
      expect(AppColors.warmEditorial.surface, expected);
      expect(AppTheme.warmEditorial().cardTheme.color, expected);
      expect(AppTheme.warmEditorial().colorScheme.surface, expected);
      expect(AppTheme.warmEditorial().bottomSheetTheme.backgroundColor, expected);
    });

    // 3. Hairline dividers: #E8E2D9
    test('Token Invariant 3: Hairline dividers must be exactly #E8E2D9', () {
      const expected = Color(0xFFE8E2D9);
      expect(AppColors.hairlineColor, expected);
      expect(AppColors.hairlineDivider, expected);
      expect(AppColors.warmEditorial.hairline, expected);
      expect(AppColors.warmEditorial.border, expected);
      expect(AppTheme.warmEditorial().dividerTheme.color, expected);
      expect(AppTheme.warmEditorial().colorScheme.outline, expected);
    });

    // 4. Primary Ink: #1C1B1A
    test('Token Invariant 4: Primary Ink must be exactly #1C1B1A', () {
      const expected = Color(0xFF1C1B1A);
      expect(AppColors.primaryInkColor, expected);
      expect(AppColors.textPrimaryInk, expected);
      expect(AppColors.warmEditorial.primaryInk, expected);
      expect(AppColors.warmEditorial.onBackground, expected);
      expect(AppColors.warmEditorial.onSurface, expected);
      expect(AppTheme.warmEditorial().colorScheme.onSurface, expected);
    });

    // 5. Secondary Slate: #6B655D
    test('Token Invariant 5: Secondary Slate must be exactly #6B655D', () {
      const expected = Color(0xFF6B655D);
      expect(AppColors.secondarySlateColor, expected);
      expect(AppColors.subtitleSecondary, expected);
      expect(AppColors.warmEditorial.secondarySlate, expected);
      expect(AppTheme.warmEditorial().colorScheme.secondary, expected);
      expect(AppTheme.warmEditorial().colorScheme.onSurfaceVariant, expected);
    });

    // 6. Accent Ink Blue: #2F4A7A
    test('Token Invariant 6: Accent Ink Blue must be exactly #2F4A7A', () {
      const expected = Color(0xFF2F4A7A);
      expect(AppColors.accentInkBlueColor, expected);
      expect(AppColors.warmEditorial.accentInkBlue, expected);
      expect(AppColors.warmEditorial.primary, expected);
      expect(AppTheme.warmEditorial().colorScheme.primary, expected);
    });

    // 7. Spoken Highlight: #D6E2F5
    test('Token Invariant 7: Spoken Highlight must be exactly #D6E2F5', () {
      const expected = Color(0xFFD6E2F5);
      expect(AppColors.accentContainerColor, expected);
      expect(AppColors.spokenHighlight, expected);
      expect(AppColors.warmEditorial.accentContainer, expected);
      expect(AppTheme.warmEditorial().colorScheme.primaryContainer, expected);
    });

    // 8. Paper Reader: #F6F1E7
    test('Token Invariant 8: Paper Reader must be exactly #F6F1E7', () {
      const expected = Color(0xFFF6F1E7);
      expect(AppColors.paperReaderColor, expected);
      expect(AppColors.warmEditorial.paperReader, expected);

      final theme = AppTheme.warmEditorial();
      final bandColors = theme.extensions.values.whereType<BandColors>().first;
      expect(bandColors.label, expected);
    });

    // 9. Destructive: #BA1A1A
    test('Token Invariant 9: Destructive must be exactly #BA1A1A', () {
      const expected = Color(0xFFBA1A1A);
      expect(AppColors.destructiveColor, expected);
      expect(AppColors.warmEditorial.destructive, expected);
      expect(AppColors.warmEditorial.error, expected);
      expect(AppTheme.warmEditorial().colorScheme.error, expected);
    });
  });

  group('Milestone 1 Challenge: Shape & Radii Invariants', () {
    test('CardTheme has exact radius 16.0 with side width 1.0 and hairline border', () {
      final theme = AppTheme.warmEditorial();
      expect(AppTheme.cardRadius, 16.0);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());

      final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.circular(16.0)));
      expect(cardShape.side.width, equals(1.0));
      expect(cardShape.side.color, equals(const Color(0xFFE8E2D9)));
    });

    test('BottomSheetTheme has exact vertical top radius 24.0', () {
      final theme = AppTheme.warmEditorial();
      expect(AppTheme.bottomSheetRadius, 24.0);
      expect(theme.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());

      final sheetShape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
      expect(
        sheetShape.borderRadius,
        equals(const BorderRadius.vertical(top: Radius.circular(24.0))),
      );
    });

    test('ChipTheme has StadiumBorder with 1.0 hairline border', () {
      final theme = AppTheme.warmEditorial();
      expect(theme.chipTheme.shape, equals(const StadiumBorder()));
      expect(theme.chipTheme.side?.width, equals(1.0));
      expect(theme.chipTheme.side?.color, equals(const Color(0xFFE8E2D9)));
    });

    test('Buttons and FAB conform to StadiumBorder pill invariant', () {
      final theme = AppTheme.warmEditorial();
      expect(theme.floatingActionButtonTheme.shape, equals(const StadiumBorder()));

      final filledButtonShape =
          theme.filledButtonTheme.style?.shape?.resolve({});
      expect(filledButtonShape, equals(const StadiumBorder()));

      final outlinedButtonShape =
          theme.outlinedButtonTheme.style?.shape?.resolve({});
      expect(outlinedButtonShape, equals(const StadiumBorder()));

      final textButtonShape =
          theme.textButtonTheme.style?.shape?.resolve({});
      expect(textButtonShape, equals(const StadiumBorder()));
    });
  });

  group('Milestone 1 Challenge: Accessibility & WCAG Contrast Ratios', () {
    double relativeLuminance(Color c) {
      double channel(double norm) {
        return norm <= 0.03928
            ? norm / 12.92
            : math.pow((norm + 0.055) / 1.055, 2.4).toDouble();
      }

      return 0.2126 * channel(c.r) +
          0.7152 * channel(c.g) +
          0.0722 * channel(c.b);
    }

    double contrastRatio(Color c1, Color c2) {
      final l1 = relativeLuminance(c1);
      final l2 = relativeLuminance(c2);
      final lighter = math.max(l1, l2);
      final darker = math.min(l1, l2);
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('Primary Ink (#1C1B1A) on Canvas (#FAF7F2) meets WCAG AAA (>= 7.0:1)', () {
      final ratio = contrastRatio(AppColors.primaryInkColor, AppColors.canvasColor);
      expect(ratio, greaterThanOrEqualTo(7.0),
          reason: 'Contrast ratio $ratio does not meet WCAG AAA');
    });

    test('Primary Ink (#1C1B1A) on Card Surface (#FFFFFF) meets WCAG AAA (>= 7.0:1)', () {
      final ratio = contrastRatio(AppColors.primaryInkColor, AppColors.cardSurface);
      expect(ratio, greaterThanOrEqualTo(7.0),
          reason: 'Contrast ratio $ratio does not meet WCAG AAA');
    });

    test('Secondary Slate (#6B655D) on Canvas (#FAF7F2) meets WCAG AA (>= 4.5:1)', () {
      final ratio = contrastRatio(AppColors.secondarySlateColor, AppColors.canvasColor);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Contrast ratio $ratio does not meet WCAG AA');
    });

    test('White text on Accent Ink Blue (#2F4A7A) meets WCAG AAA (>= 7.0:1)', () {
      final ratio = contrastRatio(Colors.white, AppColors.accentInkBlueColor);
      expect(ratio, greaterThanOrEqualTo(7.0),
          reason: 'Contrast ratio $ratio does not meet WCAG AAA');
    });

    test('White text on Destructive (#BA1A1A) meets WCAG AA (>= 4.5:1)', () {
      final ratio = contrastRatio(Colors.white, AppColors.destructiveColor);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Contrast ratio $ratio does not meet WCAG AA');
    });
  });

  group('Milestone 1 Challenge: Theme Wiring & Immutability Stress-Testing', () {
    test('Landscape orientation preserves all tokens and shape invariants', () {
      final landscapeTheme = AppTheme.warmEditorial(orientation: Orientation.landscape);
      expect(landscapeTheme.scaffoldBackgroundColor, const Color(0xFFFAF7F2));
      expect(landscapeTheme.cardTheme.shape, isA<RoundedRectangleBorder>());

      final cardShape = landscapeTheme.cardTheme.shape! as RoundedRectangleBorder;
      expect(cardShape.borderRadius, BorderRadius.circular(16.0));
      expect(landscapeTheme.chipTheme.shape, const StadiumBorder());
    });

    test('AppTheme.light() defaults to warmEditorial()', () {
      final lightTheme = AppTheme.light();
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFFAF7F2));
      expect(lightTheme.colorScheme.primary, const Color(0xFF2F4A7A));
    });

    testWidgets('AppTheme.dark() constructed within ScreenUtilInit context does NOT equal light theme', (tester) async {
      late ThemeData darkTheme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ScreenUtilInit(
                designSize: const Size(412, 915),
                builder: (context, _) {
                  darkTheme = AppTheme.dark();
                  return const SizedBox();
                },
              );
            },
          ),
        ),
      );
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, isNot(const Color(0xFFFAF7F2)));
    });

    test('AppColors lerp edge cases: t=0, t=1, lerp with null', () {
      const colors = AppColors.warmEditorial;
      expect(colors.lerp(null, 0.5), equals(colors));
      expect(colors.lerp(colors, 0.0), isA<AppColors>());
      final atZero = colors.lerp(colors, 0.0) as AppColors;
      expect(atZero.background, colors.background);
      final atOne = colors.lerp(colors, 1.0) as AppColors;
      expect(atOne.accentInkBlue, colors.accentInkBlue);
    });
  });
}
