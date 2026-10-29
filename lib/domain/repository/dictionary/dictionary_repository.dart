class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.definition,
    this.partOfSpeech,
    this.example,
  });

  final String word;
  final String definition;
  final String? partOfSpeech;
  final String? example;
}

abstract interface class DictionaryRepository {
  Future<DictionaryEntry?> lookup(String word);
}
