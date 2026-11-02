import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// The local-first source of truth for library metadata and reading progress.
///
/// Import, database, and cloud-sync details remain in the data layer. This
/// keeps reader and library UI independent of storage choices.
abstract class LibraryRepository {
  /// Fires after books or collections change, by this repository or
  /// another writer such as a backup restore.
  Stream<void> get changes;

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

  /// Books in Trash, most recently deleted first.
  Future<List<BookEntity>> getTrash();

  /// Hides the book in Trash; its file and annotations stay.
  Future<void> moveToTrash(String bookId);

  Future<void> restoreFromTrash(String bookId);

  /// Trashed books deleted before [cutoff].
  Future<List<BookEntity>> trashedBefore(DateTime cutoff);

  Future<void> setShelf({required String bookId, BookShelf? shelf});

  Future<void> setFavorite({required String bookId, required bool favorite});

  Future<void> updateDetails({
    required String bookId,
    required BookDetails details,
  });

  /// Saves the reading position. Starting a To read book moves it on to
  /// the progress-based shelf.
  Future<void> updateProgress({
    required String bookId,
    required double progress,
    required DateTime lastReadAt,
    String? readingLocatorJson,
  });
}

/// Permanent deletion: [keep] archives the annotations so re-importing the
/// file brings them back; [delete] removes them too.
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
    this.series,
    this.seriesIndex,
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
  final String? series;
  final double? seriesIndex;
}
