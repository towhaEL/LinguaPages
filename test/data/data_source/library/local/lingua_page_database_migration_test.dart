import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('LinguaPageDatabase migrations', () {
    for (var fromVersion = 1; fromVersion < 5; fromVersion++) {
      test('upgrades a version $fromVersion database to version 6', () async {
        final nativeDatabase = sqlite3.openInMemory();

        _createLegacySchema(nativeDatabase, fromVersion);
        nativeDatabase.userVersion = fromVersion;

        final database = LinguaPageDatabase(
          NativeDatabase.opened(nativeDatabase),
        );
        addTearDown(database.close);

        final book = await database.select(database.libraryBooks).getSingle();

        expect(book.title, 'Legacy book');
        expect(book.readingLocatorJson, isNull);
        expect(book.tableOfContentsJson, isNull);
        expect(book.isDeleted, isFalse);
        expect(nativeDatabase.userVersion, 6);

        expect(await database.select(database.highlights).get(), isEmpty);
        expect(await database.select(database.bookmarks).get(), isEmpty);
        expect(await database.select(database.readingSessions).get(), isEmpty);
        expect(await database.select(database.vocabItems).get(), isEmpty);
        expect(await database.select(database.reviewCards).get(), isEmpty);
        expect(
          await database.select(database.reviewHistoryEntries).get(),
          isEmpty,
        );
        expect(await database.select(database.appSettings).get(), isEmpty);
      });
    }

    test('preserves study data while adding later library columns', () async {
      final nativeDatabase = sqlite3.openInMemory();

      _createLegacySchema(nativeDatabase, 2);
      nativeDatabase.execute('''
        INSERT INTO highlights
          (id, book_id, color, selected_text, locator_json, created_at)
        VALUES ('highlight-1', 'book-1', 'yellow', 'hola', '{}', 1792406400000);
      ''');
      nativeDatabase.execute('''
        INSERT INTO app_settings (key, value)
        VALUES ('dailyNewCardLimit', '15');
      ''');
      nativeDatabase.userVersion = 2;

      final database = LinguaPageDatabase(
        NativeDatabase.opened(nativeDatabase),
      );
      addTearDown(database.close);

      final highlights = await database.select(database.highlights).get();
      final settings = await database.select(database.appSettings).get();

      expect(highlights.single.selectedText, 'hola');
      expect(settings.single.value, '15');
      expect(nativeDatabase.userVersion, 6);
    });
  });
}

void _createLegacySchema(Database database, int version) {
  database.execute('PRAGMA foreign_keys = ON;');
  database.execute('''
    CREATE TABLE library_books (
      id TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      author TEXT,
      document_format TEXT NOT NULL,
      source_uri TEXT NOT NULL,
      source_file_name TEXT NOT NULL,
      content_fingerprint TEXT NOT NULL UNIQUE,
      cover_path TEXT,
      language_code TEXT,
      file_size_bytes INTEGER NOT NULL,
      progress REAL NOT NULL DEFAULT 0.0,
      added_at INTEGER NOT NULL,
      last_read_at INTEGER
    );
  ''');
  database.execute('''
    INSERT INTO library_books
      (id, title, document_format, source_uri, source_file_name,
       content_fingerprint, file_size_bytes, added_at)
    VALUES ('book-1', 'Legacy book', 'txt', '/books/legacy.txt',
      'legacy.txt', 'legacy-fingerprint', 12, 1792406400000);
  ''');

  if (version < 2) return;

  database.execute('''
    CREATE TABLE highlights (
      id TEXT NOT NULL PRIMARY KEY,
      book_id TEXT NOT NULL REFERENCES library_books (id),
      color TEXT NOT NULL,
      selected_text TEXT NOT NULL,
      locator_json TEXT NOT NULL,
      note TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER
    );
    CREATE TABLE bookmarks (
      id TEXT NOT NULL PRIMARY KEY,
      book_id TEXT NOT NULL REFERENCES library_books (id),
      title TEXT NOT NULL,
      locator_json TEXT NOT NULL,
      created_at INTEGER NOT NULL
    );
    CREATE TABLE reading_sessions (
      id TEXT NOT NULL PRIMARY KEY,
      book_id TEXT NOT NULL REFERENCES library_books (id),
      started_at INTEGER NOT NULL,
      ended_at INTEGER NOT NULL,
      start_progress REAL NOT NULL,
      end_progress REAL NOT NULL
    );
    CREATE TABLE vocab_items (
      id TEXT NOT NULL PRIMARY KEY,
      word TEXT NOT NULL,
      lemma TEXT NOT NULL,
      source_sentence TEXT NOT NULL DEFAULT '',
      translation TEXT NOT NULL,
      book_id TEXT REFERENCES library_books (id),
      locator_json TEXT,
      source_language TEXT NOT NULL,
      target_language TEXT NOT NULL,
      notes TEXT,
      created_at INTEGER NOT NULL
    );
    CREATE TABLE review_cards (
      id TEXT NOT NULL PRIMARY KEY,
      vocab_item_id TEXT NOT NULL REFERENCES vocab_items (id),
      interval INTEGER NOT NULL DEFAULT 0,
      ease_factor REAL NOT NULL DEFAULT 2.5,
      repetitions INTEGER NOT NULL DEFAULT 0,
      next_review_date INTEGER NOT NULL,
      last_reviewed_at INTEGER,
      state TEXT NOT NULL DEFAULT 'newCard',
      created_at INTEGER NOT NULL
    );
    CREATE TABLE app_settings (
      key TEXT NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    );
  ''');

  if (version >= 3) {
    database.execute(
      'ALTER TABLE library_books ADD COLUMN reading_locator_json TEXT;',
    );
  }
  if (version >= 4) {
    database.execute(
      'ALTER TABLE library_books ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;',
    );
  }
}
