import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentLocator', () {
    test('round-trips an EPUB CFI', () {
      const locator = EpubLocator(cfi: 'epubcfi(/6/4[chapter]!/4/2)');

      final restored = DocumentLocator.fromJson(locator.toJson());

      expect(restored, isA<EpubLocator>());
      expect((restored as EpubLocator).cfi, locator.cfi);
    });

    test('round-trips a PDF page and optional text offset', () {
      const locator = PdfLocator(page: 12, textOffset: 48);

      final restored = DocumentLocator.fromJson(locator.toJson());

      expect(restored, isA<PdfLocator>());
      expect((restored as PdfLocator).page, 12);
      expect(restored.textOffset, 48);
    });

    test('preserves an optional native Readium locator payload', () {
      const epubLocator = EpubLocator(
        cfi: 'chapter.xhtml',
        locatorJson: '{"href":"chapter.xhtml","type":"text/html"}',
      );
      const pdfLocator = PdfLocator(
        page: 3,
        locatorJson: '{"href":"3","type":"application/pdf"}',
      );

      final restoredEpub = DocumentLocator.fromJson(epubLocator.toJson());
      final restoredPdf = DocumentLocator.fromJson(pdfLocator.toJson());

      expect(
        (restoredEpub as EpubLocator).locatorJson,
        epubLocator.locatorJson,
      );
      expect((restoredPdf as PdfLocator).locatorJson, pdfLocator.locatorJson);
    });

    test('rejects an unknown locator type', () {
      expect(
        () => DocumentLocator.fromJson({'type': 'unknown'}),
        throwsFormatException,
      );
    });
  });
}
