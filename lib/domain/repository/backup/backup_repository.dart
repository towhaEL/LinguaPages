/// Manages backup creation and restore.
abstract interface class BackupRepository {
  /// Creates a backup archive and returns its file path.
  Future<String> createBackup({bool includeBookFiles = false});

  /// Restores from a backup archive at [filePath].
  /// Returns the count of items restored (books, highlights, vocab, etc.).
  Future<BackupRestoreResult> restoreBackup(String filePath);
}

class BackupRestoreResult {
  const BackupRestoreResult({
    required this.booksRestored,
    required this.highlightsRestored,
    required this.bookmarksRestored,
    required this.vocabItemsRestored,
    required this.reviewCardsRestored,
    required this.duplicatesSkipped,
  });

  final int booksRestored;
  final int highlightsRestored;
  final int bookmarksRestored;
  final int vocabItemsRestored;
  final int reviewCardsRestored;
  final int duplicatesSkipped;

  int get totalRestored =>
      booksRestored +
      highlightsRestored +
      bookmarksRestored +
      vocabItemsRestored +
      reviewCardsRestored;
}
