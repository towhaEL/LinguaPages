import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';

@singleton
class ClearDictionaryCacheUseCase {
  ClearDictionaryCacheUseCase(this._dictionaryRepository);

  final DictionaryRepository _dictionaryRepository;

  Future<void> execute() => _dictionaryRepository.clearCache();
}
