import 'dart:typed_data';

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Domain contract for every supported document format.
///
/// Concrete readers must live outside the domain layer. This keeps Flutter
/// plugins and format-specific libraries replaceable.
abstract interface class DocumentEngine {
  Future<DocumentInfo> open();

  /// The open document's readable text, which text locators index into.
  String get text;

  Future<void> close();

  Future<List<String>> tableOfContents();

  Future<List<DocumentTocEntry>> tableOfContentsEntries();

  Future<int?> pageIndexForLocator(DocumentLocator locator);

  /// The first text offset on reflowable page [pageIndex] of the open
  /// document. Fixed layouts have no text offsets and return 0.
  int pageStartOffset(int pageIndex);

  /// The reflowable page holding text [offset] of the open document. Fixed
  /// layouts return 0.
  int pageIndexForOffset(int offset);

  Future<Uint8List?> renderPage(int pageIndex);

  Future<Uint8List?> renderPageThumbnail(int pageIndex) =>
      renderPage(pageIndex);

  Future<String?> pageText(int pageIndex);

  Future<List<DocumentSearchResult>> search(String query);

  Future<DocumentTextSelection> resolveSelection({
    required int start,
    required int end,
  });
}
