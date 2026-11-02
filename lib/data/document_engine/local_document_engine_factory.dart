import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/document_engine/epub/epub_document_engine.dart';
import 'package:lingua_pages/data/document_engine/pdf/pdf_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/fb2_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/html_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/markdown_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/txt_document_engine.dart';
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
      DocumentFormat.txt => TxtDocumentEngine(file),
      DocumentFormat.markdown => MarkdownDocumentEngine(file),
      DocumentFormat.html => HtmlDocumentEngine(file),
      DocumentFormat.fb2 => Fb2DocumentEngine(file),
    };
  }
}
