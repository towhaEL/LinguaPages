import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';

enum DictionaryLookupStatus {
  loading,
  found,
  notFound,
  offline,
  failed,

  /// The selection was empty or more than one word, so nothing was looked up.
  notAWord,
}

class DictionaryLookupState {
  const DictionaryLookupState({
    this.status = DictionaryLookupStatus.loading,
    this.word,
    this.entries = const [],
  });

  final DictionaryLookupStatus status;

  /// The normalized word, or null when the selection was not a single word.
  final String? word;
  final List<DictionaryEntry> entries;
}
