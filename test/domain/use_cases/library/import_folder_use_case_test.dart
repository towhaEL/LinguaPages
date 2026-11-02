import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_folder_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _Folder extends Mock implements FolderImportService {}

class _Import extends Mock implements ImportDocumentUseCase {}

void main() {
  late _Folder folder;
  late _Import importer;
  late ImportFolderUseCase useCase;

  const fresh = FolderDocument(uri: 'content://fresh', fileName: 'fresh.epub');
  const duplicate = FolderDocument(uri: 'content://dup', fileName: 'dup.txt');
  const unreadable = FolderDocument(uri: 'content://bad', fileName: 'bad.pdf');
  const freshCopy = IncomingDocument(
    path: '/cache/fresh',
    fileName: 'fresh.epub',
  );
  const duplicateCopy = IncomingDocument(
    path: '/cache/dup',
    fileName: 'dup.txt',
  );

  setUpAll(() {
    registerFallbackValue(freshCopy);
    registerFallbackValue(fresh);
  });

  setUp(() {
    folder = _Folder();
    importer = _Import();
    useCase = ImportFolderUseCase(folder, importer);
    when(() => folder.copy(fresh)).thenAnswer((_) async => freshCopy);
    when(() => folder.copy(duplicate)).thenAnswer((_) async => duplicateCopy);
    when(() => folder.copy(unreadable)).thenAnswer((_) async => null);
    when(() => folder.discard(any())).thenAnswer((_) async {});
    when(() => importer.executeIncoming(freshCopy)).thenAnswer(
      (_) async => BookEntity(
        id: 'fresh',
        title: 'Fresh',
        format: DocumentFormat.epub,
        sourceUri: '/books/fresh.epub',
        sourceFileName: 'fresh.epub',
        contentFingerprint: 'fresh',
        addedAt: DateTime(2026),
      ),
    );
    when(
      () => importer.executeIncoming(duplicateCopy),
    ).thenThrow(const DuplicateDocumentException('dup.txt'));
  });

  test('imports each file, counting duplicates and failures', () async {
    when(
      () => folder.pickFolder(),
    ).thenAnswer((_) async => [fresh, duplicate, unreadable]);

    final result = await useCase.execute();

    expect(result!.imported, 1);
    expect(result.duplicates, 1);
    expect(result.failed, 1);
    verify(() => folder.discard(freshCopy)).called(1);
    verify(() => folder.discard(duplicateCopy)).called(1);
  });

  test('returns null when the picker is dismissed', () async {
    when(() => folder.pickFolder()).thenAnswer((_) async => null);

    expect(await useCase.execute(), isNull);
    verifyNever(() => folder.copy(any()));
  });
}
