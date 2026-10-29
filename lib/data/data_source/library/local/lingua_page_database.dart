import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'lingua_page_database.g.dart';

// ---------------------------------------------------------------------------
// Library
// ---------------------------------------------------------------------------

class LibraryBooks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get documentFormat => text()();
  TextColumn get sourceUri => text()();
  TextColumn get sourceFileName => text()();
  TextColumn get contentFingerprint => text().unique()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get languageCode => text().nullable()();
  TextColumn get tableOfContentsJson => text().nullable()();
  IntColumn get fileSizeBytes => integer()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get readingLocatorJson => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastReadAt => dateTime().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Reader — Highlights
// ---------------------------------------------------------------------------

class Highlights extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(LibraryBooks, #id)();
  TextColumn get color => text()(); // HighlightColor.name
  TextColumn get selectedText => text()();
  TextColumn get locatorJson => text()(); // DocumentLocator serialized
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Reader — Bookmarks
// ---------------------------------------------------------------------------

class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(LibraryBooks, #id)();
  TextColumn get title => text()();
  TextColumn get locatorJson => text()(); // DocumentLocator serialized
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Reader — Reading sessions
// ---------------------------------------------------------------------------

class ReadingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text().references(LibraryBooks, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  RealColumn get startProgress => real()();
  RealColumn get endProgress => real()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Settings — Reader preferences
// ---------------------------------------------------------------------------

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    LibraryBooks,
    Highlights,
    Bookmarks,
    ReadingSessions,
    AppSettings,
  ],
)
class LinguaPageDatabase extends _$LinguaPageDatabase {
  LinguaPageDatabase(super.executor);

  LinguaPageDatabase.defaults() : super(driftDatabase(name: 'lingua_page'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(highlights);
        await m.createTable(bookmarks);
        await m.createTable(readingSessions);
        await m.createTable(appSettings);
      }
      if (from < 3) {
        await m.addColumn(libraryBooks, libraryBooks.readingLocatorJson);
      }
      if (from < 4) {
        await m.addColumn(libraryBooks, libraryBooks.isDeleted);
      }
      if (from < 5) {
        await m.addColumn(libraryBooks, libraryBooks.tableOfContentsJson);
      }
      if (from < 7) {
        // Language-learning tables were removed from the product in v7.
        await customStatement('DROP TABLE IF EXISTS review_history_entries');
        await customStatement('DROP TABLE IF EXISTS review_cards');
        await customStatement('DROP TABLE IF EXISTS vocab_items');
      }
    },
  );
}
