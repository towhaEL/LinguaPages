import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/document_engine/epub/epub_document_engine.dart';
import 'package:lingua_pages/data/document_engine/pdf/pdf_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/plain_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:lingua_pages/domain/service/document_engine_factory.dart';

@LazySingleton(as: DocumentEngineFactory)
class LocalDocumentEngineFactory implements DocumentEngineFactory {
  @override
  DocumentEngine create(BookEntity book) {
    final file = File(book.sourceUri);
    return switch (book.format) {
      DocumentFormat.epub => EpubDocumentEngine(file),
      DocumentFormat.pdf => PdfDocumentEngine(file),
      DocumentFormat.txt ||
      DocumentFormat.markdown ||
      DocumentFormat.html ||
      DocumentFormat.fb2 => PlainTextDocumentEngine(
        file: file,
        format: book.format,
      ),
    };
  }
}
