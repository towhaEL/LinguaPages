import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';

@singleton
class LookupWordUseCase {
  LookupWordUseCase(this._dictionaryRepository);

  final DictionaryRepository _dictionaryRepository;
  final Map<String, Future<DictionaryEntry?>> _responseCache = {};

  Future<DictionaryEntry?> execute(String word) {
    final normalizedWord = word.trim().toLowerCase();
    return _responseCache.putIfAbsent(
      normalizedWord,
      () => _lookupAndCache(normalizedWord),
    );
  }

  void clearCache() => _responseCache.clear();

  Future<DictionaryEntry?> _lookupAndCache(String word) async {
    try {
      return await _dictionaryRepository.lookup(word);
    } catch (_) {
      _responseCache.remove(word);
      rethrow;
    }
  }
}
