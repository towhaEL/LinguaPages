import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);

  test('ReviewCardEntity is due at and after its next review date', () {
    final card = _card(nextReviewDate: now);

    expect(card.isDue(now), isTrue);
    expect(card.isDue(now.add(const Duration(seconds: 1))), isTrue);
    expect(card.isDue(now.subtract(const Duration(seconds: 1))), isFalse);
  });

  test('ReviewCardEntity exposes its scheduled state and review metadata', () {
    final reviewedAt = now.subtract(const Duration(days: 1));
    final card = _card(
      nextReviewDate: now,
      interval: 4,
      easeFactor: 2.4,
      repetitions: 3,
      state: ReviewCardState.review,
      lastReviewedAt: reviewedAt,
    );

    expect(card.interval, 4);
    expect(card.easeFactor, 2.4);
    expect(card.repetitions, 3);
    expect(card.state, ReviewCardState.review);
    expect(card.lastReviewedAt, reviewedAt);
  });
}

ReviewCardEntity _card({
  required DateTime nextReviewDate,
  int interval = 0,
  double easeFactor = 2.5,
  int repetitions = 0,
  ReviewCardState state = ReviewCardState.newCard,
  DateTime? lastReviewedAt,
}) {
  return ReviewCardEntity(
    id: 'card-1',
    vocabItemId: 'vocab-1',
    interval: interval,
    easeFactor: easeFactor,
    repetitions: repetitions,
    nextReviewDate: nextReviewDate,
    state: state,
    createdAt: DateTime(2026, 10, 1),
    lastReviewedAt: lastReviewedAt,
  );
}
