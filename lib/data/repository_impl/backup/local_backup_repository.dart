import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/exceptions/backup_exception.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

/// Stores the local database as a zip holding `backup.json`, optionally with
/// the book and cover files and AES encryption.
///
/// Restore also accepts the older plain JSON snapshot. Sections from older
/// backups that are no longer part of the product (vocabulary, review) are
/// ignored.
@LazySingleton(as: BackupRepository)
class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository(this._database, this._storage);

  static const _payloadName = 'backup.json';

  // Fingerprints become part of storage file names, so restored ones must be
  // plain tokens.
  static final _safeFingerprint = RegExp(r'^[A-Za-z0-9_-]+$');

  final LinguaPageDatabase _database;
  final DocumentStorageService _storage;

  @override
  Future<String> createBackup({
    bool includeBookFiles = false,
    bool includeDictionaryCache = false,
    String? passphrase,
  }) async {
    final directory = await Directory.systemTemp.createTemp(
      'linguapages-backup-',
    );
    final path = '${directory.path}/linguapages-backup.zip';
    final books = await _database.select(_database.libraryBooks).get();
    final payload = {
      'version': 2,
      'includeBookFiles': includeBookFiles,
      'books': books.map((row) => row.toJson()).toList(),
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
      'settings': (await _database.select(_database.appSettings).get())
          .map((row) => row.toJson())
          .toList(),
      if (includeDictionaryCache)
        'dictionaryCache':
            (await _database.select(_database.dictionaryCacheEntries).get())
                .map((row) => row.toJson())
                .toList(),
    };

    final encoder = ZipFileEncoder(password: _passphrase(passphrase))
      ..create(path);
    try {
      encoder.addArchiveFile(
        ArchiveFile.string(_payloadName, jsonEncode(payload)),
      );
      if (includeBookFiles) {
        for (final book in books) {
          final file = File(book.sourceUri);
          if (await file.exists()) {
            await encoder.addFile(file, _bookEntry(book));
          }
          final coverPath = book.coverPath;
          if (coverPath == null) continue;
          final cover = File(coverPath);
          if (await cover.exists()) {
            await encoder.addFile(cover, _coverEntry(book));
          }
        }
      }
    } finally {
      await encoder.close();
    }
    return path;
  }

  @override
  Future<BackupRestoreResult> restoreBackup(
    String filePath, {
    String? passphrase,
  }) async {
    final header = await _readHeader(filePath);
    final isZip = header.length >= 4 && header[0] == 0x50 && header[1] == 0x4B;
    if (!isZip) {
      final payload =
          jsonDecode(await File(filePath).readAsString())
              as Map<String, dynamic>;
      return _restore(payload, null);
    }

    // Bit 0 of the first local header's flags marks an encrypted entry; our
    // backups always start with the payload entry.
    final encrypted = header.length > 6 && header[6] & 1 != 0;
    final password = _passphrase(passphrase);
    if (encrypted && password == null) {
      throw const BackupException(BackupFailureKind.passphraseRequired);
    }

    final input = InputFileStream(filePath);
    try {
      final archive = ZipDecoder().decodeStream(input, password: password);
      final Uint8List? json;
      try {
        json = archive.findFile(_payloadName)?.readBytes();
      } on Object {
        if (encrypted) {
          throw const BackupException(BackupFailureKind.passphraseIncorrect);
        }
        rethrow;
      }
      if (json == null) {
        throw const FormatException('The backup has no backup.json entry.');
      }
      final payload = jsonDecode(utf8.decode(json)) as Map<String, dynamic>;
      return await _restore(payload, archive);
    } finally {
      await input.close();
    }
  }

  Future<BackupRestoreResult> _restore(
    Map<String, dynamic> payload,
    Archive? archive,
  ) {
    return _database.transaction(() async {
      var booksRestored = 0;
      var highlightsRestored = 0;
      var bookmarksRestored = 0;
      var duplicatesSkipped = 0;
      // The same file imported on two devices gets two ids; annotations from
      // the backup follow the book already in this library.
      final bookIds = <String, String>{};

      for (final raw in _records(payload, 'books')) {
        var row = LibraryBook.fromJson(raw);
        final existing =
            await (_database.select(_database.libraryBooks)
                  ..where(
                    (book) =>
                        book.id.equals(row.id) |
                        book.contentFingerprint.equals(row.contentFingerprint),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (existing != null) {
          bookIds[row.id] = existing.id;
          duplicatesSkipped++;
          continue;
        }
        if (archive != null) row = await _restoreFiles(row, archive);
        await _database
            .into(_database.libraryBooks)
            .insert(row.toCompanion(false));
        booksRestored++;
      }

      String bookId(String id) => bookIds[id] ?? id;

      for (final raw in _records(payload, 'highlights')) {
        final row = Highlight.fromJson(raw);
        final exists = await (_database.select(
          _database.highlights,
        )..where((item) => item.id.equals(row.id))).getSingleOrNull();
        if (exists != null) {
          duplicatesSkipped++;
          continue;
        }
        await _database
            .into(_database.highlights)
            .insert(
              row.copyWith(bookId: bookId(row.bookId)).toCompanion(false),
            );
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
        await _database
            .into(_database.bookmarks)
            .insert(
              row.copyWith(bookId: bookId(row.bookId)).toCompanion(false),
            );
        bookmarksRestored++;
      }

      for (final raw in _records(payload, 'readingSessions')) {
        final row = ReadingSession.fromJson(raw);
        await _database
            .into(_database.readingSessions)
            .insertOnConflictUpdate(
              row.copyWith(bookId: bookId(row.bookId)).toCompanion(false),
            );
      }

      for (final raw in _records(payload, 'settings')) {
        final row = AppSetting.fromJson(raw);
        await _database
            .into(_database.appSettings)
            .insertOnConflictUpdate(row.toCompanion(false));
      }

      // Lookups already cached on this device are newer; keep them.
      for (final raw in _records(payload, 'dictionaryCache')) {
        final row = DictionaryCacheEntry.fromJson(raw);
        await _database
            .into(_database.dictionaryCacheEntries)
            .insert(row.toCompanion(false), mode: InsertMode.insertOrIgnore);
      }

      return BackupRestoreResult(
        booksRestored: booksRestored,
        highlightsRestored: highlightsRestored,
        bookmarksRestored: bookmarksRestored,
        duplicatesSkipped: duplicatesSkipped,
      );
    });
  }

  /// Copies the book and cover from [archive] into app storage and points
  /// [row] at the copies. Books without files keep their stored paths.
  Future<LibraryBook> _restoreFiles(LibraryBook row, Archive archive) async {
    if (!_safeFingerprint.hasMatch(row.contentFingerprint)) return row;
    var restored = row;
    final book = archive.findFile(_bookEntry(row))?.readBytes();
    if (book != null) {
      restored = restored.copyWith(
        sourceUri: await _storage.store(
          sourceFileName: row.sourceFileName,
          contentFingerprint: row.contentFingerprint,
          bytes: book,
        ),
      );
    }
    final cover = archive.findFile(_coverEntry(row))?.readBytes();
    if (cover != null) {
      restored = restored.copyWith(
        coverPath: Value(
          await _storage.storeCover(
            contentFingerprint: row.contentFingerprint,
            sourceFileName: _coverFileName(row),
            bytes: cover,
          ),
        ),
      );
    }
    return restored;
  }

  String _bookEntry(LibraryBook book) =>
      'books/${book.contentFingerprint}/${book.sourceFileName}';

  String _coverEntry(LibraryBook book) =>
      'covers/${book.contentFingerprint}/${_coverFileName(book)}';

  String _coverFileName(LibraryBook book) {
    final path = book.coverPath ?? '';
    final dot = path.lastIndexOf('.');
    final extension = dot < 0 ? 'bin' : path.substring(dot + 1);
    return 'cover.$extension';
  }

  String? _passphrase(String? value) =>
      value == null || value.isEmpty ? null : value;

  Future<List<int>> _readHeader(String filePath) async {
    final file = await File(filePath).open();
    try {
      return await file.read(8);
    } finally {
      await file.close();
    }
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
