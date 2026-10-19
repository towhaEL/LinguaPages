import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';

@singleton
class LookupWordUseCase {
  LookupWordUseCase(this._dictionaryRepository);

  final DictionaryRepository _dictionaryRepository;

  Future<DictionaryEntry?> execute({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return _dictionaryRepository.lookup(
      word: word,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
}
