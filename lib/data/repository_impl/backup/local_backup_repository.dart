import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';

/// Stores a portable JSON snapshot of the local database.
///
/// Book binaries are intentionally not copied yet. The snapshot contains
/// metadata and all user-created study data, which keeps backup/restore useful
/// while the app-private document storage contract is being finalized.
@LazySingleton(as: BackupRepository)
class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<String> createBackup({bool includeBookFiles = false}) async {
    final directory = await Directory.systemTemp.createTemp(
      'linguapages-backup-',
    );
    final file = File('${directory.path}/linguapages-backup.json');
    final payload = {
      'version': 1,
      'includeBookFiles': includeBookFiles,
      'books': (await _database.select(_database.libraryBooks).get())
          .map((row) => row.toJson())
          .toList(),
      'highlights': (await _database.select(_database.highlights).get())
          .map((row) => row.toJson())
          .toList(),
      'bookmarks': (await _database.select(_database.bookmarks).get())
          .map((row) => row.toJson())
          .toList(),
      'readingSessions':
          (await _database.select(_database.readingSessions).get())
              .map((row) => row.toJson())
              .toList(),
      'vocabItems': (await _database.select(_database.vocabItems).get())
          .map((row) => row.toJson())
          .toList(),
      'reviewCards': (await _database.select(_database.reviewCards).get())
          .map((row) => row.toJson())
          .toList(),
      'settings': (await _database.select(_database.appSettings).get())
          .map((row) => row.toJson())
          .toList(),
    };
    await file.writeAsString(jsonEncode(payload));
    return file.path;
  }

  @override
  Future<BackupRestoreResult> restoreBackup(String filePath) async {
    final payload =
        jsonDecode(await File(filePath).readAsString()) as Map<String, dynamic>;
    var booksRestored = 0;
    var highlightsRestored = 0;
    var bookmarksRestored = 0;
    var vocabItemsRestored = 0;
    var reviewCardsRestored = 0;
    var duplicatesSkipped = 0;

    for (final raw in _records(payload, 'books')) {
      final row = LibraryBook.fromJson(raw);
      final exists = await (_database.select(
        _database.libraryBooks,
      )..where((book) => book.id.equals(row.id))).getSingleOrNull();
      if (exists != null) {
        duplicatesSkipped++;
        continue;
      }
      await _database
          .into(_database.libraryBooks)
          .insert(row.toCompanion(false));
      booksRestored++;
    }

    for (final raw in _records(payload, 'highlights')) {
      final row = Highlight.fromJson(raw);
      final exists = await (_database.select(
        _database.highlights,
      )..where((item) => item.id.equals(row.id))).getSingleOrNull();
      if (exists != null) {
        duplicatesSkipped++;
        continue;
      }
      await _database.into(_database.highlights).insert(row.toCompanion(false));
      highlightsRestored++;
    }

    for (final raw in _records(payload, 'bookmarks')) {
      final row = Bookmark.fromJson(raw);
      final exists = await (_database.select(
        _database.bookmarks,
      )..where((item) => item.id.equals(row.id))).getSingleOrNull();
      if (exists != null) {
        duplicatesSkipped++;
        continue;
      }
      await _database.into(_database.bookmarks).insert(row.toCompanion(false));
      bookmarksRestored++;
    }

    for (final raw in _records(payload, 'readingSessions')) {
      final row = ReadingSession.fromJson(raw);
      await _database
          .into(_database.readingSessions)
          .insertOnConflictUpdate(row.toCompanion(false));
    }

    for (final raw in _records(payload, 'vocabItems')) {
      final row = VocabItem.fromJson(raw);
      final exists = await (_database.select(
        _database.vocabItems,
      )..where((item) => item.id.equals(row.id))).getSingleOrNull();
      if (exists != null) {
        duplicatesSkipped++;
        continue;
      }
      await _database.into(_database.vocabItems).insert(row.toCompanion(false));
      vocabItemsRestored++;
    }

    for (final raw in _records(payload, 'reviewCards')) {
      final row = ReviewCard.fromJson(raw);
      final exists = await (_database.select(
        _database.reviewCards,
      )..where((item) => item.id.equals(row.id))).getSingleOrNull();
      if (exists != null) {
        duplicatesSkipped++;
        continue;
      }
      await _database
          .into(_database.reviewCards)
          .insert(row.toCompanion(false));
      reviewCardsRestored++;
    }

    for (final raw in _records(payload, 'settings')) {
      final row = AppSetting.fromJson(raw);
      await _database
          .into(_database.appSettings)
          .insertOnConflictUpdate(row.toCompanion(false));
    }

    return BackupRestoreResult(
      booksRestored: booksRestored,
      highlightsRestored: highlightsRestored,
      bookmarksRestored: bookmarksRestored,
      vocabItemsRestored: vocabItemsRestored,
      reviewCardsRestored: reviewCardsRestored,
      duplicatesSkipped: duplicatesSkipped,
    );
  }

  List<Map<String, dynamic>> _records(
    Map<String, dynamic> payload,
    String key,
  ) {
    final value = payload[key];
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((record) => Map<String, dynamic>.from(record))
        .toList();
  }
}
