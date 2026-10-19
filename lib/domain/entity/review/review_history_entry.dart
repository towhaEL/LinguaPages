import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';

/// One immutable answer recorded during a review session.
class ReviewHistoryItem {
  const ReviewHistoryItem({
    required this.id,
    required this.reviewCardId,
    required this.vocabItemId,
    required this.rating,
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.reviewedAt,
  });

  final String id;
  final String reviewCardId;
  final String vocabItemId;
  final ReviewRating rating;
  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime reviewedAt;
}
