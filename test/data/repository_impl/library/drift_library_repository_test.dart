import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/library/drift_library_repository.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';

void main() {
  group('DriftLibraryRepository', () {
    late LinguaPageDatabase database;
    late DriftLibraryRepository repository;

    setUp(() {
      database = LinguaPageDatabase(NativeDatabase.memory());
      repository = DriftLibraryRepository(database);
    });

    tearDown(() => database.close());

    test('persists imported document metadata', () async {
      final importedBook = await repository.importDocument(_document());
      final storedBook = await repository.getById(importedBook.id);

      expect(storedBook?.title, 'Don Quijote');
      expect(storedBook?.format, DocumentFormat.epub);
      expect(storedBook?.sourceUri, '/storage/books/don-quijote.epub');
      expect(storedBook?.fileSizeBytes, 2048);
      expect(storedBook?.author, 'Miguel de Cervantes');
      expect(storedBook?.languageCode, 'es');
      expect(storedBook?.coverPath, '/covers/don-quijote.png');
      expect(storedBook?.tableOfContents, ['Chapter One', 'Chapter Two']);
    });

    test('rejects the same document fingerprint twice', () async {
      await repository.importDocument(_document());

      await expectLater(
        repository.importDocument(_document()),
        throwsA(isA<DuplicateDocumentException>()),
      );
    });

    test('updates reading progress and searches imported books', () async {
      final importedBook = await repository.importDocument(_document());
      final lastReadAt = DateTime(2026, 10, 19);

      await repository.updateProgress(
        bookId: importedBook.id,
        progress: .45,
        lastReadAt: lastReadAt,
        readingLocatorJson: '{"href":"chapter.xhtml","type":"text/html"}',
      );

      final results = await repository.search('quijote');
      expect(results.single.progress, .45);
      expect(
        results.single.readingLocatorJson,
        '{"href":"chapter.xhtml","type":"text/html"}',
      );
      expect(results.single.lastReadAt, lastReadAt);
    });

    test('sorts books by progress from most to least complete', () async {
      final completedBook = await repository.importDocument(
        _document(title: 'Completed', fingerprint: 'completed-fingerprint'),
      );
      await repository.importDocument(
        _document(title: 'Unread', fingerprint: 'unread-fingerprint'),
      );

      await repository.updateProgress(
        bookId: completedBook.id,
        progress: .8,
        lastReadAt: DateTime(2026, 10, 19),
      );

      final books = await repository.getAll(sort: LibrarySort.progress);
      expect(books.map((book) => book.title), ['Completed', 'Unread']);
    });

    test('can remove a book while keeping its annotations', () async {
      final book = await repository.importDocument(_document());
      await _seedAnnotations(database, book.id);

      await repository.deleteBook(bookId: book.id, data: DeleteBookData.keep);

      expect(await repository.getAll(), isEmpty);
      expect(await database.select(database.libraryBooks).get(), hasLength(1));
      expect(await database.select(database.bookmarks).get(), hasLength(1));
    });

    test('removes a book and its annotations when requested', () async {
      final book = await repository.importDocument(_document());
      await _seedAnnotations(database, book.id);

      await repository.deleteBook(bookId: book.id, data: DeleteBookData.delete);

      expect(await database.select(database.libraryBooks).get(), isEmpty);
      expect(await database.select(database.bookmarks).get(), isEmpty);
    });
  });
}

Future<void> _seedAnnotations(
  LinguaPageDatabase database,
  String bookId,
) async {
  final now = DateTime(2026, 10, 19);
  await database
      .into(database.bookmarks)
      .insert(
        BookmarksCompanion.insert(
          id: 'bookmark-$bookId',
          bookId: bookId,
          title: 'Saved page',
          locatorJson: '{}',
          createdAt: now,
        ),
      );
}

BookImportRequest _document({
  String title = 'Don Quijote',
  String fingerprint = 'fixture-fingerprint',
}) {
  return BookImportRequest(
    title: title,
    format: DocumentFormat.epub,
    sourceUri: '/storage/books/don-quijote.epub',
    sourceFileName: 'don-quijote.epub',
    contentFingerprint: fingerprint,
    fileSizeBytes: 2048,
    author: 'Miguel de Cervantes',
    languageCode: 'es',
    coverPath: '/covers/don-quijote.png',
    tableOfContents: const ['Chapter One', 'Chapter Two'],
  );
}
