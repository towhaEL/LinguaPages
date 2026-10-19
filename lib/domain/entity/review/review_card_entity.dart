/// A vocabulary item scheduled for spaced repetition.
class ReviewCardEntity {
  const ReviewCardEntity({
    required this.id,
    required this.vocabItemId,
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReviewDate,
    required this.state,
    required this.createdAt,
    this.lastReviewedAt,
  });

  final String id;
  final String vocabItemId;
  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;
  final ReviewCardState state;
  final DateTime createdAt;

  bool isDue([DateTime? now]) => !nextReviewDate.isAfter(now ?? DateTime.now());
}

enum ReviewCardState { newCard, learning, review }

enum ReviewRating { again, hard, good, easy }
