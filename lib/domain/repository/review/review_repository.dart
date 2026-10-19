import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/entity/review/review_history_entry.dart';

/// Manages spaced-repetition review cards linked to vocabulary items.
abstract interface class ReviewRepository {
  Future<List<ReviewCardEntity>> getDueCards({DateTime? now});

  Future<List<ReviewCardEntity>> getAllCards();

  Future<ReviewCardEntity> createForVocabItem(String vocabItemId);

  Future<ReviewCardEntity> recordReview({
    required String cardId,
    required ReviewRating rating,
  });

  Future<int> dueCount({DateTime? now});

  Future<int> totalCards();

  Future<List<ReviewHistoryItem>> getHistory({int limit = 100});

  Future<void> deleteForVocabItem(String vocabItemId);
}
