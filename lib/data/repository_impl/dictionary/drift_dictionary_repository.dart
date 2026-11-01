import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/data/data_source/dictionary/dictionary_data_source.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';
import 'package:lingua_pages/data/remapper/dictionary_remapper.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';

/// Looks a word up in memory, then in the Drift cache, and only then online.
/// Found words are kept until the user clears the cache; "no definition"
/// answers are kept for [notFoundTtl] so new dictionary entries show up.
@LazySingleton(as: DictionaryRepository)
class DriftDictionaryRepository implements DictionaryRepository {
  DriftDictionaryRepository(
    this._database,
    this._dataSource,
    this._settingsRepository,
    this._logger, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const notFoundTtl = Duration(days: 7);

  final LinguaPageDatabase _database;
  final DictionaryDataSource _dataSource;
  final SettingsRepository _settingsRepository;
  final Logger _logger;
  final DateTime Function() _clock;
  final Map<String, Future<DictionaryLookupResult>> _memory = {};

  @override
  Future<DictionaryLookupResult> lookup(String word) {
    final pending = _memory[word];
    if (pending != null) return pending;
    final result = _lookup(word);
    _memory[word] = result;
    unawaited(
      result.then((value) {
        // Offline and failed answers are retried on the next lookup.
        if (value is DictionaryOffline || value is DictionaryFailed) {
          _memory.remove(word);
        }
      }),
    );
    return result;
  }

  @override
  Future<void> clearCache() async {
    _memory.clear();
    await _database.delete(_database.dictionaryCacheEntries).go();
  }

  Future<DictionaryLookupResult> _lookup(String word) async {
    final cached = await _readCache(word);
    if (cached != null) return cached;
    if (!await _onlineEnabled()) return const DictionaryOffline();

    try {
      // Retrofit inserts path values as-is; "and/or" must not become a path.
      final models = await _dataSource.entries(Uri.encodeComponent(word));
      if (models.isEmpty) {
        await _writeCache(word, null);
        return const DictionaryNotFound();
      }
      await _writeCache(
        word,
        jsonEncode([for (final model in models) model.toJson()]),
      );
      return DictionaryFound([for (final model in models) model.toEntity()]);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        await _writeCache(word, null);
        return const DictionaryNotFound();
      }
      if (_isOffline(error)) return const DictionaryOffline();
      _logger.w('Dictionary lookup failed for "$word"', error: error);
      return const DictionaryFailed();
    } catch (error, stackTrace) {
      // A response that does not match the expected shape.
      _logger.e(
        'Dictionary response could not be read for "$word"',
        error: error,
        stackTrace: stackTrace,
      );
      return const DictionaryFailed();
    }
  }

  Future<DictionaryLookupResult?> _readCache(String word) async {
    final table = _database.dictionaryCacheEntries;
    final row = await (_database.select(
      table,
    )..where((entry) => entry.word.equals(word))).getSingleOrNull();
    if (row == null) return null;

    final json = row.json;
    if (json == null) {
      final fresh = _clock().difference(row.fetchedAt) < notFoundTtl;
      return fresh ? const DictionaryNotFound() : null;
    }
    try {
      final models = (jsonDecode(json) as List<dynamic>)
          .map(
            (item) =>
                DictionaryEntryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      return DictionaryFound([for (final model in models) model.toEntity()]);
    } catch (error) {
      _logger.w('Dropping unreadable dictionary cache for "$word"');
      await (_database.delete(
        table,
      )..where((entry) => entry.word.equals(word))).go();
      return null;
    }
  }

  Future<void> _writeCache(String word, String? json) async {
    try {
      await _database
          .into(_database.dictionaryCacheEntries)
          .insertOnConflictUpdate(
            DictionaryCacheEntriesCompanion.insert(
              word: word,
              json: Value(json),
              fetchedAt: _clock(),
            ),
          );
    } catch (error) {
      // The definition is still shown; it just is not available offline.
      _logger.w('Could not cache dictionary entry for "$word"', error: error);
    }
  }

  Future<bool> _onlineEnabled() async {
    try {
      return (await _settingsRepository.getSettings()).onlineDictionary;
    } catch (_) {
      return true;
    }
  }

  bool _isOffline(DioException error) =>
      error.error is SocketException ||
      const {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      }.contains(error.type);
}
