import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';

/// Authoritative token constants for Warm Editorial Minimalism.
abstract final class WarmEditorialTokens {
  static const canvasBackground = Color(0xFFFAF7F2);
  static const cardSurface = Color(0xFFFFFFFF);
  static const surfaceDim = Color(0xFFF0EDE9);
  static const surfaceContainerLow = Color(0xFFF6F3EE);
  static const surfaceContainerHighest = Color(0xFFE5E2DD);
  static const hairlineDivider = Color(0xFFE8E2D9);
  static const paperReader = Color(0xFFF6F1E7);
  static const textPrimaryInk = Color(0xFF1C1B1A);
  static const subtitleSecondary = Color(0xFF6B655D);
  static const accentInkBlue = Color(0xFF2F4A7A);
  static const accentHover = Color(0xFF23395E);
  static const spokenHighlight = Color(0xFFD6E2F5);
  static const destructive = Color(0xFFBA1A1A);
  static const destructiveContainer = Color(0xFFFFDAD6);

  // Highlight Palette
  static const highlightYellow = Color(0xFFFDE047);
  static const highlightGreen = Color(0xFF86EFAC);
  static const highlightBlue = Color(0xFF93C5FD);
  static const highlightPink = Color(0xFFF472B6);
  static const highlightOrange = Color(0xFFFDBA74);
  static const highlightAmber = Color(0xFFE5A93C);

  // Radii
  static const cardRadius = 16.0;
  static const bottomSheetRadius = 24.0;
  static const bottomSheetRadiusLarge = 28.0;
  static const bookCoverRadius = 4.0;

  // Viewport Dimensions
  static const standardViewport = Size(412, 915);
}

/// Creates a standardized ThemeData wired to Warm Editorial specifications.
ThemeData createWarmEditorialTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: WarmEditorialTokens.canvasBackground,
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: WarmEditorialTokens.canvasBackground,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: WarmEditorialTokens.accentInkBlue,
      onPrimary: Colors.white,
      primaryContainer: WarmEditorialTokens.spokenHighlight,
      onPrimaryContainer: WarmEditorialTokens.accentInkBlue,
      secondary: WarmEditorialTokens.subtitleSecondary,
      onSecondary: Colors.white,
      error: WarmEditorialTokens.destructive,
      onError: Colors.white,
      errorContainer: WarmEditorialTokens.destructiveContainer,
      onErrorContainer: WarmEditorialTokens.destructive,
      surface: WarmEditorialTokens.cardSurface,
      onSurface: WarmEditorialTokens.textPrimaryInk,
      outline: WarmEditorialTokens.hairlineDivider,
    ),
    cardTheme: CardThemeData(
      color: WarmEditorialTokens.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
        side: const BorderSide(
          color: WarmEditorialTokens.hairlineDivider,
          width: 1.0,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: WarmEditorialTokens.cardSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WarmEditorialTokens.bottomSheetRadius),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: const BorderSide(
        color: WarmEditorialTokens.hairlineDivider,
        width: 1.0,
      ),
      backgroundColor: WarmEditorialTokens.cardSurface,
      selectedColor: WarmEditorialTokens.accentInkBlue,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        color: WarmEditorialTokens.textPrimaryInk,
      ),
    ),
    extensions: const [
      AppColors(
        primary: WarmEditorialTokens.accentInkBlue,
        onPrimary: Colors.white,
        secondary: WarmEditorialTokens.subtitleSecondary,
        onSecondary: Colors.white,
        background: WarmEditorialTokens.canvasBackground,
        onBackground: WarmEditorialTokens.textPrimaryInk,
        surface: WarmEditorialTokens.cardSurface,
        onSurface: WarmEditorialTokens.textPrimaryInk,
        onSurfaceMuted: WarmEditorialTokens.subtitleSecondary,
        error: WarmEditorialTokens.destructive,
        onError: Colors.white,
        success: Color(0xFF2E7D32),
        warning: Color(0xFFED6C02),
        info: Color(0xFF0288D1),
        premium: WarmEditorialTokens.accentInkBlue,
        border: WarmEditorialTokens.hairlineDivider,
        shadow: Color(0x1F1C1B1A),
        disabled: Color(0xFFC4C6D0),
        surfaceElevated: WarmEditorialTokens.cardSurface,
      ),
      BandColors(
        epub: Color(0xFF2F4A7A),
        pdf: Color(0xFFBA1A1A),
        txt: Color(0xFF6B655D),
        markdown: Color(0xFF2E7D32),
        html: Color(0xFFE65100),
        fb2: Color(0xFF6A1B9A),
        onBand: Colors.white,
        label: WarmEditorialTokens.paperReader,
        onLabel: WarmEditorialTokens.textPrimaryInk,
      ),
    ],
  );
}

/// Configures the test environment viewport and builds a hermetic MaterialApp.
Widget buildTestHarness({
  required Widget child,
  ThemeData? theme,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme ?? createWarmEditorialTheme(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

/// Convenience test extension to pump a widget within the Warm Editorial harness.
extension WidgetTesterHarnessExtension on WidgetTester {
  Future<void> pumpHarness(
    Widget child, {
    ThemeData? theme,
    Size viewport = WarmEditorialTokens.standardViewport,
    Duration? pumpDuration,
  }) async {
    view.physicalSize = viewport * view.devicePixelRatio;
    addTearDown(() => view.resetPhysicalSize());

    await pumpWidget(buildTestHarness(child: child, theme: theme));
    if (pumpDuration != null) {
      await pump(pumpDuration);
    } else {
      await pumpAndSettle();
    }
  }

  /// Strictly asserts the non-negotiable architectural rule:
  /// NO persistent bottom navigation bar may exist anywhere.
  void expectNoBottomNavigationBar() {
    expect(
      find.byType(NavigationBar),
      findsNothing,
      reason: 'Architecture violation: NavigationBar must NOT be present!',
    );
    expect(
      find.byType(BottomNavigationBar),
      findsNothing,
      reason: 'Architecture violation: BottomNavigationBar must NOT be present!',
    );
  }
}
