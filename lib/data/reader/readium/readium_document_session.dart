import 'dart:convert';
import 'dart:ui';

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';

import 'package:flutter_readium/flutter_readium.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

/// Small application-facing adapter around the Flutter Readium plugin.
///
/// Readium is deliberately kept in the data layer. The rest of the app only
/// deals with the returned publication and locator streams at the reader
/// presentation boundary, so replacing the native reader does not leak a
/// plugin dependency into the domain layer.
class ReadiumDocumentSession {
  ReadiumDocumentSession({FlutterReadium? readium})
    : _readium = readium ?? FlutterReadium();

  final FlutterReadium _readium;

  /// Bundled reading fonts registered with the EPUB navigator. Names match
  /// [ReaderFontAppearance.family].
  static final fontFamilies = [
    for (final (family, directory, file) in const [
      ('Literata', 'literata', 'Literata'),
      ('Source Serif 4', 'source_serif_4', 'SourceSerif4'),
      ('EB Garamond', 'eb_garamond', 'EBGaramond'),
    ])
      ReaderFontFamily(
        name: family,
        fallbacks: const ['serif'],
        faces: [
          for (final (suffix, style, weight) in const [
            ('Regular', ReaderFontStyle.normal, 400),
            ('Italic', ReaderFontStyle.italic, 400),
            ('Bold', ReaderFontStyle.normal, 700),
            ('BoldItalic', ReaderFontStyle.italic, 700),
          ])
            ReaderFontFace(
              asset: 'assets/fonts/$directory/$file-$suffix.ttf',
              style: style,
              weight: weight,
            ),
        ],
      ),
  ];

  Publication? publication;

  Stream<ReadiumReaderStatus> get onStatusChanged =>
      _readium.onReaderStatusChanged;

  Stream<Locator> get onLocatorChanged => _readium.onTextLocatorChanged;

  Future<Publication> open(String sourceUri) async {
    publication = await _readium.openPublication(sourceUri);
    return publication!;
  }

  Future<void> close() async {
    publication = null;
    await _readium.closePublication();
  }

  Future<bool> goToLocator(Locator locator) => _readium.goToLocator(locator);

  Future<bool> goToProgression(double progression) =>
      _readium.goToProgression(progression);

  Future<void> applySettings({
    required SettingsEntity settings,
    required DocumentFormat format,
  }) async {
    if (format == DocumentFormat.epub) {
      await _readium.setEPUBPreferences(epubPreferences(settings));
    } else if (format == DocumentFormat.pdf) {
      await _readium.setPDFPreferences(pdfPreferences(settings));
    }
  }

  /// The EPUB navigator preferences for [settings]. A null value leaves the
  /// book's own style; the navigator replaces, not merges, preferences.
  static EPUBPreferences epubPreferences(SettingsEntity settings) {
    double? unlessDefault(double value, double fallback) =>
        value == fallback ? null : value;
    final direction = settings.readerDirection;
    return EPUBPreferences(
      backgroundColor: Color(settings.readerTheme.backgroundArgb),
      textColor: Color(settings.readerTheme.textArgb),
      fontFamily: settings.readerFont.family,
      // The reader's theme, spacing, alignment and margins only take effect
      // over the book's stylesheet with publisher styles off; left on, a
      // book's hard-coded black headings vanish on dark pages.
      publisherStyles: settings.publisherStyles,
      fontSize: settings.fontSize / 18,
      lineHeight: settings.lineSpacing,
      pageMargins: settings.margin / 16,
      textAlign: _textAlignment(settings.readerTextAlignment),
      scroll: settings.readerMode == ReaderMode.continuous,
      hyphens: settings.hyphenation ? true : null,
      paragraphSpacing: unlessDefault(settings.paragraphSpacing, 0),
      paragraphIndent: unlessDefault(settings.paragraphIndent, 0),
      letterSpacing: unlessDefault(settings.letterSpacing, 0),
      wordSpacing: unlessDefault(settings.wordSpacing, 0),
      fontWeight: unlessDefault(settings.fontWeight, 1),
      columnCount: switch (settings.readerColumns) {
        ReaderColumns.auto => null,
        ReaderColumns.one => EpubColumnCount.one,
        ReaderColumns.two => EpubColumnCount.two,
      },
      spread: switch (settings.readerColumns) {
        ReaderColumns.auto => null,
        ReaderColumns.one => 'never',
        ReaderColumns.two => 'always',
      },
      readingProgression: switch (direction) {
        ReaderDirection.book => null,
        ReaderDirection.leftToRight => EpubReadingProgression.ltr,
        // Vertical CJK text pages right to left.
        ReaderDirection.rightToLeft ||
        ReaderDirection.vertical => EpubReadingProgression.rtl,
      },
      verticalText: direction == ReaderDirection.book
          ? null
          : direction == ReaderDirection.vertical,
      imageFilter: settings.readerTheme.isDarkPage
          ? switch (settings.readerImageFilter) {
              ReaderImageFilter.none => null,
              ReaderImageFilter.dim => EpubImageFilter.darken,
              ReaderImageFilter.invert => EpubImageFilter.invert,
            }
          : null,
    );
  }

  static PDFPreferences pdfPreferences(SettingsEntity settings) {
    return PDFPreferences(
      layout: settings.readerMode == ReaderMode.continuous
          ? PDFLayout.scrollVertical
          : PDFLayout.paginated,
      fit: settings.readerPdfFit == ReaderPdfFit.width
          ? PDFFit.width
          : PDFFit.page,
      spread: switch (settings.readerColumns) {
        ReaderColumns.auto => null,
        ReaderColumns.one => PDFSpread.never,
        ReaderColumns.two => PDFSpread.always,
      },
      readingProgression: switch (settings.readerDirection) {
        ReaderDirection.book || ReaderDirection.vertical => null,
        ReaderDirection.leftToRight => PDFReadingProgression.ltr,
        ReaderDirection.rightToLeft => PDFReadingProgression.rtl,
      },
    );
  }

  /// Draws [highlights] on the page, replacing the previous set. Highlights
  /// without a native Readium locator (made by a fallback engine) are skipped.
  Future<void> applyHighlights(
    List<HighlightEntity> highlights, {
    required ReaderTheme theme,
  }) {
    final decorations = <ReaderDecoration>[];
    for (final highlight in highlights) {
      final json = switch (highlight.locator) {
        EpubLocator(:final locatorJson) => locatorJson,
        PdfLocator(:final locatorJson) => locatorJson,
        TextLocator() => null,
      };
      final locator = json == null
          ? null
          : Locator.fromJson(jsonDecode(json) as Map<String, dynamic>);
      if (locator == null) continue;
      decorations.add(
        ReaderDecoration(
          id: highlight.id,
          locator: locator,
          style: ReaderDecorationStyle(
            style: DecorationStyle.highlight,
            tint: Color(highlight.color.tintArgb(darkPage: theme.isDarkPage)),
          ),
        ),
      );
    }
    return _readium.applyDecorations(_highlightGroup, decorations);
  }

  static const _highlightGroup = 'highlights';

  Future<List<TextSearchResult>> search(String query) =>
      _readium.searchInPublication(query);

  Future<void> goBackward() => _readium.goBackward();

  Future<void> goForward() => _readium.goForward();

  static TextAlign _textAlignment(ReaderTextAlignment alignment) =>
      switch (alignment) {
        ReaderTextAlignment.left => TextAlign.left,
        ReaderTextAlignment.center => TextAlign.center,
        ReaderTextAlignment.justify => TextAlign.justify,
      };
}
