import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/app_text_styles.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';

class AppTheme {
  const AppTheme._();

  static const double cardRadius = 16.0;
  static const double bottomSheetRadius = 24.0;
  static const double bottomSheetRadiusLarge = 28.0;
  static const double bookCoverRadius = 4.0;

  static const BorderSide hairlineBorder = BorderSide(
    color: AppColors.hairlineDivider,
    width: 1.0,
  );

  static const StadiumBorder stadiumBorder = StadiumBorder(
    side: hairlineBorder,
  );

  static const BorderSide darkHairlineBorder = BorderSide(
    color: AppColors.darkHairlineDivider,
    width: 1.0,
  );

  static const StadiumBorder darkStadiumBorder = StadiumBorder(
    side: darkHairlineBorder,
  );

  /// Default Light Theme using Warm Editorial Minimalism.
  static ThemeData light({Orientation orientation = Orientation.portrait}) {
    return warmEditorial(orientation: orientation);
  }

  /// Dark Theme using Warm Editorial Minimalism.
  static ThemeData dark({Orientation orientation = Orientation.portrait}) {
    return darkWarmEditorial(orientation: orientation);
  }

  /// Master Dark Theme configuration using Warm Editorial Minimalism.
  static ThemeData darkWarmEditorial({
    Orientation orientation = Orientation.portrait,
  }) {
    const appColors = AppColors.darkWarmEditorial;
    const bandColors = BandColors(
      epub: AppColors.darkAccentInkBlueColor,
      pdf: AppColors.darkDestructiveColor,
      txt: AppColors.darkSecondarySlateColor,
      markdown: Color(0xFF4FA370),
      html: Color(0xFFD2AA45),
      fb2: Color(0xFFB07CCB),
      onBand: Color(0xFF111315),
      label: AppColors.darkCardSurface,
      onLabel: AppColors.darkPrimaryInkColor,
    );

    final textTheme = AppTextStyles.createMaterialTextTheme(
      textColor: AppColors.darkPrimaryInkColor,
    );
    final appTextTheme = AppTextStyles.createAppTextTheme(
      textColor: AppColors.darkPrimaryInkColor,
    );

    const pill = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvasBackground,
      canvasColor: AppColors.darkCanvasBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkAccentInkBlueColor,
        onPrimary: Color(0xFF003062),
        primaryContainer: AppColors.darkAccentContainerColor,
        onPrimaryContainer: Color(0xFFD6E2F5),
        secondary: AppColors.darkSecondarySlateColor,
        onSecondary: Color(0xFF111315),
        secondaryContainer: AppColors.darkSurfaceElevated,
        onSecondaryContainer: AppColors.darkPrimaryInkColor,
        tertiary: Color(0xFF5B8FD6),
        onTertiary: Color(0xFF111315),
        error: AppColors.darkDestructiveColor,
        onError: Color(0xFF690005),
        errorContainer: AppColors.darkDestructiveContainerColor,
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.darkCardSurface,
        onSurface: AppColors.darkPrimaryInkColor,
        onSurfaceVariant: AppColors.darkSecondarySlateColor,
        surfaceContainerLowest: Color(0xFF0C0D0F),
        surfaceContainerLow: AppColors.darkSurfaceContainerLowColor,
        surfaceContainer: AppColors.darkCardSurface,
        surfaceContainerHigh: AppColors.darkSurfaceElevated,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighestColor,
        outline: AppColors.darkOutlineColor,
        outlineVariant: AppColors.darkOutlineVariantColor,
        shadow: Color(0x99000000),
        scrim: Colors.black,
        inverseSurface: AppColors.darkPrimaryInkColor,
        onInverseSurface: AppColors.darkCanvasBackground,
        inversePrimary: AppColors.accentInkBlueColor,
        surfaceTint: Colors.transparent,
      ),
      textTheme: textTheme,
      extensions: [
        appColors,
        bandColors,
        appTextTheme,
      ],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCanvasBackground,
        foregroundColor: AppColors.darkPrimaryInkColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryInkColor,
          letterSpacing: -0.22,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkPrimaryInkColor,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: darkHairlineBorder,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCardSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.darkCardSurface,
        elevation: 8,
        dragHandleColor: AppColors.darkSecondarySlateColor,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(bottomSheetRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardSurface,
        selectedColor: AppColors.darkAccentInkBlueColor,
        side: darkHairlineBorder,
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryInkColor,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF003062),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkAccentInkBlueColor,
          foregroundColor: const Color(0xFF003062),
          disabledBackgroundColor: AppColors.darkSurfaceContainerHighestColor,
          disabledForegroundColor: AppColors.darkSecondarySlateColor,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkAccentInkBlueColor,
          side: darkHairlineBorder,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkAccentInkBlueColor,
          minimumSize: const Size(48, 48),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkPrimaryInkColor,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkAccentInkBlueColor,
        foregroundColor: Color(0xFF003062),
        elevation: 4,
        shape: StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkHairlineDivider,
        thickness: 1.0,
        space: 1.0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: darkHairlineBorder,
        ),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkPrimaryInkColor,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.darkSecondarySlateColor,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceElevated,
        actionTextColor: AppColors.darkAccentInkBlueColor,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkPrimaryInkColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardSurface,
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkSecondarySlateColor,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.darkSecondarySlateColor,
        suffixIconColor: AppColors.darkSecondarySlateColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: darkHairlineBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: darkHairlineBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkAccentInkBlueColor,
            width: 1.5,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkAccentInkBlueColor,
        linearTrackColor: AppColors.darkSurfaceContainerHighestColor,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.darkAccentInkBlueColor,
        inactiveTrackColor: AppColors.darkSurfaceContainerHighestColor,
        thumbColor: AppColors.darkAccentInkBlueColor,
        overlayColor: Color(0x2EA6C8FF),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0xFF003062)
              : AppColors.darkSecondarySlateColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.darkAccentInkBlueColor
              : AppColors.darkSurfaceContainerHighestColor,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.darkHairlineDivider,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.darkAccentInkBlueColor,
        selectionColor: Color(0x40A6C8FF),
        selectionHandleColor: AppColors.darkAccentInkBlueColor,
      ),
    );
  }

  /// Master Warm Editorial Theme configuration.
  static ThemeData warmEditorial({
    Orientation orientation = Orientation.portrait,
  }) {
    const appColors = AppColors.warmEditorial;
    const bandColors = BandColors(
      epub: AppColors.accentInkBlueColor,
      pdf: AppColors.destructiveColor,
      txt: AppColors.secondarySlateColor,
      markdown: Color(0xFF2E7D32),
      html: Color(0xFFE65100),
      fb2: Color(0xFF6A1B9A),
      onBand: Colors.white,
      label: AppColors.paperReaderColor,
      onLabel: AppColors.primaryInkColor,
    );

    final textTheme = AppTextStyles.createMaterialTextTheme(
      textColor: AppColors.primaryInkColor,
    );
    final appTextTheme = AppTextStyles.createAppTextTheme(
      textColor: AppColors.primaryInkColor,
    );

    const pill = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvasBackground,
      canvasColor: AppColors.canvasBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.accentInkBlueColor,
        onPrimary: Colors.white,
        primaryContainer: AppColors.accentContainerColor,
        onPrimaryContainer: AppColors.accentInkBlueColor,
        secondary: AppColors.secondarySlateColor,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.surfaceContainerLowColor,
        onSecondaryContainer: AppColors.primaryInkColor,
        tertiary: Color(0xFF3B608C),
        onTertiary: Colors.white,
        error: AppColors.destructiveColor,
        onError: Colors.white,
        errorContainer: AppColors.destructiveContainerColor,
        onErrorContainer: AppColors.destructiveColor,
        surface: AppColors.cardSurface,
        onSurface: AppColors.primaryInkColor,
        onSurfaceVariant: AppColors.secondarySlateColor,
        surfaceContainerLowest: AppColors.cardSurface,
        surfaceContainerLow: AppColors.surfaceContainerLowColor,
        surfaceContainer: AppColors.surfaceDimColor,
        surfaceContainerHigh: AppColors.surfaceContainerHighestColor,
        surfaceContainerHighest: AppColors.surfaceContainerHighestColor,
        outline: AppColors.hairlineDivider,
        outlineVariant: AppColors.outlineVariantColor,
        shadow: Color(0x1F1C1B1A),
        scrim: Color(0x591C1C19),
        inverseSurface: AppColors.primaryInkColor,
        onInverseSurface: AppColors.canvasBackground,
        inversePrimary: Color(0xFFA6C8FF),
        surfaceTint: Colors.transparent,
      ),
      textTheme: textTheme,
      extensions: [
        appColors,
        bandColors,
        appTextTheme,
      ],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvasBackground,
        foregroundColor: AppColors.primaryInkColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryInkColor,
          letterSpacing: -0.22,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryInkColor,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: hairlineBorder,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.cardSurface,
        elevation: 8,
        dragHandleColor: AppColors.secondarySlateColor,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(bottomSheetRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardSurface,
        selectedColor: AppColors.accentInkBlueColor,
        side: hairlineBorder,
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryInkColor,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentInkBlueColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerHighestColor,
          disabledForegroundColor: AppColors.secondarySlateColor,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentInkBlueColor,
          side: const BorderSide(color: AppColors.hairlineDivider, width: 1.0),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentInkBlueColor,
          minimumSize: const Size(48, 48),
          shape: pill,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primaryInkColor,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentInkBlueColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairlineDivider,
        thickness: 1.0,
        space: 1.0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: hairlineBorder,
        ),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryInkColor,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.secondarySlateColor,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryInkColor,
        actionTextColor: AppColors.accentContainerColor,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        hintStyle: GoogleFonts.inter(
          color: AppColors.secondarySlateColor,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.secondarySlateColor,
        suffixIconColor: AppColors.secondarySlateColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hairlineBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hairlineBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.accentInkBlueColor,
            width: 1.5,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentInkBlueColor,
        linearTrackColor: AppColors.surfaceContainerHighestColor,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accentInkBlueColor,
        inactiveTrackColor: AppColors.surfaceContainerHighestColor,
        thumbColor: AppColors.accentInkBlueColor,
        overlayColor: Color(0x2E2F4A7A),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.secondarySlateColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accentInkBlueColor
              : AppColors.surfaceContainerHighestColor,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.hairlineDivider,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accentInkBlueColor,
        selectionColor: Color(0x40D6E2F5),
        selectionHandleColor: AppColors.accentInkBlueColor,
      ),
    );
  }
}
