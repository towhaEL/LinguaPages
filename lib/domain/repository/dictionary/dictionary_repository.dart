import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';

abstract interface class DictionaryRepository {
  /// Looks up an already-normalized single [word]. Never throws for network
  /// failures; they are returned as [DictionaryOffline] or [DictionaryFailed].
  Future<DictionaryLookupResult> lookup(String word);

  /// Removes every cached definition, in memory and on disk.
  Future<void> clearCache();
}
