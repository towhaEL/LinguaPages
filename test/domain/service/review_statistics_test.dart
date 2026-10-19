import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/service/review_statistics.dart';

void main() {
  test('counts due cards and consecutive review days', () {
    final now = DateTime(2026, 10, 19, 12);
    final cards = [
      _card(
        1,
        nextReviewDate: DateTime(2026, 10, 19),
        lastReviewedAt: DateTime(2026, 10, 19, 9),
      ),
      _card(
        2,
        nextReviewDate: DateTime(2026, 10, 20),
        lastReviewedAt: DateTime(2026, 10, 18, 9),
      ),
      _card(
        3,
        nextReviewDate: DateTime(2026, 10, 20),
        lastReviewedAt: DateTime(2026, 10, 16, 9),
      ),
    ];

    final stats = ReviewStatistics.fromCards(cards, now: now);

    expect(stats.totalCards, 3);
    expect(stats.reviewedCards, 3);
    expect(stats.dueCards, 1);
    expect(stats.activeDays, 3);
    expect(stats.currentStreak, 2);
  });

  test('starts a streak from yesterday when today has no review', () {
    final now = DateTime(2026, 10, 19, 12);
    final stats = ReviewStatistics.fromCards([
      _card(1, lastReviewedAt: DateTime(2026, 10, 18, 9)),
    ], now: now);

    expect(stats.currentStreak, 1);
  });
}

ReviewCardEntity _card(
  int index, {
  DateTime? nextReviewDate,
  DateTime? lastReviewedAt,
}) {
  return ReviewCardEntity(
    id: 'card-$index',
    vocabItemId: 'vocab-$index',
    interval: 1,
    easeFactor: 2.5,
    repetitions: lastReviewedAt == null ? 0 : 1,
    nextReviewDate: nextReviewDate ?? DateTime(2026, 10, 20),
    state: lastReviewedAt == null
        ? ReviewCardState.newCard
        : ReviewCardState.review,
    createdAt: DateTime(2026, 10, 1),
    lastReviewedAt: lastReviewedAt,
  );
}
