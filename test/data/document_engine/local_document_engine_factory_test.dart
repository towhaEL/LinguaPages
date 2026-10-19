import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/document_engine/epub/epub_document_engine.dart';
import 'package:lingua_pages/data/document_engine/local_document_engine_factory.dart';
import 'package:lingua_pages/data/document_engine/pdf/pdf_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/plain_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';

void main() {
  test('creates the matching engine for every supported format', () {
    final factory = LocalDocumentEngineFactory();

    expect(
      factory.create(_book(DocumentFormat.epub)),
      isA<EpubDocumentEngine>(),
    );
    expect(factory.create(_book(DocumentFormat.pdf)), isA<PdfDocumentEngine>());
    for (final format in [
      DocumentFormat.txt,
      DocumentFormat.markdown,
      DocumentFormat.html,
      DocumentFormat.fb2,
    ]) {
      expect(factory.create(_book(format)), isA<PlainTextDocumentEngine>());
    }
  });
}

BookEntity _book(DocumentFormat format) {
  return BookEntity(
    id: 'book-$format',
    title: 'Sample',
    format: format,
    sourceUri: '/tmp/sample.${format.name}',
    sourceFileName: 'sample.${format.name}',
    contentFingerprint: 'fingerprint-$format',
    addedAt: DateTime(2026),
  );
}
