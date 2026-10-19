import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/get_library_books_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/search_library_use_case.dart';

void main() {
  late _FakeLibraryRepository repository;
  late _FakeImportService importService;
  late _FakeStorageService storageService;

  setUp(() {
    repository = _FakeLibraryRepository();
    importService = _FakeImportService();
    storageService = _FakeStorageService();
  });

  test('GetLibraryBooksUseCase forwards the requested sort', () async {
    final books = [_book('recent')];
    repository.books = books;

    final result = await GetLibraryBooksUseCase(repository).execute(
      sort: LibrarySort.progress,
    );

    expect(result, books);
    expect(repository.lastSort, LibrarySort.progress);
  });

  test('SearchLibraryUseCase forwards query and sort', () async {
    final books = [_book('match')];
    repository.searchResults = books;

    final result = await SearchLibraryUseCase(repository).execute(
      'language',
      sort: LibrarySort.title,
    );

    expect(result, books);
    expect(repository.lastQuery, 'language');
    expect(repository.lastSort, LibrarySort.title);
  });

  test('ImportDocumentUseCase returns null when picker is dismissed',
      () async {
    final result = await ImportDocumentUseCase(
      importService,
      repository,
    ).execute();

    expect(result, isNull);
    expect(repository.importRequest, isNull);
  });

  test('ImportDocumentUseCase imports a picked document', () async {
    final request = _request('picked.epub');
    final imported = _book('picked');
    importService.picked = request;
    repository.importedBook = imported;

    final result = await ImportDocumentUseCase(
      importService,
      repository,
    ).execute();

    expect(result, imported);
    expect(repository.importRequest, request);
  });

  test('ImportDocumentUseCase converts an incoming file then imports it',
      () async {
    final request = _request('shared.epub');
    final imported = _book('shared');
    importService.externalRequest = request;
    repository.importedBook = imported;

    final result = await ImportDocumentUseCase(
      importService,
      repository,
    ).executeIncoming(
      const IncomingDocument(path: '/shared/shared.epub', fileName: 'shared.epub'),
    );

    expect(result, imported);
    expect(importService.externalPath, '/shared/shared.epub');
    expect(importService.externalFileName, 'shared.epub');
    expect(repository.importRequest, request);
  });

  test('DeleteLibraryBookUseCase deletes metadata and stored files', () async {
    final book = _book('delete-me');

    await DeleteLibraryBookUseCase(repository, storageService).execute(
      book: book,
      data: DeleteBookData.delete,
    );

    expect(repository.deletedBookId, book.id);
    expect(repository.deletedData, DeleteBookData.delete);
    expect(storageService.sourceUri, book.sourceUri);
    expect(storageService.coverPath, book.coverPath);
  });
}

BookEntity _book(String id) {
  return BookEntity(
    id: id,
    title: id,
    format: DocumentFormat.epub,
    sourceUri: 'file:///$id.epub',
    sourceFileName: '$id.epub',
    contentFingerprint: 'fingerprint-$id',
    addedAt: DateTime(2026),
  );
}

BookImportRequest _request(String fileName) {
  return BookImportRequest(
    title: fileName,
    format: DocumentFormat.epub,
    sourceUri: 'file:///incoming/$fileName',
    sourceFileName: fileName,
    contentFingerprint: 'fingerprint-$fileName',
    fileSizeBytes: 10,
  );
}

class _FakeLibraryRepository implements LibraryRepository {
  List<BookEntity> books = [];
  List<BookEntity> searchResults = [];
  BookEntity? importedBook;
  BookImportRequest? importRequest;
  String? lastQuery;
  LibrarySort? lastSort;
  String? deletedBookId;
  DeleteBookData? deletedData;

  @override
  Future<List<BookEntity>> getAll({LibrarySort sort = LibrarySort.recent}) async {
    lastSort = sort;
    return books;
  }

  @override
  Future<List<BookEntity>> search(
    String query, {
    LibrarySort sort = LibrarySort.recent,
  }) async {
    lastQuery = query;
    lastSort = sort;
    return searchResults;
  }

  @override
  Future<BookEntity?> getById(String id) async => null;

  @override
  Future<BookEntity> importDocument(BookImportRequest document) async {
    importRequest = document;
    return importedBook ?? _book(document.sourceFileName);
  }

  @override
  Future<void> deleteBook({
    required String bookId,
    required DeleteBookData data,
  }) async {
    deletedBookId = bookId;
    deletedData = data;
  }

  @override
  Future<void> updateProgress({
    required String bookId,
    required double progress,
    required DateTime lastReadAt,
    String? readingLocatorJson,
  }) async {}
}

class _FakeImportService implements DocumentImportService {
  BookImportRequest? picked;
  BookImportRequest? externalRequest;
  String? externalPath;
  String? externalFileName;

  @override
  Future<BookImportRequest?> pickDocument() async => picked;

  @override
  Future<BookImportRequest> importExternalFile({
    required String path,
    required String fileName,
  }) async {
    externalPath = path;
    externalFileName = fileName;
    return externalRequest ?? _request(fileName);
  }
}

class _FakeStorageService implements DocumentStorageService {
  String? sourceUri;
  String? coverPath;

  @override
  Future<void> delete({required String sourceUri, String? coverPath}) async {
    this.sourceUri = sourceUri;
    this.coverPath = coverPath;
  }

  @override
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    Uint8List? bytes,
  }) async =>
      'file:///stored/$sourceFileName';

  @override
  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required Uint8List bytes,
  }) async =>
      'cover://$contentFingerprint';
}
