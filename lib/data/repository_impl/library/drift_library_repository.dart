import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';

@LazySingleton(as: LibraryRepository)
class DriftLibraryRepository implements LibraryRepository {
  DriftLibraryRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<BookEntity>> getAll({
    LibrarySort sort = LibrarySort.recent,
  }) async {
    final books = await (_database.select(
      _database.libraryBooks,
    )..where((book) => book.isDeleted.equals(false))).get();
    final entities = books.map(_toEntity).toList();
    entities.sort(
      (a, b) => switch (sort) {
        LibrarySort.recent => (b.lastReadAt ?? b.addedAt).compareTo(
          a.lastReadAt ?? a.addedAt,
        ),
        LibrarySort.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        LibrarySort.author => (a.author ?? '').toLowerCase().compareTo(
          (b.author ?? '').toLowerCase(),
        ),
        LibrarySort.progress => b.progress.compareTo(a.progress),
      },
    );
    return entities;
  }

  @override
  Future<BookEntity?> getById(String id) async {
    final row =
        await (_database.select(_database.libraryBooks)..where(
              (book) => book.id.equals(id) & book.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<BookEntity> importDocument(BookImportRequest document) async {
    final duplicate =
        await (_database.select(_database.libraryBooks)..where(
              (book) =>
                  book.contentFingerprint.equals(document.contentFingerprint),
            ))
            .getSingleOrNull();
    if (duplicate != null) {
      if (duplicate.isDeleted) {
        final now = DateTime.now();
        await (_database.update(
          _database.libraryBooks,
        )..where((book) => book.id.equals(duplicate.id))).write(
          LibraryBooksCompanion(
            title: Value(document.title),
            author: Value(document.author),
            documentFormat: Value(document.format.name),
            sourceUri: Value(document.sourceUri),
            sourceFileName: Value(document.sourceFileName),
            coverPath: Value(document.coverPath),
            languageCode: Value(document.languageCode),
            tableOfContentsJson: Value(
              _encodeTableOfContents(document.tableOfContents),
            ),
            fileSizeBytes: Value(document.fileSizeBytes),
            addedAt: Value(now),
            isDeleted: const Value(false),
          ),
        );
        final restored = await (_database.select(
          _database.libraryBooks,
        )..where((book) => book.id.equals(duplicate.id))).getSingle();
        return _toEntity(restored);
      }
      throw DuplicateDocumentException(document.sourceFileName);
    }

    final now = DateTime.now();
    final entity = BookEntity(
      id: 'book-${now.microsecondsSinceEpoch}-${document.contentFingerprint}',
      title: document.title,
      author: document.author,
      format: document.format,
      sourceUri: document.sourceUri,
      sourceFileName: document.sourceFileName,
      contentFingerprint: document.contentFingerprint,
      coverPath: document.coverPath,
      languageCode: document.languageCode,
      tableOfContents: document.tableOfContents,
      fileSizeBytes: document.fileSizeBytes,
      addedAt: now,
    );
    await _database.into(_database.libraryBooks).insert(_toCompanion(entity));
    return entity;
  }

  @override
  Future<void> deleteBook({
    required String bookId,
    required DeleteBookData data,
  }) async {
    if (data == DeleteBookData.keep) {
      await (_database.update(_database.libraryBooks)
            ..where((book) => book.id.equals(bookId)))
          .write(const LibraryBooksCompanion(isDeleted: Value(true)));
      return;
    }

    await _database.transaction(() async {
      final vocabulary = await (_database.select(
        _database.vocabItems,
      )..where((item) => item.bookId.equals(bookId))).get();
      final vocabularyIds = vocabulary.map((item) => item.id).toList();
      if (vocabularyIds.isNotEmpty) {
        await (_database.delete(
          _database.reviewHistoryEntries,
        )..where((entry) => entry.vocabItemId.isIn(vocabularyIds))).go();
        await (_database.delete(
          _database.reviewCards,
        )..where((card) => card.vocabItemId.isIn(vocabularyIds))).go();
        await (_database.delete(
          _database.vocabItems,
        )..where((item) => item.id.isIn(vocabularyIds))).go();
      }
      await (_database.delete(
        _database.highlights,
      )..where((item) => item.bookId.equals(bookId))).go();
      await (_database.delete(
        _database.bookmarks,
      )..where((item) => item.bookId.equals(bookId))).go();
      await (_database.delete(
        _database.readingSessions,
      )..where((item) => item.bookId.equals(bookId))).go();
      await (_database.delete(
        _database.libraryBooks,
      )..where((book) => book.id.equals(bookId))).go();
    });
  }

  @override
  Future<List<BookEntity>> search(
    String query, {
    LibrarySort sort = LibrarySort.recent,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final books = await getAll(sort: sort);
    if (normalizedQuery.isEmpty) return books;
    return books
        .where(
          (book) =>
              book.title.toLowerCase().contains(normalizedQuery) ||
              (book.author?.toLowerCase().contains(normalizedQuery) ?? false),
        )
        .toList();
  }

  @override
  Future<void> updateProgress({
    required String bookId,
    required double progress,
    required DateTime lastReadAt,
    String? readingLocatorJson,
  }) async {
    if (progress < 0 || progress > 1) {
      throw ArgumentError.value(
        progress,
        'progress',
        'must be between 0 and 1',
      );
    }
    await (_database.update(
      _database.libraryBooks,
    )..where((book) => book.id.equals(bookId))).write(
      LibraryBooksCompanion(
        progress: Value(progress),
        readingLocatorJson: Value(readingLocatorJson),
        lastReadAt: Value(lastReadAt),
      ),
    );
  }

  BookEntity _toEntity(LibraryBook row) {
    return BookEntity(
      id: row.id,
      title: row.title,
      author: row.author,
      format: DocumentFormat.values.byName(row.documentFormat),
      sourceUri: row.sourceUri,
      sourceFileName: row.sourceFileName,
      contentFingerprint: row.contentFingerprint,
      coverPath: row.coverPath,
      languageCode: row.languageCode,
      tableOfContents: _decodeTableOfContents(row.tableOfContentsJson),
      fileSizeBytes: row.fileSizeBytes,
      progress: row.progress,
      readingLocatorJson: row.readingLocatorJson,
      addedAt: row.addedAt,
      lastReadAt: row.lastReadAt,
    );
  }

  LibraryBooksCompanion _toCompanion(BookEntity book) {
    return LibraryBooksCompanion.insert(
      id: book.id,
      title: book.title,
      documentFormat: book.format.name,
      sourceUri: book.sourceUri,
      sourceFileName: book.sourceFileName,
      contentFingerprint: book.contentFingerprint,
      fileSizeBytes: book.fileSizeBytes ?? 0,
      addedAt: book.addedAt,
      author: Value(book.author),
      coverPath: Value(book.coverPath),
      languageCode: Value(book.languageCode),
      tableOfContentsJson: Value(_encodeTableOfContents(book.tableOfContents)),
      progress: Value(book.progress),
      readingLocatorJson: Value(book.readingLocatorJson),
      lastReadAt: Value(book.lastReadAt),
    );
  }

  String? _encodeTableOfContents(List<String> tableOfContents) {
    if (tableOfContents.isEmpty) return null;
    return jsonEncode(tableOfContents);
  }

  List<String> _decodeTableOfContents(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}
