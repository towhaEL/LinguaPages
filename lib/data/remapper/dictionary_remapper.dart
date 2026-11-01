import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';

extension DictionaryEntryModelRemapper on DictionaryEntryModel {
  DictionaryEntry toEntity() => DictionaryEntry(
    word: word,
    phonetic: _phonetic,
    meanings: [for (final meaning in meanings) meaning.toEntity()],
    license: license == null
        ? null
        : DictionaryLicense(name: license!.name, url: license!.url),
    sourceUrls: sourceUrls,
  );

  /// The top-level `phonetic` is often missing; fall back to the first
  /// non-empty `phonetics[].text`.
  String? get _phonetic {
    if (phonetic?.trim().isNotEmpty ?? false) return phonetic!.trim();
    for (final item in phonetics) {
      final text = item.text?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}

extension MeaningModelRemapper on MeaningModel {
  DictionaryMeaning toEntity() => DictionaryMeaning(
    partOfSpeech: partOfSpeech,
    definitions: [
      for (final definition in definitions)
        DictionaryDefinition(
          definition: definition.definition,
          example: definition.example,
          synonyms: definition.synonyms,
          antonyms: definition.antonyms,
        ),
    ],
    synonyms: synonyms,
    antonyms: antonyms,
  );
}
