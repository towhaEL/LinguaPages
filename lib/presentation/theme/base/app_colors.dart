import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.info,
    required this.premium,
    required this.border,
    required this.shadow,
    required this.disabled,
    required this.surfaceElevated,
    Color? hairline,
    Color? primaryInk,
    Color? secondarySlate,
    Color? accentInkBlue,
    Color? accentContainer,
    Color? paperReader,
    Color? destructive,
    Color? surfaceDim,
    Color? surfaceContainerLow,
    Color? surfaceContainerHighest,
    Color? outline,
    Color? outlineVariant,
    Color? accentHover,
    Color? destructiveContainer,
    Color? highlightYellow,
    Color? highlightGreen,
    Color? highlightBlue,
    Color? highlightPink,
    Color? highlightOrange,
    Color? highlightAmber,
  })  : hairline = hairline ?? border,
        primaryInk = primaryInk ?? onSurface,
        secondarySlate = secondarySlate ?? onSurfaceMuted,
        accentInkBlue = accentInkBlue ?? primary,
        accentContainer = accentContainer ?? const Color(0xFFD6E2F5),
        paperReader = paperReader ?? const Color(0xFFF6F1E7),
        destructive = destructive ?? error,
        surfaceDim = surfaceDim ?? const Color(0xFFF0EDE9),
        surfaceContainerLow = surfaceContainerLow ?? const Color(0xFFF6F3EE),
        surfaceContainerHighest = surfaceContainerHighest ?? const Color(0xFFE5E2DD),
        outline = outline ?? const Color(0xFF747780),
        outlineVariant = outlineVariant ?? const Color(0xFFC4C6D0),
        accentHover = accentHover ?? const Color(0xFF23395E),
        destructiveContainer = destructiveContainer ?? const Color(0xFFFFDAD6),
        highlightYellow = highlightYellow ?? const Color(0xFFFDE047),
        highlightGreen = highlightGreen ?? const Color(0xFF86EFAC),
        highlightBlue = highlightBlue ?? const Color(0xFF93C5FD),
        highlightPink = highlightPink ?? const Color(0xFFF472B6),
        highlightOrange = highlightOrange ?? const Color(0xFFFDBA74),
        highlightAmber = highlightAmber ?? const Color(0xFFE5A93C);

  // Core brand and base
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;

  /// Secondary text on [background] and [surface]; keeps ≥4.5:1 contrast.
  final Color onSurfaceMuted;
  final Color error;
  final Color onError;

  // Semantic
  final Color success;
  final Color warning;
  final Color info;
  final Color premium;

  // Utility
  final Color border;
  final Color shadow;
  final Color disabled;

  /// A surface one step above [surface] for layered cards / sheets.
  final Color surfaceElevated;

  // Named Warm Editorial tokens
  final Color hairline;
  final Color primaryInk;
  final Color secondarySlate;
  final Color accentInkBlue;
  final Color accentContainer;
  final Color paperReader;
  final Color destructive;
  final Color surfaceDim;
  final Color surfaceContainerLow;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color accentHover;
  final Color destructiveContainer;

  // Highlighting Annotations Palette
  final Color highlightYellow;
  final Color highlightGreen;
  final Color highlightBlue;
  final Color highlightPink;
  final Color highlightOrange;
  final Color highlightAmber;

  // Static Warm Editorial Constants
  static const Color canvasColor = Color(0xFFFAF7F2);
  static const Color canvasBackground = Color(0xFFFAF7F2);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceDimColor = Color(0xFFF0EDE9);
  static const Color surfaceContainerLowColor = Color(0xFFF6F3EE);
  static const Color surfaceContainerHighestColor = Color(0xFFE5E2DD);
  static const Color hairlineColor = Color(0xFFE8E2D9);
  static const Color hairlineDivider = Color(0xFFE8E2D9);
  static const Color paperReaderColor = Color(0xFFF6F1E7);
  static const Color primaryInkColor = Color(0xFF1C1B1A);
  static const Color textPrimaryInk = Color(0xFF1C1B1A);
  static const Color secondarySlateColor = Color(0xFF6B655D);
  static const Color subtitleSecondary = Color(0xFF6B655D);
  static const Color outlineColor = Color(0xFF747780);
  static const Color outlineVariantColor = Color(0xFFC4C6D0);
  static const Color accentInkBlueColor = Color(0xFF2F4A7A);
  static const Color accentHoverColor = Color(0xFF23395E);
  static const Color accentContainerColor = Color(0xFFD6E2F5);
  static const Color spokenHighlight = Color(0xFFD6E2F5);
  static const Color destructiveColor = Color(0xFFBA1A1A);
  static const Color destructiveContainerColor = Color(0xFFFFDAD6);

  // Highlighting Palette Static Constants
  static const Color highlightYellowColor = Color(0xFFFDE047);
  static const Color highlightGreenColor = Color(0xFF86EFAC);
  static const Color highlightBlueColor = Color(0xFF93C5FD);
  static const Color highlightPinkColor = Color(0xFFF472B6);
  static const Color highlightOrangeColor = Color(0xFFFDBA74);
  static const Color highlightAmberColor = Color(0xFFE5A93C);

  static const AppColors warmEditorial = AppColors(
    primary: accentInkBlueColor,
    onPrimary: Colors.white,
    secondary: secondarySlateColor,
    onSecondary: Colors.white,
    background: canvasBackground,
    onBackground: primaryInkColor,
    surface: cardSurface,
    onSurface: primaryInkColor,
    onSurfaceMuted: secondarySlateColor,
    error: destructiveColor,
    onError: Colors.white,
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    info: Color(0xFF0288D1),
    premium: accentInkBlueColor,
    border: hairlineDivider,
    shadow: Color(0x1F1C1B1A),
    disabled: Color(0xFFC4C6D0),
    surfaceElevated: cardSurface,
    hairline: hairlineDivider,
    primaryInk: primaryInkColor,
    secondarySlate: secondarySlateColor,
    accentInkBlue: accentInkBlueColor,
    accentContainer: accentContainerColor,
    paperReader: paperReaderColor,
    destructive: destructiveColor,
    surfaceDim: surfaceDimColor,
    surfaceContainerLow: surfaceContainerLowColor,
    surfaceContainerHighest: surfaceContainerHighestColor,
    outline: outlineColor,
    outlineVariant: outlineVariantColor,
    accentHover: accentHoverColor,
    destructiveContainer: destructiveContainerColor,
    highlightYellow: highlightYellowColor,
    highlightGreen: highlightGreenColor,
    highlightBlue: highlightBlueColor,
    highlightPink: highlightPinkColor,
    highlightOrange: highlightOrangeColor,
    highlightAmber: highlightAmberColor,
  );

  // Static Dark Warm Editorial Constants
  static const Color darkCanvasColor = Color(0xFF111315);
  static const Color darkCanvasBackground = Color(0xFF111315);
  static const Color darkCardSurface = Color(0xFF1C1F22);
  static const Color darkSurfaceElevated = Color(0xFF26292D);
  static const Color darkSurfaceDimColor = Color(0xFF16191B);
  static const Color darkSurfaceContainerLowColor = Color(0xFF16191B);
  static const Color darkSurfaceContainerHighestColor = Color(0xFF2F3337);
  static const Color darkHairlineDivider = Color(0xFF33383D);
  static const Color darkPrimaryInkColor = Color(0xFFFAF7F2);
  static const Color darkSecondarySlateColor = Color(0xFFA8A59E);
  static const Color darkAccentInkBlueColor = Color(0xFFA6C8FF);
  static const Color darkAccentContainerColor = Color(0xFF2F4A7A);
  static const Color darkDestructiveColor = Color(0xFFFFB4AB);
  static const Color darkDestructiveContainerColor = Color(0xFF93000A);
  static const Color darkOutlineColor = Color(0xFF6B7076);
  static const Color darkOutlineVariantColor = Color(0xFF33383D);

  static const AppColors darkWarmEditorial = AppColors(
    primary: darkAccentInkBlueColor,
    onPrimary: Color(0xFF003062),
    secondary: darkSecondarySlateColor,
    onSecondary: Color(0xFF111315),
    background: darkCanvasBackground,
    onBackground: darkPrimaryInkColor,
    surface: darkCardSurface,
    onSurface: darkPrimaryInkColor,
    onSurfaceMuted: darkSecondarySlateColor,
    error: darkDestructiveColor,
    onError: Color(0xFF690005),
    success: Color(0xFF4FA370),
    warning: Color(0xFFD2AA45),
    info: Color(0xFF5B8FD6),
    premium: darkAccentInkBlueColor,
    border: darkHairlineDivider,
    shadow: Color(0x99000000),
    disabled: Color(0xFF5C6166),
    surfaceElevated: darkSurfaceElevated,
    hairline: darkHairlineDivider,
    primaryInk: darkPrimaryInkColor,
    secondarySlate: darkSecondarySlateColor,
    accentInkBlue: darkAccentInkBlueColor,
    accentContainer: darkAccentContainerColor,
    paperReader: darkCardSurface,
    destructive: darkDestructiveColor,
    surfaceDim: darkSurfaceDimColor,
    surfaceContainerLow: darkSurfaceContainerLowColor,
    surfaceContainerHighest: darkSurfaceContainerHighestColor,
    outline: darkOutlineColor,
    outlineVariant: darkOutlineVariantColor,
    accentHover: Color(0xFFD6E2F5),
    destructiveContainer: darkDestructiveContainerColor,
    highlightYellow: highlightYellowColor,
    highlightGreen: highlightGreenColor,
    highlightBlue: highlightBlueColor,
    highlightPink: highlightPinkColor,
    highlightOrange: highlightOrangeColor,
    highlightAmber: highlightAmberColor,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? error,
    Color? onError,
    Color? success,
    Color? warning,
    Color? info,
    Color? premium,
    Color? border,
    Color? shadow,
    Color? disabled,
    Color? surfaceElevated,
    Color? hairline,
    Color? primaryInk,
    Color? secondarySlate,
    Color? accentInkBlue,
    Color? accentContainer,
    Color? paperReader,
    Color? destructive,
    Color? surfaceDim,
    Color? surfaceContainerLow,
    Color? surfaceContainerHighest,
    Color? outline,
    Color? outlineVariant,
    Color? accentHover,
    Color? destructiveContainer,
    Color? highlightYellow,
    Color? highlightGreen,
    Color? highlightBlue,
    Color? highlightPink,
    Color? highlightOrange,
    Color? highlightAmber,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      premium: premium ?? this.premium,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      disabled: disabled ?? this.disabled,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      hairline: hairline ?? this.hairline,
      primaryInk: primaryInk ?? this.primaryInk,
      secondarySlate: secondarySlate ?? this.secondarySlate,
      accentInkBlue: accentInkBlue ?? this.accentInkBlue,
      accentContainer: accentContainer ?? this.accentContainer,
      paperReader: paperReader ?? this.paperReader,
      destructive: destructive ?? this.destructive,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      accentHover: accentHover ?? this.accentHover,
      destructiveContainer: destructiveContainer ?? this.destructiveContainer,
      highlightYellow: highlightYellow ?? this.highlightYellow,
      highlightGreen: highlightGreen ?? this.highlightGreen,
      highlightBlue: highlightBlue ?? this.highlightBlue,
      highlightPink: highlightPink ?? this.highlightPink,
      highlightOrange: highlightOrange ?? this.highlightOrange,
      highlightAmber: highlightAmber ?? this.highlightAmber,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      premium: Color.lerp(premium, other.premium, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      secondarySlate: Color.lerp(secondarySlate, other.secondarySlate, t)!,
      accentInkBlue: Color.lerp(accentInkBlue, other.accentInkBlue, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      paperReader: Color.lerp(paperReader, other.paperReader, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      destructiveContainer: Color.lerp(destructiveContainer, other.destructiveContainer, t)!,
      highlightYellow: Color.lerp(highlightYellow, other.highlightYellow, t)!,
      highlightGreen: Color.lerp(highlightGreen, other.highlightGreen, t)!,
      highlightBlue: Color.lerp(highlightBlue, other.highlightBlue, t)!,
      highlightPink: Color.lerp(highlightPink, other.highlightPink, t)!,
      highlightOrange: Color.lerp(highlightOrange, other.highlightOrange, t)!,
      highlightAmber: Color.lerp(highlightAmber, other.highlightAmber, t)!,
    );
  }
}
