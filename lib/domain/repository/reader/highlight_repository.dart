import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';

/// Manages user-created highlights across all books.
abstract interface class HighlightRepository {
  Future<List<HighlightEntity>> getByBookId(String bookId);

  Future<HighlightEntity> create(HighlightEntity highlight);

  Future<void> update(HighlightEntity highlight);

  Future<void> delete(String highlightId);

  Future<int> countByBookId(String bookId);
}
