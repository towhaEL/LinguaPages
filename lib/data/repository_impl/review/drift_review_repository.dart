import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';

@LazySingleton(as: ReviewRepository)
class DriftReviewRepository implements ReviewRepository {
  DriftReviewRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<ReviewCardEntity>> getDueCards({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final rows =
        await (_database.select(_database.reviewCards)
              ..where(
                (card) => card.nextReviewDate.isSmallerOrEqualValue(reference),
              )
              ..orderBy([(card) => OrderingTerm.asc(card.nextReviewDate)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<ReviewCardEntity> createForVocabItem(String vocabItemId) async {
    final now = DateTime.now();
    final card = ReviewCardEntity(
      id: 'review-$vocabItemId',
      vocabItemId: vocabItemId,
      interval: 0,
      easeFactor: 2.5,
      repetitions: 0,
      nextReviewDate: now,
      state: ReviewCardState.newCard,
      createdAt: now,
    );
    await _database
        .into(_database.reviewCards)
        .insertOnConflictUpdate(
          ReviewCardsCompanion.insert(
            id: card.id,
            vocabItemId: card.vocabItemId,
            interval: Value(card.interval),
            easeFactor: Value(card.easeFactor),
            repetitions: Value(card.repetitions),
            nextReviewDate: card.nextReviewDate,
            state: Value(card.state.name),
            createdAt: card.createdAt,
          ),
        );
    return card;
  }

  @override
  Future<ReviewCardEntity> recordReview({
    required String cardId,
    required ReviewRating rating,
  }) async {
    final row = await (_database.select(
      _database.reviewCards,
    )..where((card) => card.id.equals(cardId))).getSingle();
    final current = _toEntity(row);
    final next = _schedule(current, rating, DateTime.now());
    await (_database.update(
      _database.reviewCards,
    )..where((card) => card.id.equals(cardId))).write(
      ReviewCardsCompanion(
        interval: Value(next.interval),
        easeFactor: Value(next.easeFactor),
        repetitions: Value(next.repetitions),
        nextReviewDate: Value(next.nextReviewDate),
        lastReviewedAt: Value(next.lastReviewedAt),
        state: Value(next.state.name),
      ),
    );
    return next;
  }

  @override
  Future<int> dueCount({DateTime? now}) async {
    return (await getDueCards(now: now)).length;
  }

  @override
  Future<int> totalCards() async {
    final rows = await _database.select(_database.reviewCards).get();
    return rows.length;
  }

  @override
  Future<void> deleteForVocabItem(String vocabItemId) async {
    await (_database.delete(
      _database.reviewCards,
    )..where((card) => card.vocabItemId.equals(vocabItemId))).go();
  }

  ReviewCardEntity _schedule(
    ReviewCardEntity card,
    ReviewRating rating,
    DateTime reviewedAt,
  ) {
    var easeFactor = card.easeFactor;
    var repetitions = card.repetitions;
    var interval = card.interval;
    late ReviewCardState state;
    late Duration delay;

    switch (rating) {
      case ReviewRating.again:
        easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0).toDouble();
        repetitions = 0;
        interval = 0;
        state = ReviewCardState.learning;
        delay = const Duration(minutes: 10);
      case ReviewRating.hard:
        easeFactor = (easeFactor - 0.15).clamp(1.3, 3.0).toDouble();
        repetitions += 1;
        interval = (interval * 1.2).ceil().clamp(1, 3650);
        state = ReviewCardState.review;
        delay = Duration(days: interval);
      case ReviewRating.good:
        repetitions += 1;
        interval = repetitions == 1
            ? 1
            : repetitions == 2
            ? 6
            : (interval * easeFactor).round().clamp(1, 3650);
        state = ReviewCardState.review;
        delay = Duration(days: interval);
      case ReviewRating.easy:
        easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0).toDouble();
        repetitions += 1;
        interval = repetitions == 1
            ? 4
            : (interval * easeFactor * 1.3).round().clamp(1, 3650);
        state = ReviewCardState.review;
        delay = Duration(days: interval);
    }

    return ReviewCardEntity(
      id: card.id,
      vocabItemId: card.vocabItemId,
      interval: interval,
      easeFactor: easeFactor,
      repetitions: repetitions,
      nextReviewDate: reviewedAt.add(delay),
      lastReviewedAt: reviewedAt,
      state: state,
      createdAt: card.createdAt,
    );
  }

  ReviewCardEntity _toEntity(ReviewCard row) => ReviewCardEntity(
    id: row.id,
    vocabItemId: row.vocabItemId,
    interval: row.interval,
    easeFactor: row.easeFactor,
    repetitions: row.repetitions,
    nextReviewDate: row.nextReviewDate,
    lastReviewedAt: row.lastReviewedAt,
    state: ReviewCardState.values.byName(row.state),
    createdAt: row.createdAt,
  );
}
