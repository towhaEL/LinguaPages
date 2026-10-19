import 'dart:ui';

import 'package:flutter_readium/flutter_readium.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
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
      await _readium.setEPUBPreferences(
        EPUBPreferences(
          backgroundColor: _backgroundColor(settings.readerTheme),
          textColor: _textColor(settings.readerTheme),
          fontSize: settings.fontSize / 18,
          lineHeight: settings.lineSpacing,
          pageMargins: settings.margin / 16,
          textAlign: _textAlignment(settings.readerTextAlignment),
          scroll: settings.readerMode == ReaderMode.continuous,
        ),
      );
      return;
    }
    if (format == DocumentFormat.pdf) {
      await _readium.setPDFPreferences(
        PDFPreferences(
          layout: settings.readerMode == ReaderMode.continuous
              ? PDFLayout.scrollVertical
              : PDFLayout.paginated,
          fit: settings.readerPdfFit == ReaderPdfFit.width
              ? PDFFit.width
              : PDFFit.page,
        ),
      );
    }
  }

  Future<List<TextSearchResult>> search(String query) =>
      _readium.searchInPublication(query);

  Future<void> goBackward() => _readium.goBackward();

  Future<void> goForward() => _readium.goForward();

  Color _backgroundColor(ReaderTheme theme) => switch (theme) {
    ReaderTheme.light => const Color(0xFFFFFFFF),
    ReaderTheme.sepia => const Color(0xFFF6EFD9),
    ReaderTheme.dark => const Color(0xFF121212),
  };

  Color _textColor(ReaderTheme theme) => switch (theme) {
    ReaderTheme.light => const Color(0xFF1A1A1A),
    ReaderTheme.sepia => const Color(0xFF4A3B2A),
    ReaderTheme.dark => const Color(0xFFE9E9E9),
  };

  TextAlign _textAlignment(ReaderTextAlignment alignment) =>
      switch (alignment) {
        ReaderTextAlignment.left => TextAlign.left,
        ReaderTextAlignment.center => TextAlign.center,
        ReaderTextAlignment.justify => TextAlign.justify,
      };
}
