/// User preferences that affect reading and study behavior.
class SettingsEntity {
  const SettingsEntity({
    this.readerTheme = ReaderTheme.light,
    this.readerMode = ReaderMode.paginated,
    this.fontSize = 18,
    this.lineSpacing = 1.5,
    this.margin = 16,
    this.readerTextAlignment = ReaderTextAlignment.left,
    this.readerPdfFit = ReaderPdfFit.page,
    this.readerPdfMode = ReaderPdfMode.visual,
    this.keepScreenAwake = false,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'es',
    this.dailyNewCardLimit = 15,
  });

  final ReaderTheme readerTheme;
  final ReaderMode readerMode;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment readerTextAlignment;
  final ReaderPdfFit readerPdfFit;
  final ReaderPdfMode readerPdfMode;
  final bool keepScreenAwake;
  final String sourceLanguage;
  final String targetLanguage;
  final int dailyNewCardLimit;

  SettingsEntity copyWith({
    ReaderTheme? readerTheme,
    ReaderMode? readerMode,
    double? fontSize,
    double? lineSpacing,
    double? margin,
    ReaderTextAlignment? readerTextAlignment,
    ReaderPdfFit? readerPdfFit,
    ReaderPdfMode? readerPdfMode,
    bool? keepScreenAwake,
    String? sourceLanguage,
    String? targetLanguage,
    int? dailyNewCardLimit,
  }) {
    return SettingsEntity(
      readerTheme: readerTheme ?? this.readerTheme,
      readerMode: readerMode ?? this.readerMode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      margin: margin ?? this.margin,
      readerTextAlignment: readerTextAlignment ?? this.readerTextAlignment,
      readerPdfFit: readerPdfFit ?? this.readerPdfFit,
      readerPdfMode: readerPdfMode ?? this.readerPdfMode,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      dailyNewCardLimit: dailyNewCardLimit ?? this.dailyNewCardLimit,
    );
  }
}

enum ReaderTheme { light, sepia, dark }

enum ReaderMode { paginated, continuous }

enum ReaderTextAlignment { left, center, justify }

enum ReaderPdfFit { page, width }

enum ReaderPdfMode { visual, text }
