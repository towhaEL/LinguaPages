import 'package:lingua_pages/domain/entity/reader/reading_session_entity.dart';

/// Tracks reading sessions for statistics and progress.
abstract interface class ReadingSessionRepository {
  Future<List<ReadingSessionEntity>> getByBookId(String bookId);

  Future<ReadingSessionEntity> save(ReadingSessionEntity session);

  /// Total time spent reading a book, in seconds.
  Future<int> totalReadingTimeForBook(String bookId);

  /// Total time spent reading across all books, in seconds.
  Future<int> totalReadingTime();
}
