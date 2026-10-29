import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';
import 'package:lingua_pages/presentation/theme/base/base_color_theme.dart';

/// Paperback Bands: near-black ink ground, one lifted card surface and flat
/// print colours that code each document format. The app chrome is dark-only.
class DarkColorTheme extends BaseColorTheme {
  static const fontFamily = 'Figtree';

  // === Ink and paper ===
  static const _ink = Color(0xFF111315);
  static const _card = Color(0xFF1C1F22);
  static const _cardHigh = Color(0xFF26292D);
  static const _navBar = Color(0xFF16191B);
  static const _paper = Color(0xFFECEAE4);
  static const _paperMuted = Color(0xFFA8A59E);
  static const _rule = Color(0xFF33383D);

  /// Component boundaries (outlined buttons, focused fields) need ≥3:1.
  static const _outline = Color(0xFF6B7076);

  // === Print colours ===
  static const _orange = Color(0xFFE0742E);
  static const _error = Color(0xFFFF8A7A);

  static const bandColors = BandColors(
    epub: _orange,
    pdf: Color(0xFF4FA370),
    txt: Color(0xFF5B8FD6),
    markdown: Color(0xFFB07CCB),
    html: Color(0xFF3FA9A9),
    fb2: Color(0xFFD2AA45),
    onBand: _ink,
    label: Color(0xFFF4F1EA),
    onLabel: _ink,
  );

  @override
  AppColors get getAppColors => const AppColors(
    primary: _orange,
    onPrimary: _ink,
    secondary: _paper,
    onSecondary: _ink,
    background: _ink,
    onBackground: _paper,
    surface: _card,
    onSurface: _paper,
    onSurfaceMuted: _paperMuted,
    error: _error,
    onError: _ink,
    success: Color(0xFF4FA370),
    warning: Color(0xFFD2AA45),
    info: Color(0xFF5B8FD6),
    premium: Color(0xFFB07CCB),
    border: _rule,
    shadow: Color(0x99000000),
    disabled: Color(0xFF5C6166),
    surfaceElevated: _cardHigh,
  );

  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _orange,
    onPrimary: _ink,
    primaryContainer: Color(0xFF4A2A14),
    onPrimaryContainer: Color(0xFFFFD9C2),
    secondary: _paper,
    onSecondary: _ink,
    secondaryContainer: _cardHigh,
    onSecondaryContainer: _paper,
    tertiary: Color(0xFF5B8FD6),
    onTertiary: _ink,
    error: _error,
    onError: _ink,
    errorContainer: Color(0xFF5C1F17),
    onErrorContainer: Color(0xFFFFDAD3),
    surface: _ink,
    onSurface: _paper,
    onSurfaceVariant: _paperMuted,
    surfaceContainerLowest: Color(0xFF0C0D0F),
    surfaceContainerLow: _navBar,
    surfaceContainer: _card,
    surfaceContainerHigh: _cardHigh,
    surfaceContainerHighest: Color(0xFF2F3337),
    outline: _outline,
    outlineVariant: _rule,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: _paper,
    onInverseSurface: _ink,
    inversePrimary: Color(0xFF9A4A16),
    surfaceTint: Colors.transparent,
  );

  @override
  ThemeData getTheme() {
    final appColors = getAppColors;
    const pill = StadiumBorder();
    const labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _ink,
      canvasColor: _ink,
      extensions: [appColors, bandColors],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: _ink,
        foregroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: _paper,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _navBar,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _orange,
        elevation: 0,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? _ink : _paperMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? _paper
                : _paperMuted,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: _navBar,
        indicatorColor: _orange,
        selectedIconTheme: IconThemeData(color: _ink),
        unselectedIconTheme: IconThemeData(color: _paperMuted),
        selectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _paper,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _paperMuted,
        ),
        labelType: NavigationRailLabelType.all,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _paper,
          foregroundColor: _ink,
          disabledBackgroundColor: _cardHigh,
          disabledForegroundColor: _paperMuted,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: pill,
          textStyle: labelStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _paper,
          side: const BorderSide(color: _outline),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: pill,
          textStyle: labelStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _orange,
          minimumSize: const Size(48, 48),
          shape: pill,
          textStyle: labelStyle,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _paper,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _orange,
        foregroundColor: _ink,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      cardTheme: const CardThemeData(
        color: _card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: _paperMuted,
        textColor: _paper,
        minVerticalPadding: 12,
      ),
      dividerTheme: const DividerThemeData(
        color: _rule,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: _card,
        dragHandleColor: _outline,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: _card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _paper,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          height: 1.45,
          color: _paperMuted,
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: _cardHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _paper,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _paper,
        actionTextColor: Color(0xFF9A4A16),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card,
        hintStyle: const TextStyle(color: _paperMuted),
        prefixIconColor: _paperMuted,
        suffixIconColor: _paperMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _orange, width: 2),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: _card,
        selectedColor: _orange,
        side: BorderSide(color: _rule),
        shape: StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: _paper,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _orange,
        linearTrackColor: _cardHigh,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _orange,
        inactiveTrackColor: _cardHigh,
        thumbColor: _paper,
        overlayColor: Color(0x33E0742E),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? _ink : _paperMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? _orange : _cardHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : _outline,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _orange,
        selectionColor: Color(0x66E0742E),
        selectionHandleColor: _orange,
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: _paper,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
    );
  }
}
