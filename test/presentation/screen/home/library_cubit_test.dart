import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/get_library_books_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/search_library_use_case.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';

void main() {
  late _FakeLibraryRepository repository;
  late _FakeDocumentImportService importService;
  late _FakeIncomingDocumentService incomingService;
  late LibraryCubit cubit;

  setUp(() {
    repository = _FakeLibraryRepository();
    importService = _FakeDocumentImportService();
    incomingService = _FakeIncomingDocumentService();
    cubit = _createCubit(
      repository,
      importService: importService,
      incomingService: incomingService,
    );
  });

  tearDown(() async {
    await cubit.close();
    await incomingService.close();
  });

  test('load emits success with books from the repository', () async {
    final book = _book('first', title: 'First book');
    repository.books = [book];

    final states = <LibraryState>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.load();
    await subscription.cancel();

    expect(states.map((state) => state.status), [
      LibraryStatus.loading,
      LibraryStatus.success,
    ]);
    expect(cubit.state.books, [book]);
    expect(repository.lastSort, LibrarySort.recent);
  });

  test('search stores the query and returns matching books', () async {
    final book = _book('matching', title: 'Language practice');
    repository.searchResults = [book];

    await cubit.search('language');

    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.query, 'language');
    expect(cubit.state.books, [book]);
    expect(repository.lastQuery, 'language');
  });

  test('changeSort reloads the current search with the selected sort', () async {
    final book = _book('sorted', title: 'Sorted result');
    repository.searchResults = [book];
    await cubit.search('sorted');

    await cubit.changeSort(LibrarySort.title);

    expect(cubit.state.sort, LibrarySort.title);
    expect(cubit.state.books, [book]);
    expect(repository.lastQuery, 'sorted');
    expect(repository.lastSort, LibrarySort.title);
  });

  test('changeSort reloads the full library when there is no search query',
      () async {
    final book = _book('sorted', title: 'Sorted result');
    repository.books = [book];

    await cubit.changeSort(LibrarySort.progress);

    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.sort, LibrarySort.progress);
    expect(cubit.state.books, [book]);
    expect(repository.lastQuery, isNull);
    expect(repository.lastSort, LibrarySort.progress);
  });

  test('toggleViewMode alternates between grid and list', () {
    expect(cubit.state.viewMode, LibraryViewMode.grid);

    cubit.toggleViewMode();
    expect(cubit.state.viewMode, LibraryViewMode.list);

    cubit.toggleViewMode();
    expect(cubit.state.viewMode, LibraryViewMode.grid);
  });

  test('load exposes a repository failure and can recover on retry', () async {
    repository.getAllError = StateError('database unavailable');

    await cubit.load();

    expect(cubit.state.status, LibraryStatus.failure);
    expect(cubit.state.errorMessage, contains('database unavailable'));

    repository.getAllError = null;
    repository.books = [_book('recovered')];
    await cubit.load();

    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.books.single.id, 'recovered');
  });

  test('deleteBook refreshes the library and reports success', () async {
    final book = _book('to-delete');
    repository.books = [book];

    final deleted = await cubit.deleteBook(
      book: book,
      data: DeleteBookData.keep,
    );

    expect(deleted, isTrue);
    expect(repository.deletedBookId, book.id);
    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.books, isEmpty);
  });

  test('deleteBook reports false when deletion fails', () async {
    final book = _book('cannot-delete');
    repository.deleteError = StateError('delete failed');

    final deleted = await cubit.deleteBook(
      book: book,
      data: DeleteBookData.delete,
    );

    expect(deleted, isFalse);
    expect(cubit.state.status, LibraryStatus.initial);
  });

  test('importDocument reports an imported book and refreshes the list',
      () async {
    final book = _book('imported', title: 'Imported book');
    importService.pickedDocument = _request('imported.epub');
    repository.importedBook = book;
    repository.books = [book];

    await cubit.importDocument();

    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.isImporting, isFalse);
    expect(cubit.state.importFeedback, LibraryImportFeedback.imported);
    expect(cubit.state.importMessage, 'Imported book');
    expect(cubit.state.books, [book]);
  });

  test('importDocument reports duplicate feedback', () async {
    importService.pickedDocument = _request('duplicate.epub');
    repository.importError = const DuplicateDocumentException('duplicate.epub');

    await cubit.importDocument();

    expect(cubit.state.isImporting, isFalse);
    expect(cubit.state.importFeedback, LibraryImportFeedback.duplicate);
    expect(cubit.state.importMessage, 'duplicate.epub');
  });

  test('importDocument maps document failures to user feedback', () async {
    importService.pickedDocument = _request('broken.epub');
    repository.importError = const CorruptDocumentException('broken document');

    await cubit.importDocument();

    expect(cubit.state.isImporting, isFalse);
    expect(cubit.state.importFeedback, LibraryImportFeedback.corruptDocument);
    expect(cubit.state.importMessage, 'broken document');
  });

  test('incoming documents are imported through the same feedback path',
      () async {
    final book = _book('incoming', title: 'Incoming book');
    repository.importedBook = book;
    repository.books = [book];
    importService.externalDocument = _request('incoming.epub');

    incomingService.add(
      const IncomingDocument(path: '/tmp/incoming.epub', fileName: 'incoming.epub'),
    );
    await _settleAsyncWork();

    expect(cubit.state.status, LibraryStatus.success);
    expect(cubit.state.importFeedback, LibraryImportFeedback.imported);
    expect(cubit.state.importMessage, 'Incoming book');
    expect(importService.lastExternalPath, '/tmp/incoming.epub');
  });
}

