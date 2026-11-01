/// One headword returned by the dictionary, with its meanings and the license
/// that has to be shown alongside it.
class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.meanings,
    this.phonetic,
    this.license,
    this.sourceUrls = const [],
  });

  final String word;
  final String? phonetic;
  final List<DictionaryMeaning> meanings;
  final DictionaryLicense? license;
  final List<String> sourceUrls;
}

class DictionaryMeaning {
  const DictionaryMeaning({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  final String partOfSpeech;
  final List<DictionaryDefinition> definitions;
  final List<String> synonyms;
  final List<String> antonyms;
}

class DictionaryDefinition {
  const DictionaryDefinition({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;
}

class DictionaryLicense {
  const DictionaryLicense({required this.name, required this.url});

  final String name;
  final String url;
}

/// Outcome of a lookup. Network problems are values, not exceptions, so the
/// lookup sheet can show a calm state for each of them.
sealed class DictionaryLookupResult {
  const DictionaryLookupResult();
}

final class DictionaryFound extends DictionaryLookupResult {
  const DictionaryFound(this.entries);

  final List<DictionaryEntry> entries;
}

final class DictionaryNotFound extends DictionaryLookupResult {
  const DictionaryNotFound();
}

/// The word is not cached and the dictionary could not be reached (no
/// connection, a timeout, or online lookups turned off in Settings).
final class DictionaryOffline extends DictionaryLookupResult {
  const DictionaryOffline();
}

final class DictionaryFailed extends DictionaryLookupResult {
  const DictionaryFailed();
}
