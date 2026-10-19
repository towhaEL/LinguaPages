import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';

@singleton
class SaveVocabularyUseCase {
  SaveVocabularyUseCase(this._vocabularyRepository);

  final VocabularyRepository _vocabularyRepository;

  Future<VocabItemEntity> execute(VocabItemEntity item) {
    return _vocabularyRepository.save(item);
  }
}
