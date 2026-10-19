import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/exceptions/vocabulary_limit_exception.dart';
import 'package:lingua_pages/domain/repository/premium/premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';

@singleton
class SaveVocabularyUseCase {
  SaveVocabularyUseCase(
    this._vocabularyRepository,
    this._featureFlags,
    this._entitlementRepository,
  );

  static const freeVocabularyLimit = 500;

  final VocabularyRepository _vocabularyRepository;
  final AppFeatureFlags _featureFlags;
  final PremiumEntitlementRepository? _entitlementRepository;

  Future<VocabItemEntity> execute(VocabItemEntity item) async {
    final entitlementRepository = _entitlementRepository;
    final premiumAccess = entitlementRepository == null
        ? _featureFlags.premiumEnabled
        : _featureFlags.premiumEnabled &&
            (await entitlementRepository.getCurrent()).isActive;
    if (!premiumAccess &&
        await _vocabularyRepository.totalCount() >= freeVocabularyLimit) {
      throw const VocabularyLimitException(freeVocabularyLimit);
    }
    return _vocabularyRepository.save(item);
  }
}
