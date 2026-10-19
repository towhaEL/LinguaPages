/// A single interval spent reading a book.
class ReadingSessionEntity {
  const ReadingSessionEntity({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.endedAt,
    required this.startProgress,
    required this.endProgress,
  });

  final String id;
  final String bookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final double startProgress;
  final double endProgress;

  int get durationSeconds => endedAt.difference(startedAt).inSeconds;
}
