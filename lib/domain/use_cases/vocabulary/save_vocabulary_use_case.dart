import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/exceptions/vocabulary_limit_exception.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';

@singleton
class SaveVocabularyUseCase {
  SaveVocabularyUseCase(this._vocabularyRepository, this._featureFlags);

  static const freeVocabularyLimit = 500;

  final VocabularyRepository _vocabularyRepository;
  final AppFeatureFlags _featureFlags;

  Future<VocabItemEntity> execute(VocabItemEntity item) async {
    if (!_featureFlags.premiumEnabled &&
        await _vocabularyRepository.totalCount() >= freeVocabularyLimit) {
      throw const VocabularyLimitException(freeVocabularyLimit);
    }
    return _vocabularyRepository.save(item);
  }
}
