import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';

/// Small English definitions fixture used until the online dictionary lands.
@LazySingleton(as: DictionaryRepository)
class MockDictionaryDataSource implements DictionaryRepository {
  static const _entries = {
    'book': DictionaryEntry(
      word: 'book',
      partOfSpeech: 'noun',
      definition: 'A collection of sheets of paper bound together to hinge '
          'at one edge, containing printed or written material.',
      example: 'I read a book every week.',
    ),
    'read': DictionaryEntry(
      word: 'read',
      partOfSpeech: 'verb',
      definition: 'To look at and interpret letters or other information '
          'that is written.',
      example: 'She likes to read before bed.',
    ),
    'hello': DictionaryEntry(
      word: 'hello',
      partOfSpeech: 'interjection',
      definition: 'A greeting said when meeting someone or acknowledging '
          'someone’s arrival or presence.',
      example: 'Hello, everyone.',
    ),
  };

  @override
  Future<DictionaryEntry?> lookup(String word) async =>
      _entries[word.trim().toLowerCase()];
}
