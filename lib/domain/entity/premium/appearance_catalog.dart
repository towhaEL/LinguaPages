import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

/// Every reading look the app offers, with its premium flag.
///
/// Premium only ever changes appearance. Reading, annotations, export, backup
/// and the dictionary never check entitlement.
abstract final class AppearanceCatalog {
  static const presets = [
    ReaderStylePreset(
      id: ReaderStylePresetId.standard,
      font: ReaderFont.original,
      fontSize: 18,
      lineSpacing: 1.5,
      margin: 16,
      alignment: ReaderTextAlignment.left,
    ),
    ReaderStylePreset(
      id: ReaderStylePresetId.classic,
      font: ReaderFont.literata,
      fontSize: 19,
      lineSpacing: 1.6,
      margin: 20,
      alignment: ReaderTextAlignment.justify,
    ),
    ReaderStylePreset(
      id: ReaderStylePresetId.airy,
      font: ReaderFont.sourceSerif,
      fontSize: 18,
      lineSpacing: 1.9,
      margin: 28,
      alignment: ReaderTextAlignment.left,
    ),
    ReaderStylePreset(
      id: ReaderStylePresetId.compact,
      font: ReaderFont.ebGaramond,
      fontSize: 19,
      lineSpacing: 1.3,
      margin: 12,
      alignment: ReaderTextAlignment.justify,
    ),
  ];

  /// Whether [settings] use any appearance item that needs premium.
  static bool usesPremium(SettingsEntity settings) =>
      settings.readerTheme.isPremium || settings.readerFont.isPremium;

  /// What the reader shows. Without premium, locked items fall back to free
  /// ones; the saved choice itself is kept so it returns after a restore.
  static SettingsEntity effective(
    SettingsEntity settings, {
    required bool premium,
  }) {
    if (premium) return settings;
    return settings.copyWith(
      readerTheme: settings.readerTheme.freeFallback,
      readerFont: settings.readerFont.isPremium
          ? ReaderFont.original
          : settings.readerFont,
    );
  }

  /// What gets saved when [next] comes from the settings sheet, which starts
  /// from [effective]. Without premium, a theme or font is only saved when
  /// the user picked a different free one: a previewed premium item is not
  /// saved, and an expired user's saved premium choice survives other edits.
  static SettingsEntity persistable(
    SettingsEntity next, {
    required SettingsEntity saved,
    required bool premium,
  }) {
    if (premium) return next;
    final shown = effective(saved, premium: false);
    return next.copyWith(
      readerTheme:
          next.readerTheme.isPremium || next.readerTheme == shown.readerTheme
          ? saved.readerTheme
          : next.readerTheme,
      readerFont:
          next.readerFont.isPremium || next.readerFont == shown.readerFont
          ? saved.readerFont
          : next.readerFont,
    );
  }
}

extension ReaderThemeAppearance on ReaderTheme {
  bool get isPremium => switch (this) {
    ReaderTheme.light || ReaderTheme.sepia || ReaderTheme.dark => false,
    _ => true,
  };

  /// Light text on a dark page; highlights then use deep tints.
  bool get isDarkPage => switch (this) {
    ReaderTheme.dark || ReaderTheme.twilight || ReaderTheme.nightContrast =>
      true,
    _ => false,
  };

  /// The closest free theme, so a night theme never falls back to white.
  ReaderTheme get freeFallback => switch (this) {
    ReaderTheme.twilight || ReaderTheme.nightContrast => ReaderTheme.dark,
    ReaderTheme.sepiaContrast => ReaderTheme.sepia,
    ReaderTheme.sage => ReaderTheme.light,
    _ => this,
  };

  /// Page colour as 0xAARRGGBB.
  int get backgroundArgb => switch (this) {
    ReaderTheme.light => 0xFFFFFFFF,
    ReaderTheme.sepia => 0xFFF6EFD9,
    ReaderTheme.dark => 0xFF121212,
    ReaderTheme.twilight => 0xFF1F2433,
    ReaderTheme.nightContrast => 0xFF000000,
    ReaderTheme.sepiaContrast => 0xFFEFE0BA,
    ReaderTheme.sage => 0xFFE2EADB,
  };

  /// Body text colour as 0xAARRGGBB.
  int get textArgb => switch (this) {
    ReaderTheme.light => 0xFF1A1A1A,
    ReaderTheme.sepia => 0xFF4A3B2A,
    ReaderTheme.dark => 0xFFE9E9E9,
    ReaderTheme.twilight => 0xFFD8DCE8,
    ReaderTheme.nightContrast => 0xFFF5F5F5,
    ReaderTheme.sepiaContrast => 0xFF2A1D0E,
    ReaderTheme.sage => 0xFF1F2D1C,
  };
}

extension HighlightTint on HighlightColor {
  /// Opaque fill drawn behind highlighted text as 0xAARRGGBB. Pale on light
  /// pages and deep on dark ones; every page theme's text stays at 5:1 or
  /// better on top of it (7:1 or better on light pages).
  int tintArgb({required bool darkPage}) => darkPage
      ? switch (this) {
          HighlightColor.yellow => 0xFF6B5714,
          HighlightColor.green => 0xFF2A5C37,
          HighlightColor.blue => 0xFF234A78,
          HighlightColor.pink => 0xFF6B2A4B,
        }
      : switch (this) {
          HighlightColor.yellow => 0xFFFFE08A,
          HighlightColor.green => 0xFFB9E4BE,
          HighlightColor.blue => 0xFFB8D8F5,
          HighlightColor.pink => 0xFFF6C3D6,
        };
}

extension ReaderFontAppearance on ReaderFont {
  bool get isPremium => switch (this) {
    ReaderFont.original || ReaderFont.serif || ReaderFont.sans => false,
    _ => true,
  };

  /// Font family name for both renderers; null keeps the book's own font.
  /// `serif` and `sans-serif` are platform generic families; the rest are
  /// bundled under `assets/fonts`.
  String? get family => switch (this) {
    ReaderFont.original => null,
    ReaderFont.serif => 'serif',
    ReaderFont.sans => 'sans-serif',
    ReaderFont.literata => 'Literata',
    ReaderFont.sourceSerif => 'Source Serif 4',
    ReaderFont.ebGaramond => 'EB Garamond',
  };
}

enum ReaderStylePresetId { standard, classic, airy, compact }

/// A named bundle of font, size, line spacing, margins and alignment.
class ReaderStylePreset {
  const ReaderStylePreset({
    required this.id,
    required this.font,
    required this.fontSize,
    required this.lineSpacing,
    required this.margin,
    required this.alignment,
  });

  final ReaderStylePresetId id;
  final ReaderFont font;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment alignment;

  bool get isPremium => id != ReaderStylePresetId.standard;

  SettingsEntity applyTo(SettingsEntity settings) => settings.copyWith(
    readerFont: font,
    fontSize: fontSize,
    lineSpacing: lineSpacing,
    margin: margin,
    readerTextAlignment: alignment,
  );

  bool matches(SettingsEntity settings) =>
      settings.readerFont == font &&
      settings.fontSize == fontSize &&
      settings.lineSpacing == lineSpacing &&
      settings.margin == margin &&
      settings.readerTextAlignment == alignment;
}
