import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/reader/readium/readium_document_session.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

void main() {
  test('default settings leave the book style alone', () {
    final preferences = ReadiumDocumentSession.epubPreferences(
      const SettingsEntity(),
    );

    expect(preferences.publisherStyles, isFalse);
    expect(preferences.hyphens, isNull);
    expect(preferences.paragraphSpacing, isNull);
    expect(preferences.paragraphIndent, isNull);
    expect(preferences.letterSpacing, isNull);
    expect(preferences.wordSpacing, isNull);
    expect(preferences.fontWeight, isNull);
    expect(preferences.columnCount, isNull);
    expect(preferences.readingProgression, isNull);
    expect(preferences.verticalText, isNull);
    expect(preferences.imageFilter, isNull);
  });

  test('maps comfort settings onto EPUB preferences', () {
    final preferences = ReadiumDocumentSession.epubPreferences(
      const SettingsEntity(
        readerTheme: ReaderTheme.dark,
        hyphenation: true,
        paragraphSpacing: .5,
        paragraphIndent: 1.5,
        letterSpacing: .1,
        wordSpacing: .3,
        fontWeight: 1.5,
        publisherStyles: true,
        readerColumns: ReaderColumns.two,
        readerDirection: ReaderDirection.vertical,
        readerImageFilter: ReaderImageFilter.invert,
      ),
    );

    expect(preferences.hyphens, isTrue);
    expect(preferences.paragraphSpacing, .5);
    expect(preferences.paragraphIndent, 1.5);
    expect(preferences.letterSpacing, .1);
    expect(preferences.wordSpacing, .3);
    expect(preferences.fontWeight, 1.5);
    expect(preferences.publisherStyles, isTrue);
    expect(preferences.columnCount, EpubColumnCount.two);
    expect(preferences.spread, 'always');
    expect(preferences.readingProgression, EpubReadingProgression.rtl);
    expect(preferences.verticalText, isTrue);
    expect(preferences.imageFilter, EpubImageFilter.invert);
  });

  test('image filter only applies on dark pages', () {
    final preferences = ReadiumDocumentSession.epubPreferences(
      const SettingsEntity(readerImageFilter: ReaderImageFilter.dim),
    );

    expect(preferences.imageFilter, isNull);
  });

  test('maps columns and direction onto PDF preferences', () {
    final preferences = ReadiumDocumentSession.pdfPreferences(
      const SettingsEntity(
        readerColumns: ReaderColumns.one,
        readerDirection: ReaderDirection.rightToLeft,
      ),
    );

    expect(preferences.spread, PDFSpread.never);
    expect(preferences.readingProgression, PDFReadingProgression.rtl);
  });
}
