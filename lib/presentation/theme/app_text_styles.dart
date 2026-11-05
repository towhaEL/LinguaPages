import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/app_text_theme.dart';

abstract final class AppTextStyles {
  // Headlines and Editorial Titles (Newsreader serif)
  static TextStyle displayLarge({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
        letterSpacing: -0.72,
        color: color,
      );

  static TextStyle displayMedium({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 30,
        fontWeight: FontWeight.w400,
        height: 1.27,
        letterSpacing: -0.45,
        color: color,
      );

  static TextStyle displaySmall({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.30,
        letterSpacing: -0.26,
        color: color,
      );

  static TextStyle headlineLarge({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.30,
        letterSpacing: -0.26,
        color: color,
      );

  static TextStyle headlineMedium({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        letterSpacing: -0.22,
        color: color,
      );

  static TextStyle headlineSmall({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: color,
      );

  static TextStyle titleLarge({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: color,
      );

  // UI Controls, Metadata, and Body (Inter sans)
  static TextStyle titleMedium({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.40,
        color: color,
      );

  static TextStyle titleSmall({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.42,
        letterSpacing: 0.14,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0.18,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.47,
        letterSpacing: -0.08,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.secondarySlateColor}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        color: color,
      );

  static TextStyle labelLarge({Color color = AppColors.primaryInkColor}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.42,
        letterSpacing: 0.14,
        color: color,
      );

  static TextStyle labelMedium({Color color = AppColors.secondarySlateColor}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.24,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.secondarySlateColor}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.27,
        letterSpacing: 0.33,
        color: color,
      );

  /// Tabular figures for numbers, timers, counters, and percentages.
  static TextStyle tabular(TextStyle base) => base.copyWith(
        fontFeatures: [
          ...?base.fontFeatures,
          const FontFeature.tabularFigures(),
        ],
      );

  /// Creates a Material [TextTheme] aligned with Warm Editorial typography.
  static TextTheme createMaterialTextTheme({
    Color textColor = AppColors.primaryInkColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge(color: textColor),
      displayMedium: displayMedium(color: textColor),
      displaySmall: displaySmall(color: textColor),
      headlineLarge: headlineLarge(color: textColor),
      headlineMedium: headlineMedium(color: textColor),
      headlineSmall: headlineSmall(color: textColor),
      titleLarge: titleLarge(color: textColor),
      titleMedium: titleMedium(color: textColor),
      titleSmall: titleSmall(color: textColor),
      labelLarge: labelLarge(color: textColor),
      labelMedium: labelMedium(color: textColor),
      labelSmall: labelSmall(color: textColor),
      bodyLarge: bodyLarge(color: textColor),
      bodyMedium: bodyMedium(color: textColor),
      bodySmall: bodySmall(color: textColor),
    );
  }

  /// Creates an [AppTextTheme] extension populated with Warm Editorial styles.
  static AppTextTheme createAppTextTheme({
    Color textColor = AppColors.primaryInkColor,
  }) {
    return AppTextTheme(
      displayLarge: displayLarge(color: textColor),
      displayMedium: displayMedium(color: textColor),
      displaySmall: displaySmall(color: textColor),
      headlineLarge: headlineLarge(color: textColor),
      headlineMedium: headlineMedium(color: textColor),
      headlineSmall: headlineSmall(color: textColor),
      titleLarge: titleLarge(color: textColor),
      titleMedium: titleMedium(color: textColor),
      titleSmall: titleSmall(color: textColor),
      labelLarge: labelLarge(color: textColor),
      labelMedium: labelMedium(color: textColor),
      labelSmall: labelSmall(color: textColor),
      bodyLarge: bodyLarge(color: textColor),
      bodyMedium: bodyMedium(color: textColor),
      bodySmall: bodySmall(color: textColor),
    );
  }
}

extension TextStyleTabularFiguresX on TextStyle {
  TextStyle get withTabularFigures => copyWith(
        fontFeatures: [
          ...?fontFeatures,
          const FontFeature.tabularFigures(),
        ],
      );
}
