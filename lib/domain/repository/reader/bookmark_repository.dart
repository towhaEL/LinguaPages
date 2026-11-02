import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';

/// Manages user-created bookmarks across all books.
abstract interface class BookmarkRepository {
  Future<List<BookmarkEntity>> getByBookId(String bookId);

  /// Every bookmark in the library, newest first.
  Future<List<BookmarkEntity>> getAll();

  Future<BookmarkEntity> create(BookmarkEntity bookmark);

  Future<void> delete(String bookmarkId);

  Future<int> countByBookId(String bookId);
}
