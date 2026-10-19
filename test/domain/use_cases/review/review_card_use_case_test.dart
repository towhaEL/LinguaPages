import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/entity/review/review_history_entry.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';
import 'package:lingua_pages/domain/use_cases/review/review_card_use_case.dart';

void main() {
  late _FakeReviewRepository repository;
  late ReviewCardUseCase useCase;

  setUp(() {
    repository = _FakeReviewRepository();
    useCase = ReviewCardUseCase(repository);
  });

  test('getDueCards delegates to the review repository', () async {
    final cards = [_card()];
    repository.dueCards = cards;

    expect(await useCase.getDueCards(), cards);
    expect(repository.dueCardsCalls, 1);
  });

  test('getAllCards delegates to the review repository', () async {
    final cards = [_card()];
    repository.allCards = cards;

    expect(await useCase.getAllCards(), cards);
    expect(repository.allCardsCalls, 1);
  });

  test('getHistory forwards the requested limit', () async {
    final history = [_history()];
    repository.history = history;

    expect(await useCase.getHistory(limit: 25), history);
    expect(repository.historyLimit, 25);
  });

  test('recordReview forwards card id and rating', () async {
    final card = _card();
    repository.reviewedCard = card;

    expect(
      await useCase.recordReview(
        cardId: 'card-1',
        rating: ReviewRating.good,
      ),
      card,
    );
    expect(repository.reviewedCardId, 'card-1');
    expect(repository.reviewedRating, ReviewRating.good);
  });

  test('dueCount delegates to the review repository', () async {
    repository.dueCardsCount = 7;

    expect(await useCase.dueCount(), 7);
    expect(repository.dueCountCalls, 1);
  });
}

ReviewCardEntity _card() {
  return ReviewCardEntity(
    id: 'card-1',
    vocabItemId: 'vocab-1',
    interval: 1,
    easeFactor: 2.5,
    repetitions: 1,
    nextReviewDate: DateTime(2026, 10, 20),
    state: ReviewCardState.learning,
    createdAt: DateTime(2026, 10, 1),
  );
}

ReviewHistoryItem _history() {
  return ReviewHistoryItem(
    id: 'history-1',
    reviewCardId: 'card-1',
    vocabItemId: 'vocab-1',
    rating: ReviewRating.good,
    interval: 1,
    easeFactor: 2.5,
    repetitions: 1,
    reviewedAt: DateTime(2026, 10, 20),
  );
}

class _FakeReviewRepository implements ReviewRepository {
  List<ReviewCardEntity> dueCards = [];
  List<ReviewCardEntity> allCards = [];
  List<ReviewHistoryItem> history = [];
  ReviewCardEntity? reviewedCard;
  ReviewRating? reviewedRating;
  String? reviewedCardId;
  int? historyLimit;
  int dueCardsCount = 0;
  int dueCardsCalls = 0;
  int allCardsCalls = 0;
  int dueCountCalls = 0;

  @override
  Future<List<ReviewCardEntity>> getDueCards({DateTime? now}) async {
    dueCardsCalls++;
    return dueCards;
  }

  @override
  Future<List<ReviewCardEntity>> getAllCards() async {
    allCardsCalls++;
    return allCards;
  }

  @override
  Future<ReviewCardEntity> createForVocabItem(String vocabItemId) async =>
      _card();

  @override
  Future<ReviewCardEntity> recordReview({
    required String cardId,
    required ReviewRating rating,
  }) async {
    reviewedCardId = cardId;
    reviewedRating = rating;
    return reviewedCard!;
  }

  @override
  Future<int> dueCount({DateTime? now}) async {
    dueCountCalls++;
    return dueCardsCount;
  }

  @override
  Future<int> totalCards() async => allCards.length;

  @override
  Future<List<ReviewHistoryItem>> getHistory({int limit = 100}) async {
    historyLimit = limit;
    return history;
  }

  @override
  Future<void> deleteForVocabItem(String vocabItemId) async {}
}
