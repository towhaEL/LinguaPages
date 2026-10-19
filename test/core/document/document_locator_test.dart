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

    test('rejects an unknown locator type', () {
      expect(
        () => DocumentLocator.fromJson({'type': 'unknown'}),
        throwsFormatException,
      );
    });
  });
}
