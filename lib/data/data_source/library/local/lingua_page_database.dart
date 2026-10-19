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
// Vocabulary — Saved words
// ---------------------------------------------------------------------------

class VocabItems extends Table {
  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get lemma => text()();
  TextColumn get sourceSentence => text().withDefault(const Constant(''))();
  TextColumn get translation => text()();
  TextColumn get bookId => text().nullable().references(LibraryBooks, #id)();
  TextColumn get locatorJson => text().nullable()(); // DocumentLocator
  TextColumn get sourceLanguage => text()();
  TextColumn get targetLanguage => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Review — Spaced-repetition cards
// ---------------------------------------------------------------------------

class ReviewCards extends Table {
  TextColumn get id => text()();
  TextColumn get vocabItemId => text().references(VocabItems, #id)();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewDate => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  TextColumn get state =>
      text().withDefault(const Constant('newCard'))(); // ReviewCardState.name
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Review — Historical attempts
// ---------------------------------------------------------------------------

class ReviewHistoryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get reviewCardId => text().references(ReviewCards, #id)();
  TextColumn get vocabItemId => text().references(VocabItems, #id)();
  TextColumn get rating => text()(); // ReviewRating.name
  IntColumn get interval => integer()();
  RealColumn get easeFactor => real()();
  IntColumn get repetitions => integer()();
  DateTimeColumn get reviewedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Settings — Reader preferences and study config
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
    VocabItems,
    ReviewCards,
    ReviewHistoryEntries,
    AppSettings,
  ],
)
class LinguaPageDatabase extends _$LinguaPageDatabase {
  LinguaPageDatabase(super.executor);

  LinguaPageDatabase.defaults() : super(driftDatabase(name: 'lingua_page'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(highlights);
        await m.createTable(bookmarks);
        await m.createTable(readingSessions);
        await m.createTable(vocabItems);
        await m.createTable(reviewCards);
        await m.createTable(reviewHistoryEntries);
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
      if (from < 6) {
        await m.createTable(reviewHistoryEntries);
      }
    },
  );
}
