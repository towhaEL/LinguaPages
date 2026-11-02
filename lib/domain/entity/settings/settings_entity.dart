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
    this.hyphenation = false,
    this.paragraphSpacing = 0,
    this.paragraphIndent = 0,
    this.letterSpacing = 0,
    this.wordSpacing = 0,
    this.fontWeight = 1,
    this.publisherStyles = false,
    this.readerColumns = ReaderColumns.auto,
    this.readerDirection = ReaderDirection.book,
    this.readerImageFilter = ReaderImageFilter.none,
    this.keepScreenAwake = false,
    this.readerTapZones = ReaderTapZones.sides,
    this.volumeKeyPaging = false,
    this.fullScreenReading = false,
    this.readerOrientation = ReaderOrientation.auto,
    this.edgeBrightness = false,
    this.readerProgressDisplay = ReaderProgressDisplay.none,
    this.cornerShortcuts = false,
    this.readAloudSpeed = 1,
    this.readAloudVoices = const {},
    this.readAloudSkipPageNumbers = true,
    this.readAloudKeepScreenOn = false,
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
  final bool hyphenation;

  /// Extra space between paragraphs in rem; 0 keeps the book's spacing.
  final double paragraphSpacing;

  /// First-line indent in rem; 0 keeps the book's indent.
  final double paragraphIndent;

  /// Extra letter spacing in em; 0 keeps the book's spacing.
  final double letterSpacing;

  /// Extra word spacing in rem; 0 keeps the book's spacing.
  final double wordSpacing;

  /// Weight relative to the book's text; 1 keeps it.
  final double fontWeight;

  /// Keep the book's own stylesheet. Theme colours and most text settings
  /// then only partly apply.
  final bool publisherStyles;
  final ReaderColumns readerColumns;
  final ReaderDirection readerDirection;

  /// Applied to images on dark reading themes only.
  final ReaderImageFilter readerImageFilter;
  final bool keepScreenAwake;

  /// How taps on a fallback page turn it; the native reader keeps its own
  /// edge taps.
  final ReaderTapZones readerTapZones;

  /// Volume down turns forward and volume up back while reading.
  final bool volumeKeyPaging;

  /// Hide the status and navigation bars while reading.
  final bool fullScreenReading;
  final ReaderOrientation readerOrientation;

  /// A vertical swipe on the left page edge sets a reader-only brightness.
  final bool edgeBrightness;

  /// What the page shows of the position while the chrome is hidden.
  final ReaderProgressDisplay readerProgressDisplay;

  /// Top-right corner adds a bookmark, top-left switches light/dark page.
  final bool cornerShortcuts;

  /// Read-aloud rate, 1 being the voice's normal speed.
  final double readAloudSpeed;

  /// The chosen voice id for each language tag.
  final Map<String, String> readAloudVoices;
  final bool readAloudSkipPageNumbers;
  final bool readAloudKeepScreenOn;

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
    bool? hyphenation,
    double? paragraphSpacing,
    double? paragraphIndent,
    double? letterSpacing,
    double? wordSpacing,
    double? fontWeight,
    bool? publisherStyles,
    ReaderColumns? readerColumns,
    ReaderDirection? readerDirection,
    ReaderImageFilter? readerImageFilter,
    bool? keepScreenAwake,
    ReaderTapZones? readerTapZones,
    bool? volumeKeyPaging,
    bool? fullScreenReading,
    ReaderOrientation? readerOrientation,
    bool? edgeBrightness,
    ReaderProgressDisplay? readerProgressDisplay,
    bool? cornerShortcuts,
    double? readAloudSpeed,
    Map<String, String>? readAloudVoices,
    bool? readAloudSkipPageNumbers,
    bool? readAloudKeepScreenOn,
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
      hyphenation: hyphenation ?? this.hyphenation,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      paragraphIndent: paragraphIndent ?? this.paragraphIndent,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
      publisherStyles: publisherStyles ?? this.publisherStyles,
      readerColumns: readerColumns ?? this.readerColumns,
      readerDirection: readerDirection ?? this.readerDirection,
      readerImageFilter: readerImageFilter ?? this.readerImageFilter,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      readerTapZones: readerTapZones ?? this.readerTapZones,
      volumeKeyPaging: volumeKeyPaging ?? this.volumeKeyPaging,
      fullScreenReading: fullScreenReading ?? this.fullScreenReading,
      readerOrientation: readerOrientation ?? this.readerOrientation,
      edgeBrightness: edgeBrightness ?? this.edgeBrightness,
      readerProgressDisplay:
          readerProgressDisplay ?? this.readerProgressDisplay,
      cornerShortcuts: cornerShortcuts ?? this.cornerShortcuts,
      readAloudSpeed: readAloudSpeed ?? this.readAloudSpeed,
      readAloudVoices: readAloudVoices ?? this.readAloudVoices,
      readAloudSkipPageNumbers:
          readAloudSkipPageNumbers ?? this.readAloudSkipPageNumbers,
      readAloudKeepScreenOn:
          readAloudKeepScreenOn ?? this.readAloudKeepScreenOn,
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

/// Columns for reflowable text, and single or two-page spreads for fixed
/// layouts. [auto] lets the reader decide from the screen width.
enum ReaderColumns { auto, one, two }

/// [book] follows the publication; the others override it.
enum ReaderDirection { book, leftToRight, rightToLeft, vertical }

enum ReaderImageFilter { none, dim, invert }

enum ReaderTapZones { sides, topBottom, off }

enum ReaderOrientation { auto, portrait, landscape }

enum ReaderProgressDisplay { none, page, percent }
