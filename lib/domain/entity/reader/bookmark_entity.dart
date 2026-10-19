import 'package:lingua_pages/core/document/document_locator.dart';

/// A named position a reader can return to in a book.
class BookmarkEntity {
  const BookmarkEntity({
    required this.id,
    required this.bookId,
    required this.title,
    required this.locator,
    required this.createdAt,
  });

  final String id;
  final String bookId;
  final String title;
  final DocumentLocator locator;
  final DateTime createdAt;
}
