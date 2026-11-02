import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/backup/local_backup_repository.dart';
import 'package:lingua_pages/domain/exceptions/backup_exception.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

void main() {
  late Directory temp;
  late LinguaPageDatabase source;
  late LinguaPageDatabase target;
  late LocalBackupRepository sourceRepository;
  late LocalBackupRepository targetRepository;

  // Source and target are separate in-memory databases on purpose.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('backup-test-');
    source = LinguaPageDatabase(NativeDatabase.memory());
    target = LinguaPageDatabase(NativeDatabase.memory());
    sourceRepository = LocalBackupRepository(
      source,
      _FolderStorage(Directory('${temp.path}/source')),
    );
    targetRepository = LocalBackupRepository(
      target,
      _FolderStorage(Directory('${temp.path}/target')),
    );

    final book = File('${temp.path}/book.epub')..writeAsBytesSync([1, 2, 3]);
    final cover = File('${temp.path}/abc123-cover.png')
      ..writeAsBytesSync([9, 9]);
    await source
        .into(source.libraryBooks)
        .insert(_book('book-1', 'abc123', book.path, coverPath: cover.path));
    await source.into(source.highlights).insert(_highlight('h1', 'book-1'));
    await source
        .into(source.dictionaryCacheEntries)
        .insert(
          DictionaryCacheEntriesCompanion.insert(
            word: 'hello',
            json: const Value('[]'),
            fetchedAt: DateTime(2026),
          ),
        );
  });

  tearDown(() async {
    await source.close();
    await target.close();
    await temp.delete(recursive: true);
  });

  test('restores book files, covers and cache from an encrypted zip', () async {
    final path = await sourceRepository.createBackup(
      includeBookFiles: true,
      includeDictionaryCache: true,
      passphrase: 'correct horse',
    );

    final result = await targetRepository.restoreBackup(
      path,
      passphrase: 'correct horse',
    );

    expect(result.booksRestored, 1);
    expect(result.highlightsRestored, 1);
    final restored = await target.select(target.libraryBooks).getSingle();
    expect(restored.sourceUri, startsWith('${temp.path}/target/'));
    expect(File(restored.sourceUri).readAsBytesSync(), [1, 2, 3]);
    expect(File(restored.coverPath!).readAsBytesSync(), [9, 9]);
    expect(
      await target.select(target.dictionaryCacheEntries).get(),
      hasLength(1),
    );
  });

  test('reports a missing or wrong passphrase', () async {
    final path = await sourceRepository.createBackup(passphrase: 'secret-1');

    await expectLater(
      targetRepository.restoreBackup(path),
      throwsA(_failure(BackupFailureKind.passphraseRequired)),
    );
    await expectLater(
      targetRepository.restoreBackup(path, passphrase: 'wrong-pass'),
      throwsA(_failure(BackupFailureKind.passphraseIncorrect)),
    );
    expect(await target.select(target.libraryBooks).get(), isEmpty);
  });

  test('leaves the cache and book files out unless asked', () async {
    final path = await sourceRepository.createBackup();

    await targetRepository.restoreBackup(path);

    final restored = await target.select(target.libraryBooks).getSingle();
    expect(restored.sourceUri, '${temp.path}/book.epub');
    expect(await target.select(target.dictionaryCacheEntries).get(), isEmpty);
  });

  test('still restores a legacy JSON backup', () async {
    final legacy = File('${temp.path}/legacy.json')
      ..writeAsStringSync(
        jsonEncode({
          'version': 1,
          'books': [
            (await source.select(source.libraryBooks).getSingle()).toJson(),
          ],
          'vocabulary': [
            {'ignored': true},
          ],
        }),
      );

    final result = await targetRepository.restoreBackup(legacy.path);

    expect(result.booksRestored, 1);
  });

  test('merges a book imported under another id by fingerprint', () async {
    await target
        .into(target.libraryBooks)
        .insert(_book('local-id', 'abc123', '/local/book.epub'));
    final path = await sourceRepository.createBackup();

    final result = await targetRepository.restoreBackup(path);

    expect(result.booksRestored, 0);
    expect(result.duplicatesSkipped, 1);
    final highlight = await target.select(target.highlights).getSingle();
    expect(highlight.bookId, 'local-id');
  });
}

Matcher _failure(BackupFailureKind kind) =>
    isA<BackupException>().having((error) => error.kind, 'kind', kind);

LibraryBooksCompanion _book(
  String id,
  String fingerprint,
  String sourceUri, {
  String? coverPath,
}) => LibraryBooksCompanion.insert(
  id: id,
  title: 'Book',
  documentFormat: 'epub',
  sourceUri: sourceUri,
  sourceFileName: 'book.epub',
  contentFingerprint: fingerprint,
  coverPath: Value(coverPath),
  fileSizeBytes: 3,
  addedAt: DateTime(2026),
);

HighlightsCompanion _highlight(String id, String bookId) =>
    HighlightsCompanion.insert(
      id: id,
      bookId: bookId,
      color: 'yellow',
      selectedText: 'text',
      locatorJson: '{"type":"text","offset":0}',
      createdAt: DateTime(2026),
    );

class _FolderStorage implements DocumentStorageService {
  _FolderStorage(this.directory);

  final Directory directory;

  @override
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    Uint8List? bytes,
  }) => _write('$contentFingerprint-$sourceFileName', bytes!);

  @override
  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required Uint8List bytes,
  }) => _write('$contentFingerprint-$sourceFileName', bytes);

  Future<String> _write(String name, Uint8List bytes) async {
    final file = File('${directory.path}/$name');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<void> delete({required String sourceUri, String? coverPath}) async {}
}
