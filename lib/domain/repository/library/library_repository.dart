import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// The local-first source of truth for library metadata and reading progress.
///
/// Import, database, and cloud-sync details remain in the data layer. This
/// keeps reader and library UI independent of storage choices.
abstract class LibraryRepository {
  Future<List<BookEntity>> getAll({LibrarySort sort = LibrarySort.recent});

  Future<List<BookEntity>> search(
    String query, {
    LibrarySort sort = LibrarySort.recent,
  });

  Future<BookEntity?> getById(String id);

  Future<BookEntity> importDocument(BookImportRequest document);

  Future<void> deleteBook({
    required String bookId,
    required DeleteBookData data,
  });

  Future<void> updateProgress({
    required String bookId,
    required double progress,
    required DateTime lastReadAt,
    String? readingLocatorJson,
  });
}

enum DeleteBookData { keep, delete }

class BookImportRequest {
  const BookImportRequest({
    required this.title,
    required this.format,
    required this.sourceUri,
    required this.sourceFileName,
    required this.contentFingerprint,
    required this.fileSizeBytes,
    this.author,
    this.coverPath,
    this.languageCode,
    this.tableOfContents = const [],
  });

  final String title;
  final String? author;
  final DocumentFormat format;
  final String sourceUri;
  final String sourceFileName;
  final String contentFingerprint;
  final String? coverPath;
  final String? languageCode;
  final List<String> tableOfContents;
  final int fileSizeBytes;
}
