import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';

/// Development-only dictionary fixture used until licensed data is selected.
@LazySingleton(as: DictionaryRepository)
class MockDictionaryDataSource implements DictionaryRepository {
  static const _entries = {
    'book': DictionaryEntry(
      lemma: 'book',
      translation: 'libro',
      partOfSpeech: 'noun',
      example: 'I read a book every week.',
    ),
    'read': DictionaryEntry(
      lemma: 'read',
      translation: 'leer',
      partOfSpeech: 'verb',
      example: 'She likes to read before bed.',
    ),
  };

  @override
  Future<DictionaryEntry?> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (sourceLanguage != 'en' || targetLanguage != 'es') {
      return null;
    }

    return _entries[word.trim().toLowerCase()];
  }
}
