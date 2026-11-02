/// Manages backup creation and restore.
abstract interface class BackupRepository {
  /// Creates a backup zip and returns its file path. A non-empty
  /// [passphrase] encrypts every entry with AES.
  Future<String> createBackup({
    bool includeBookFiles = false,
    bool includeDictionaryCache = false,
    String? passphrase,
  });

  /// Merges the backup at [filePath] (zip, or a legacy JSON snapshot) into the
  /// library. Throws `BackupException` when an encrypted backup needs a
  /// passphrase or the passphrase is wrong.
  Future<BackupRestoreResult> restoreBackup(
    String filePath, {
    String? passphrase,
  });
}

class BackupRestoreResult {
  const BackupRestoreResult({
    required this.booksRestored,
    required this.highlightsRestored,
    required this.bookmarksRestored,
    required this.duplicatesSkipped,
  });

  final int booksRestored;
  final int highlightsRestored;
  final int bookmarksRestored;
  final int duplicatesSkipped;

  int get totalRestored =>
      booksRestored + highlightsRestored + bookmarksRestored;
}
