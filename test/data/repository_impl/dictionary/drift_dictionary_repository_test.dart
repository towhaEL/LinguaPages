import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/data/data_source/dictionary/dictionary_data_source.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';
import 'package:lingua_pages/data/repository_impl/dictionary/drift_dictionary_repository.dart';
import 'package:lingua_pages/data/repository_impl/settings/drift_settings_repository.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';

void main() {
  late LinguaPageDatabase database;
  late DriftSettingsRepository settings;
  late _FakeDataSource dataSource;
  late DateTime now;

  DriftDictionaryRepository newRepository() => DriftDictionaryRepository(
    database,
    dataSource,
    settings,
    Logger(level: Level.off),
    clock: () => now,
  );

  setUp(() {
    database = LinguaPageDatabase(NativeDatabase.memory());
    settings = DriftSettingsRepository(database);
    dataSource = _FakeDataSource();
    now = DateTime(2026, 11);
  });

  tearDown(() => database.close());

  test('a found word is cached on disk and survives a restart', () async {
    final first = await newRepository().lookup('book');
    // A new instance has an empty memory cache, so this reads Drift.
    final second = await newRepository().lookup('book');

    expect(first, isA<DictionaryFound>());
    expect((second as DictionaryFound).entries.single.word, 'book');
    expect(dataSource.calls, 1);
  });

  test('concurrent lookups of one word share a request', () async {
    final repository = newRepository();

    await Future.wait([repository.lookup('book'), repository.lookup('book')]);

    expect(dataSource.calls, 1);
  });

  test('a 404 is not found and is cached for seven days', () async {
    dataSource.error = _status(404);

    expect(await newRepository().lookup('zzz'), isA<DictionaryNotFound>());
    now = now.add(const Duration(days: 6));
    expect(await newRepository().lookup('zzz'), isA<DictionaryNotFound>());
    expect(dataSource.calls, 1);

    now = now.add(const Duration(days: 2));
    expect(await newRepository().lookup('zzz'), isA<DictionaryNotFound>());
    expect(dataSource.calls, 2);
  });

  for (final (name, error) in [
    (
      'connection error',
      DioException.connectionError(
        requestOptions: RequestOptions(),
        reason: 'offline',
      ),
    ),
    (
      'timeout',
      DioException.connectionTimeout(
        requestOptions: RequestOptions(),
        timeout: const Duration(seconds: 8),
      ),
    ),
    (
      'socket exception',
      DioException(
        requestOptions: RequestOptions(),
        error: const SocketException('no route'),
      ),
    ),
  ]) {
    test('$name is offline and retried next time', () async {
      final repository = newRepository();
      dataSource.error = error;

      expect(await repository.lookup('book'), isA<DictionaryOffline>());

      dataSource.error = null;
      expect(await repository.lookup('book'), isA<DictionaryFound>());
      expect(dataSource.calls, 2);
    });
  }

  test('a server error is failed and not cached', () async {
    final repository = newRepository();
    dataSource.error = _status(500);

    expect(await repository.lookup('book'), isA<DictionaryFailed>());
    dataSource.error = null;
    expect(await repository.lookup('book'), isA<DictionaryFound>());
  });

  test('an unexpected response shape is failed', () async {
    dataSource.error = const FormatException('bad json');

    expect(await newRepository().lookup('book'), isA<DictionaryFailed>());
  });

  test('with online lookups off only the cache is used', () async {
    await newRepository().lookup('book');
    await settings.updateSetting(key: 'onlineDictionary', value: false);
    final repository = newRepository();

    expect(await repository.lookup('book'), isA<DictionaryFound>());
    expect(await repository.lookup('read'), isA<DictionaryOffline>());
    expect(dataSource.calls, 1);
  });

  test('clearCache empties memory and disk', () async {
    final repository = newRepository();
    await repository.lookup('book');

    await repository.clearCache();
    await repository.lookup('book');

    expect(dataSource.calls, 2);
  });

  test('the word is URL-encoded for the request', () async {
    await newRepository().lookup('and/or');

    expect(dataSource.words.single, 'and%2For');
  });
}

DioException _status(int code) {
  final options = RequestOptions(path: 'entries/en/x');
  return DioException.badResponse(
    statusCode: code,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: code),
  );
}

class _FakeDataSource implements DictionaryDataSource {
  Object? error;
  int calls = 0;
  final words = <String>[];

  @override
  Future<List<DictionaryEntryModel>> entries(String word) async {
    calls++;
    words.add(word);
    final failure = error;
    if (failure != null) throw failure;
    return [
      DictionaryEntryModel(
        word: Uri.decodeComponent(word),
        meanings: const [
          MeaningModel(
            partOfSpeech: 'noun',
            definitions: [DefinitionModel(definition: 'A definition.')],
          ),
        ],
      ),
    ];
  }
}