LibraryCubit _createCubit(
  _FakeLibraryRepository repository, {
  required _FakeDocumentImportService importService,
  required _FakeIncomingDocumentService incomingService,
}) {
  return LibraryCubit(
    GetLibraryBooksUseCase(repository),
    DeleteLibraryBookUseCase(repository, _FakeDocumentStorageService()),
    ImportDocumentUseCase(importService, repository),
    SearchLibraryUseCase(repository),
    incomingService,
    Logger(level: Level.off),
  );
}

Future<void> _settleAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

BookEntity _book(String id, {String title = 'Book'}) {
  return BookEntity(
    id: id,
    title: title,
    format: DocumentFormat.epub,
    sourceUri: 'file:///books/$id.epub',
    sourceFileName: '$id.epub',
    contentFingerprint: 'fingerprint-$id',
    addedAt: DateTime(2026, 1, 1),
    fileSizeBytes: 100,
  );
}

BookImportRequest _request(String fileName) {
  return BookImportRequest(
    title: fileName,
    format: DocumentFormat.epub,
    sourceUri: 'file:///incoming/$fileName',
    sourceFileName: fileName,
    contentFingerprint: 'fingerprint-$fileName',
    fileSizeBytes: 100,
  );
}

class _FakeLibraryRepository implements LibraryRepository {
  List<BookEntity> books = [];
  List<BookEntity> searchResults = [];
  BookEntity? importedBook;
  Object? getAllError;
  Object? searchError;
  Object? importError;
  Object? deleteError;
  String? lastQuery;
  LibrarySort? lastSort;
  String? deletedBookId;

  @override
  Future<List<BookEntity>> getAll({LibrarySort sort = LibrarySort.recent}) async {
    lastQuery = null;
    lastSort = sort;
    final error = getAllError;
    if (error != null) throw error;
    return List<BookEntity>.from(books);
  }

  @override
  Future<List<BookEntity>> search(
    String query, {
    LibrarySort sort = LibrarySort.recent,
  }) async {
    lastQuery = query;
    lastSort = sort;
    final error = searchError;
    if (error != null) throw error;
    return List<BookEntity>.from(searchResults);
  }

  @override
  Future<BookEntity?> getById(String id) async =>
      books.where((book) => book.id == id).firstOrNull;

  @override
  Future<BookEntity> importDocument(BookImportRequest document) async {
    final error = importError;
    if (error != null) throw error;
    final book = importedBook ?? _book(document.sourceFileName);
    if (!books.any((item) => item.id == book.id)) books = [...books, book];
    return book;
  }

  @override
  Future<void> deleteBook({
    required String bookId,
    required DeleteBookData data,
  }) async {
    final error = deleteError;
    if (error != null) throw error;
    deletedBookId = bookId;
    books = books.where((book) => book.id != bookId).toList();
  }

  @override
  Future<void> updateProgress({
    required String bookId,
    required double progress,
    required DateTime lastReadAt,
    String? readingLocatorJson,
  }) async {}
}

class _FakeDocumentImportService implements DocumentImportService {
  BookImportRequest? pickedDocument;
  BookImportRequest? externalDocument;
  String? lastExternalPath;

  @override
  Future<BookImportRequest?> pickDocument() async => pickedDocument;

  @override
  Future<BookImportRequest> importExternalFile({
    required String path,
    required String fileName,
  }) async {
    lastExternalPath = path;
    return externalDocument ?? _request(fileName);
  }
}

class _FakeDocumentStorageService implements DocumentStorageService {
  @override
  Future<void> delete({required String sourceUri, String? coverPath}) async {}

  @override
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    List<int>? bytes,
  }) async =>
      sourceUriFor(sourceFileName);

  @override
  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required List<int> bytes,
  }) async =>
      'cover://$contentFingerprint';
}

String sourceUriFor(String fileName) => 'file:///stored/$fileName';

class _FakeIncomingDocumentService implements IncomingDocumentService {
  final StreamController<IncomingDocument> _controller =
      StreamController<IncomingDocument>.broadcast(sync: true);

  @override
  Stream<IncomingDocument> get documents => _controller.stream;

  @override
  Future<IncomingDocument?> takeInitialDocument() async => null;

  void add(IncomingDocument document) => _controller.add(document);

  Future<void> close() => _controller.close();
}
