import 'dart:typed_data';

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Domain contract for every supported document format.
///
/// Concrete readers must live outside the domain layer. This keeps Flutter
/// plugins and format-specific libraries replaceable.
abstract interface class DocumentEngine {
  Future<DocumentInfo> open();

  Future<void> close();

  Future<List<String>> tableOfContents();

  Future<List<DocumentTocEntry>> tableOfContentsEntries();

  Future<int?> pageIndexForLocator(DocumentLocator locator);

  Future<Uint8List?> renderPage(int pageIndex);

  Future<Uint8List?> renderPageThumbnail(int pageIndex) =>
      renderPage(pageIndex);

  Future<List<DocumentSearchResult>> search(String query);

  Future<DocumentTextSelection> resolveSelection({
    required int start,
    required int end,
  });
}
