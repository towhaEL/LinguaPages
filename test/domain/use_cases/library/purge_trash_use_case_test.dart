import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/purge_trash_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _Library extends Mock implements LibraryRepository {}

class _Delete extends Mock implements DeleteLibraryBookUseCase {}

void main() {
  late _Library library;
  late _Delete delete;
  late PurgeTrashUseCase useCase;
  final book = BookEntity(
    id: 'old',
    title: 'Old',
    format: DocumentFormat.txt,
    sourceUri: '/old.txt',
    sourceFileName: 'old.txt',
    contentFingerprint: 'old',
    addedAt: DateTime(2026),
    deletedAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(book);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(DeleteBookData.keep);
  });

  setUp(() {
    library = _Library();
    delete = _Delete();
    useCase = PurgeTrashUseCase(library, delete);
    when(() => library.trashedBefore(any())).thenAnswer((_) async => [book]);
    when(
      () => delete.execute(
        book: any(named: 'book'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
  });

  test('purges books trashed over 30 days ago, keeping annotations', () async {
    final purged = await useCase.execute(now: DateTime(2026, 3, 31));

    expect(purged, 1);
    verify(() => library.trashedBefore(DateTime(2026, 3, 1))).called(1);
    verify(
      () => delete.execute(book: book, data: DeleteBookData.keep),
    ).called(1);
  });

  test('empties all of Trash on request', () async {
    await useCase.execute(everything: true);

    final cutoff =
        verify(() => library.trashedBefore(captureAny())).captured.single
            as DateTime;
    expect(cutoff.isAfter(DateTime.now()), isTrue);
  });
}
