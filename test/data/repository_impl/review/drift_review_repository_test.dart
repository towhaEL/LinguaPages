import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/review/drift_review_repository.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';

void main() {
  group('DriftReviewRepository', () {
    late LinguaPageDatabase database;
    late DriftReviewRepository repository;

    setUp(() async {
      database = LinguaPageDatabase(NativeDatabase.memory());
      await database
          .into(database.vocabItems)
          .insert(
            VocabItemsCompanion.insert(
              id: 'vocab-1',
              word: 'book',
              lemma: 'book',
              translation: 'libro',
              sourceLanguage: 'en',
              targetLanguage: 'es',
              createdAt: DateTime(2026, 10, 19),
            ),
          );
      repository = DriftReviewRepository(database);
    });

    tearDown(() => database.close());

    test('creates a due new card and schedules a good review', () async {
      final card = await repository.createForVocabItem('vocab-1');

      expect(card.state, ReviewCardState.newCard);
      expect((await repository.getDueCards()).single.id, card.id);
      expect((await repository.getAllCards()).single.id, card.id);

      final reviewed = await repository.recordReview(
        cardId: card.id,
        rating: ReviewRating.good,
      );

      expect(reviewed.state, ReviewCardState.review);
      expect(reviewed.interval, 1);
      expect(reviewed.repetitions, 1);
      expect(reviewed.nextReviewDate.isAfter(DateTime.now()), isTrue);
      expect(await repository.dueCount(), 0);
    });

    test('again resets repetitions and keeps the card in learning', () async {
      final card = await repository.createForVocabItem('vocab-1');
      final reviewed = await repository.recordReview(
        cardId: card.id,
        rating: ReviewRating.again,
      );

      expect(reviewed.state, ReviewCardState.learning);
      expect(reviewed.interval, 0);
      expect(reviewed.repetitions, 0);
      expect(reviewed.nextReviewDate.isAfter(DateTime.now()), isTrue);
    });
  });
}
