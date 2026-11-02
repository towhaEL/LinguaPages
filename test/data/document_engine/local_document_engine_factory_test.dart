import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/document_engine/epub/epub_document_engine.dart';
import 'package:lingua_pages/data/document_engine/local_document_engine_factory.dart';
import 'package:lingua_pages/data/document_engine/pdf/pdf_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/fb2_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/html_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/markdown_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/txt_document_engine.dart';
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
    expect(factory.create(_book(DocumentFormat.txt)), isA<TxtDocumentEngine>());
    expect(
      factory.create(_book(DocumentFormat.markdown)),
      isA<MarkdownDocumentEngine>(),
    );
    expect(
      factory.create(_book(DocumentFormat.html)),
      isA<HtmlDocumentEngine>(),
    );
    expect(factory.create(_book(DocumentFormat.fb2)), isA<Fb2DocumentEngine>());
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
