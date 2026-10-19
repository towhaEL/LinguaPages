import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/entity/reader/reading_session_entity.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/domain/repository/reader/reading_session_repository.dart';

@LazySingleton(as: HighlightRepository)
class DriftHighlightRepository implements HighlightRepository {
  DriftHighlightRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<HighlightEntity>> getByBookId(String bookId) async {
    final rows =
        await (_database.select(_database.highlights)
              ..where((highlight) => highlight.bookId.equals(bookId))
              ..orderBy([(highlight) => OrderingTerm.asc(highlight.createdAt)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<HighlightEntity> create(HighlightEntity highlight) async {
    await _database.into(_database.highlights).insert(_toCompanion(highlight));
    return highlight;
  }

  @override
  Future<void> update(HighlightEntity highlight) async {
    await (_database.update(_database.highlights)
          ..where((row) => row.id.equals(highlight.id)))
        .write(_toCompanion(highlight));
  }

  @override
  Future<void> delete(String highlightId) async {
    await (_database.delete(
      _database.highlights,
    )..where((row) => row.id.equals(highlightId))).go();
  }

  @override
  Future<int> countByBookId(String bookId) async {
    final rows = await (_database.select(
      _database.highlights,
    )..where((highlight) => highlight.bookId.equals(bookId))).get();
    return rows.length;
  }

  HighlightEntity _toEntity(Highlight row) => HighlightEntity(
    id: row.id,
    bookId: row.bookId,
    selectedText: row.selectedText,
    locator: _decodeLocator(row.locatorJson),
    color: HighlightColor.values.byName(row.color),
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  HighlightsCompanion _toCompanion(HighlightEntity highlight) {
    return HighlightsCompanion.insert(
      id: highlight.id,
      bookId: highlight.bookId,
      selectedText: highlight.selectedText,
      locatorJson: jsonEncode(highlight.locator.toJson()),
      color: highlight.color.name,
      note: Value(highlight.note),
      createdAt: highlight.createdAt,
      updatedAt: Value(highlight.updatedAt),
    );
  }
}

@LazySingleton(as: BookmarkRepository)
class DriftBookmarkRepository implements BookmarkRepository {
  DriftBookmarkRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<BookmarkEntity>> getByBookId(String bookId) async {
    final rows =
        await (_database.select(_database.bookmarks)
              ..where((bookmark) => bookmark.bookId.equals(bookId))
              ..orderBy([(bookmark) => OrderingTerm.asc(bookmark.createdAt)]))
            .get();
    return rows
        .map(
          (row) => BookmarkEntity(
            id: row.id,
            bookId: row.bookId,
            title: row.title,
            locator: _decodeLocator(row.locatorJson),
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<BookmarkEntity> create(BookmarkEntity bookmark) async {
    await _database
        .into(_database.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            id: bookmark.id,
            bookId: bookmark.bookId,
            title: bookmark.title,
            locatorJson: jsonEncode(bookmark.locator.toJson()),
            createdAt: bookmark.createdAt,
          ),
        );
    return bookmark;
  }

  @override
  Future<void> delete(String bookmarkId) async {
    await (_database.delete(
      _database.bookmarks,
    )..where((row) => row.id.equals(bookmarkId))).go();
  }

  @override
  Future<int> countByBookId(String bookId) async {
    final rows = await (_database.select(
      _database.bookmarks,
    )..where((bookmark) => bookmark.bookId.equals(bookId))).get();
    return rows.length;
  }
}

@LazySingleton(as: ReadingSessionRepository)
class DriftReadingSessionRepository implements ReadingSessionRepository {
  DriftReadingSessionRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<ReadingSessionEntity>> getByBookId(String bookId) async {
    final rows =
        await (_database.select(_database.readingSessions)
              ..where((session) => session.bookId.equals(bookId))
              ..orderBy([(session) => OrderingTerm.desc(session.startedAt)]))
            .get();
    return rows
        .map(
          (row) => ReadingSessionEntity(
            id: row.id,
            bookId: row.bookId,
            startedAt: row.startedAt,
            endedAt: row.endedAt,
            startProgress: row.startProgress,
            endProgress: row.endProgress,
          ),
        )
        .toList();
  }

  @override
  Future<ReadingSessionEntity> save(ReadingSessionEntity session) async {
    await _database
        .into(_database.readingSessions)
        .insertOnConflictUpdate(
          ReadingSessionsCompanion.insert(
            id: session.id,
            bookId: session.bookId,
            startedAt: session.startedAt,
            endedAt: session.endedAt,
            startProgress: session.startProgress,
            endProgress: session.endProgress,
          ),
        );
    return session;
  }

  @override
  Future<int> totalReadingTimeForBook(String bookId) async {
    final sessions = await getByBookId(bookId);
    return sessions.fold<int>(
      0,
      (total, session) => total + session.durationSeconds,
    );
  }

  @override
  Future<int> totalReadingTime() async {
    final sessions = await _database.select(_database.readingSessions).get();
    return sessions.fold<int>(
      0,
      (total, session) =>
          total + session.endedAt.difference(session.startedAt).inSeconds,
    );
  }
}

DocumentLocator _decodeLocator(String value) {
  return DocumentLocator.fromJson(jsonDecode(value) as Map<String, dynamic>);
}
