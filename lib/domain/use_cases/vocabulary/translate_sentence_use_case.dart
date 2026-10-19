import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/sentence_translation_service.dart';

@singleton
class TranslateSentenceUseCase {
  TranslateSentenceUseCase(this._service);

  final SentenceTranslationService _service;

  Future<SentenceTranslationResult> execute({
    required String sentence,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return _service.translate(
      sentence: sentence,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }
}
