import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('LinguaPageDatabase migrations', () {
    for (var fromVersion = 1; fromVersion < 7; fromVersion++) {
      test('upgrades a version $fromVersion database to version 7', () async {
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
        expect(nativeDatabase.userVersion, 7);

        expect(await database.select(database.highlights).get(), isEmpty);
        expect(await database.select(database.bookmarks).get(), isEmpty);
        expect(await database.select(database.readingSessions).get(), isEmpty);
        expect(await database.select(database.appSettings).get(), isEmpty);
        expect(_tableNames(nativeDatabase), isNot(contains('vocab_items')));
      });
    }

    test('drops study tables from v6 while keeping annotations', () async {
      final nativeDatabase = sqlite3.openInMemory();

      _createLegacySchema(nativeDatabase, 6);
      nativeDatabase.execute('''
        INSERT INTO highlights
          (id, book_id, color, selected_text, locator_json, created_at)
        VALUES ('highlight-1', 'book-1', 'yellow', 'hello', '{}', 1792406400000);
        INSERT INTO bookmarks (id, book_id, title, locator_json, created_at)
        VALUES ('bookmark-1', 'book-1', 'Page 2', '{}', 1792406400000);
        INSERT INTO reading_sessions
          (id, book_id, started_at, ended_at, start_progress, end_progress)
        VALUES ('session-1', 'book-1', 1792406400000, 1792406500000, 0, 0.1);
        INSERT INTO app_settings (key, value) VALUES ('fontSize', '20');
        INSERT INTO vocab_items
          (id, word, lemma, translation, book_id, source_language,
           target_language, created_at)
        VALUES ('vocab-1', 'book', 'book', 'libro', 'book-1', 'en', 'es',
          1792406400000);
        INSERT INTO review_cards (id, vocab_item_id, next_review_date, created_at)
        VALUES ('card-1', 'vocab-1', 1792406400000, 1792406400000);
        INSERT INTO review_history_entries
          (id, review_card_id, vocab_item_id, rating, interval, ease_factor,
           repetitions, reviewed_at)
        VALUES ('history-1', 'card-1', 'vocab-1', 'good', 1, 2.5, 1,
          1792406400000);
      ''');
      nativeDatabase.userVersion = 6;

      final database = LinguaPageDatabase(
        NativeDatabase.opened(nativeDatabase),
      );
      addTearDown(database.close);

      expect(await database.select(database.libraryBooks).get(), hasLength(1));
      expect(await database.select(database.highlights).get(), hasLength(1));
      expect(await database.select(database.bookmarks).get(), hasLength(1));
      expect(
        await database.select(database.readingSessions).get(),
        hasLength(1),
      );
      expect(
        (await database.select(database.appSettings).getSingle()).value,
        '20',
      );
      expect(nativeDatabase.userVersion, 7);
      expect(
        _tableNames(nativeDatabase),
        isNot(
          anyOf(
            contains('vocab_items'),
            contains('review_cards'),
            contains('review_history_entries'),
          ),
        ),
      );
    });

    test('preserves annotations while adding later library columns', () async {
      final nativeDatabase = sqlite3.openInMemory();

      _createLegacySchema(nativeDatabase, 2);
      nativeDatabase.execute('''
        INSERT INTO highlights
          (id, book_id, color, selected_text, locator_json, created_at)
        VALUES ('highlight-1', 'book-1', 'yellow', 'hello', '{}', 1792406400000);
      ''');
      nativeDatabase.execute('''
        INSERT INTO app_settings (key, value)
        VALUES ('fontSize', '15');
      ''');
      nativeDatabase.userVersion = 2;

      final database = LinguaPageDatabase(
        NativeDatabase.opened(nativeDatabase),
      );
      addTearDown(database.close);

      final highlights = await database.select(database.highlights).get();
      final settings = await database.select(database.appSettings).get();

      expect(highlights.single.selectedText, 'hello');
      expect(settings.single.value, '15');
      expect(nativeDatabase.userVersion, 7);
    });
  });
}

Set<String> _tableNames(Database database) => database
    .select("SELECT name FROM sqlite_master WHERE type = 'table'")
    .map((row) => row['name'] as String)
    .toSet();

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
  if (version >= 5) {
    database.execute(
      'ALTER TABLE library_books ADD COLUMN table_of_contents_json TEXT;',
    );
  }
  if (version >= 6) {
    database.execute('''
      CREATE TABLE review_history_entries (
        id TEXT NOT NULL PRIMARY KEY,
        review_card_id TEXT NOT NULL REFERENCES review_cards (id),
        vocab_item_id TEXT NOT NULL REFERENCES vocab_items (id),
        rating TEXT NOT NULL,
        interval INTEGER NOT NULL,
        ease_factor REAL NOT NULL,
        repetitions INTEGER NOT NULL,
        reviewed_at INTEGER NOT NULL
      );
    ''');
  }
}
