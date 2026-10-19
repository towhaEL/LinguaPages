class SentenceTranslationResult {
  const SentenceTranslationResult({
    required this.source,
    required this.translation,
    required this.untranslatedWords,
  });

  final String source;
  final String translation;
  final List<String> untranslatedWords;

  bool get isComplete => untranslatedWords.isEmpty;
}

/// Translates a sentence without sending its contents off-device.
abstract interface class SentenceTranslationService {
  Future<SentenceTranslationResult> translate({
    required String sentence,
    required String sourceLanguage,
    required String targetLanguage,
  });
}
