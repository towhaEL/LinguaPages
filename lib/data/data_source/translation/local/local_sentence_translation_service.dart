import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';
import 'package:lingua_pages/domain/service/lemmatizer.dart';
import 'package:lingua_pages/domain/service/sentence_translation_service.dart';

@LazySingleton(as: SentenceTranslationService)
class LocalSentenceTranslationService implements SentenceTranslationService {
  LocalSentenceTranslationService(this._dictionary, this._lemmatizer);

  final DictionaryRepository _dictionary;
  final Lemmatizer _lemmatizer;

  @override
  Future<SentenceTranslationResult> translate({
    required String sentence,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (sentence.trim().isEmpty) {
      return SentenceTranslationResult(
        source: sentence,
        translation: sentence,
        untranslatedWords: const [],
      );
    }

    final untranslated = <String>[];
    final translated = await _replaceWords(
      sentence,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      untranslatedWords: untranslated,
    );

    return SentenceTranslationResult(
      source: sentence,
      translation: translated,
      untranslatedWords: untranslated,
    );
  }

  Future<String> _replaceWords(
    String sentence, {
    required String sourceLanguage,
    required String targetLanguage,
    required List<String> untranslatedWords,
  }) async {
    final parts = RegExp(r'[A-Za-zÀ-ÿ]+|[^A-Za-zÀ-ÿ]+').allMatches(sentence);
    final output = StringBuffer();

    for (final part in parts) {
      final token = part.group(0)!;
      if (!RegExp(r'^[A-Za-zÀ-ÿ]+$').hasMatch(token)) {
        output.write(token);
        continue;
      }

      final lemma = await _lemmatizer.lemmatize(
        word: token,
        language: sourceLanguage,
      );
      final entry = await _dictionary.lookup(
        word: lemma,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      if (entry == null) {
        untranslatedWords.add(token);
        output.write(token);
      } else {
        output.write(_matchCase(entry.translation, token));
      }
    }

    return output.toString();
  }

  String _matchCase(String translation, String source) {
    if (source.isNotEmpty && source[0] == source[0].toUpperCase()) {
      return translation.isEmpty
          ? translation
          : '${translation[0].toUpperCase()}${translation.substring(1)}';
    }
    return translation;
  }
}
