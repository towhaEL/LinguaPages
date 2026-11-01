import 'package:lingua_pages/domain/entity/library/book_entity.dart';

/// User preferences that affect reading behavior and the library shelf.
class SettingsEntity {
  const SettingsEntity({
    this.readerTheme = ReaderTheme.light,
    this.readerFont = ReaderFont.original,
    this.readerMode = ReaderMode.paginated,
    this.fontSize = 18,
    this.lineSpacing = 1.5,
    this.margin = 16,
    this.readerTextAlignment = ReaderTextAlignment.left,
    this.readerPdfFit = ReaderPdfFit.page,
    this.readerPdfMode = ReaderPdfMode.visual,
    this.keepScreenAwake = false,
    this.onlineDictionary = true,
    this.libraryListView = false,
    this.librarySort = LibrarySort.recent,
  });

  final ReaderTheme readerTheme;
  final ReaderFont readerFont;
  final ReaderMode readerMode;
  final double fontSize;
  final double lineSpacing;
  final double margin;
  final ReaderTextAlignment readerTextAlignment;
  final ReaderPdfFit readerPdfFit;
  final ReaderPdfMode readerPdfMode;
  final bool keepScreenAwake;

  /// When off, word lookups only use definitions already cached on device.
  final bool onlineDictionary;

  /// The shelf shows a list instead of the cover grid.
  final bool libraryListView;
  final LibrarySort librarySort;

  SettingsEntity copyWith({
    ReaderTheme? readerTheme,
    ReaderFont? readerFont,
    ReaderMode? readerMode,
    double? fontSize,
    double? lineSpacing,
    double? margin,
    ReaderTextAlignment? readerTextAlignment,
    ReaderPdfFit? readerPdfFit,
    ReaderPdfMode? readerPdfMode,
    bool? keepScreenAwake,
    bool? onlineDictionary,
    bool? libraryListView,
    LibrarySort? librarySort,
  }) {
    return SettingsEntity(
      readerTheme: readerTheme ?? this.readerTheme,
      readerFont: readerFont ?? this.readerFont,
      readerMode: readerMode ?? this.readerMode,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      margin: margin ?? this.margin,
      readerTextAlignment: readerTextAlignment ?? this.readerTextAlignment,
      readerPdfFit: readerPdfFit ?? this.readerPdfFit,
      readerPdfMode: readerPdfMode ?? this.readerPdfMode,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      onlineDictionary: onlineDictionary ?? this.onlineDictionary,
      libraryListView: libraryListView ?? this.libraryListView,
      librarySort: librarySort ?? this.librarySort,
    );
  }
}

enum ReaderTheme {
  light,
  sepia,
  dark,
  twilight,
  nightContrast,
  sepiaContrast,
  sage,
}

/// Body font for reflowable text. [original] keeps the book's own font.
enum ReaderFont { original, serif, sans, literata, sourceSerif, ebGaramond }

enum ReaderMode { paginated, continuous }

enum ReaderTextAlignment { left, center, justify }

enum ReaderPdfFit { page, width }

enum ReaderPdfMode { visual, text }
