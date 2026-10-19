import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';

@singleton
class LookupWordUseCase {
  LookupWordUseCase(this._dictionaryRepository);

  final DictionaryRepository _dictionaryRepository;
  final Map<String, Future<DictionaryEntry?>> _responseCache = {};

  Future<DictionaryEntry?> execute({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final normalizedWord = word.trim().toLowerCase();
    final normalizedSourceLanguage = sourceLanguage.trim().toLowerCase();
    final normalizedTargetLanguage = targetLanguage.trim().toLowerCase();
    final key = [
      normalizedSourceLanguage,
      normalizedTargetLanguage,
      normalizedWord,
    ].join('|');

    return _responseCache.putIfAbsent(
      key,
      () => _lookupAndCache(
        key: key,
        word: normalizedWord,
        sourceLanguage: normalizedSourceLanguage,
        targetLanguage: normalizedTargetLanguage,
      ),
    );
  }

  void clearCache() => _responseCache.clear();

  Future<DictionaryEntry?> _lookupAndCache({
    required String key,
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      return await _dictionaryRepository.lookup(
        word: word,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (_) {
      _responseCache.remove(key);
      rethrow;
    }
  }
}
