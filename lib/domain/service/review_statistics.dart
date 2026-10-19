import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';

class ReviewStatistics {
  const ReviewStatistics({
    required this.totalCards,
    required this.reviewedCards,
    required this.dueCards,
    required this.activeDays,
    required this.currentStreak,
  });

  factory ReviewStatistics.fromCards(
    Iterable<ReviewCardEntity> cards, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final cardList = cards.toList(growable: false);
    final reviewedDates = {
      for (final card in cardList)
        if (card.lastReviewedAt != null) _dateKey(card.lastReviewedAt!),
    };
    final dueCards = cardList.where((card) => card.isDue(reference)).length;
    var day = DateTime(reference.year, reference.month, reference.day);
    if (!reviewedDates.contains(_dateKey(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var currentStreak = 0;
    while (reviewedDates.contains(_dateKey(day))) {
      currentStreak++;
      day = day.subtract(const Duration(days: 1));
    }

    return ReviewStatistics(
      totalCards: cardList.length,
      reviewedCards: cardList
          .where((card) => card.lastReviewedAt != null)
          .length,
      dueCards: dueCards,
      activeDays: reviewedDates.length,
      currentStreak: currentStreak,
    );
  }

  final int totalCards;
  final int reviewedCards;
  final int dueCards;
  final int activeDays;
  final int currentStreak;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
