import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';

@singleton
class ReviewCardUseCase {
  ReviewCardUseCase(this._reviewRepository);

  final ReviewRepository _reviewRepository;

  Future<List<ReviewCardEntity>> getDueCards() {
    return _reviewRepository.getDueCards();
  }

  Future<List<ReviewCardEntity>> getAllCards() {
    return _reviewRepository.getAllCards();
  }

  Future<ReviewCardEntity> recordReview({
    required String cardId,
    required ReviewRating rating,
  }) {
    return _reviewRepository.recordReview(cardId: cardId, rating: rating);
  }

  Future<int> dueCount() {
    return _reviewRepository.dueCount();
  }
}
