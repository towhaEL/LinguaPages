/// A word the reader saved from the dictionary lookup to study later.
class SavedWordEntity {
  const SavedWordEntity({
    required this.word,
    required this.createdAt,
    this.definition,
    this.partOfSpeech,
    this.phonetic,
    this.bookId,
    this.bookTitle,
  });

  /// The word as looked up; [id] is its normalized form.
  final String word;

  /// The dictionary's first definition, or null when it had none (offline,
  /// not found).
  final String? definition;
  final String? partOfSpeech;
  final String? phonetic;

  /// The book it was saved from.
  final String? bookId;
  final String? bookTitle;
  final DateTime createdAt;

  /// One saved entry per word, whatever its case.
  String get id => normalize(word);

  static String normalize(String word) => word.trim().toLowerCase();
}
