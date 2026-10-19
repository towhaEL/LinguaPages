import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';

/// Manages spaced-repetition review cards linked to vocabulary items.
abstract interface class ReviewRepository {
  Future<List<ReviewCardEntity>> getDueCards({DateTime? now});

  Future<ReviewCardEntity> createForVocabItem(String vocabItemId);

  Future<ReviewCardEntity> recordReview({
    required String cardId,
    required ReviewRating rating,
  });

  Future<int> dueCount({DateTime? now});

  Future<int> totalCards();

  Future<void> deleteForVocabItem(String vocabItemId);
}
