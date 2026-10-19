class DictionaryEntry {
  const DictionaryEntry({
    required this.lemma,
    required this.translation,
    this.partOfSpeech,
    this.example,
  });

  final String lemma;
  final String translation;
  final String? partOfSpeech;
  final String? example;
}

abstract interface class DictionaryRepository {
  Future<DictionaryEntry?> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  });
}
