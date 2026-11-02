import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/library/drift_collection_repository.dart';
import 'package:lingua_pages/data/repository_impl/library/drift_library_repository.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';

void main() {
  late LinguaPageDatabase database;
  late DriftCollectionRepository collections;
  late DriftLibraryRepository library;

  setUp(() {
    database = LinguaPageDatabase(NativeDatabase.memory());
    collections = DriftCollectionRepository(database);
    library = DriftLibraryRepository(database);
  });

  tearDown(() => database.close());

  Future<String> importBook(String fingerprint) async =>
      (await library.importDocument(
        BookImportRequest(
          title: fingerprint,
          format: DocumentFormat.txt,
          sourceUri: '/books/$fingerprint.txt',
          sourceFileName: '$fingerprint.txt',
          contentFingerprint: fingerprint,
          fileSizeBytes: 1,
        ),
      )).id;

  test('creates, renames and lists collections by name', () async {
    final sea = await collections.create(' Sea ');
    await collections.create('Autumn');

    await collections.rename(id: sea.id, name: 'Ocean');

    expect((await collections.getAll()).map((c) => c.name), [
      'Autumn',
      'Ocean',
    ]);
    expect(() => collections.create('  '), throwsArgumentError);
  });

  test('a book can sit in several collections', () async {
    final book = await importBook('a');
    final one = await collections.create('One');
    final two = await collections.create('Two');

    await collections.setBookCollections(
      bookId: book,
      collectionIds: {one.id, two.id},
    );
    expect(
      (await collections.getAll()).every((c) => c.bookIds.contains(book)),
      isTrue,
    );

    await collections.setBookCollections(bookId: book, collectionIds: {two.id});
    final all = await collections.getAll();
    expect(all.firstWhere((c) => c.id == one.id).bookIds, isEmpty);
    expect(all.firstWhere((c) => c.id == two.id).bookIds, {book});
  });

  test('deleting a collection keeps its books', () async {
    final book = await importBook('b');
    final shelf = await collections.create('Shelf');
    await collections.setBookCollections(
      bookId: book,
      collectionIds: {shelf.id},
    );

    await collections.delete(shelf.id);

    expect(await collections.getAll(), isEmpty);
    expect(await library.getAll(), hasLength(1));
  });

  test('permanently deleting a book drops its memberships', () async {
    final book = await importBook('c');
    final shelf = await collections.create('Shelf');
    await collections.setBookCollections(
      bookId: book,
      collectionIds: {shelf.id},
    );

    await library.deleteBook(bookId: book, data: DeleteBookData.delete);

    expect((await collections.getAll()).single.bookIds, isEmpty);
  });
}
