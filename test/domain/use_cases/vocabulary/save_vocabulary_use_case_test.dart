import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:lingua_pages/domain/exceptions/vocabulary_limit_exception.dart';
import 'package:lingua_pages/domain/repository/premium/premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';
import 'package:lingua_pages/domain/use_cases/vocabulary/save_vocabulary_use_case.dart';

void main() {
  test('blocks the 501st item for non-premium users', () async {
    final repository = _FakeVocabularyRepository()
      ..items.addAll(List.generate(500, _item));
    final useCase = SaveVocabularyUseCase(repository, _flags(), null);

    await expectLater(
      useCase.execute(_item(500)),
      throwsA(isA<VocabularyLimitException>()),
    );
    expect(repository.items, hasLength(500));
  });

  test('allows more than 500 items when premium is enabled', () async {
    final repository = _FakeVocabularyRepository()
      ..items.addAll(List.generate(500, _item));
    final useCase = SaveVocabularyUseCase(
      repository,
      _flags(premiumEnabled: true),
      null,
    );

    await useCase.execute(_item(500));

    expect(repository.items, hasLength(501));
  });

  test('uses an active cached entitlement when billing is wired', () async {
    final repository = _FakeVocabularyRepository()
      ..items.addAll(List.generate(500, _item));
    final entitlement = _FakeEntitlementRepository(
      const PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.purchase,
      ),
    );
    final useCase = SaveVocabularyUseCase(
      repository,
      _flags(premiumEnabled: true),
      entitlement,
    );

    await useCase.execute(_item(500));
    expect(repository.items, hasLength(501));
  });
}

AppFeatureFlags _flags({bool premiumEnabled = false}) {
  return AppFeatureFlags(
    aiRecapEnabled: false,
    premiumEnabled: premiumEnabled,
    cloudSyncEnabled: false,
    mockServicesEnabled: true,
    mockTranslationEnabled: true,
  );
}

VocabItemEntity _item(int index) {
  return VocabItemEntity(
    id: 'vocab-$index',
    word: 'word-$index',
    lemma: 'word-$index',
    translation: 'palabra-$index',
    sourceLanguage: 'en',
    targetLanguage: 'es',
    createdAt: DateTime(2026, 10, 19).add(Duration(minutes: index)),
  );
}

class _FakeVocabularyRepository implements VocabularyRepository {
  final items = <VocabItemEntity>[];

  @override
  Future<List<VocabItemEntity>> getAll() async => List.of(items);

  @override
  Future<List<VocabItemEntity>> getByBookId(String bookId) async =>
      items.where((item) => item.bookId == bookId).toList();

  @override
  Future<List<VocabItemEntity>> search(String query) async => items;

  @override
  Future<VocabItemEntity> save(VocabItemEntity item) async {
    items.removeWhere((existing) => existing.id == item.id);
    items.add(item);
    return item;
  }

  @override
  Future<void> delete(String vocabItemId) async {
    items.removeWhere((item) => item.id == vocabItemId);
  }

  @override
  Future<int> totalCount() async => items.length;
}

class _FakeEntitlementRepository implements PremiumEntitlementRepository {
  _FakeEntitlementRepository(this.current);

  PremiumEntitlementEntity current;

  @override
  Future<PremiumEntitlementEntity> getCurrent() async => current;

  @override
  Future<void> save(PremiumEntitlementEntity entitlement) async {
    current = entitlement;
  }

  @override
  Future<void> clear() async {
    current = const PremiumEntitlementEntity(
      isPremium: false,
      source: PremiumEntitlementSource.none,
    );
  }
}
