import 'package:lingua_pages/domain/entity/vocabulary/saved_word_entity.dart';

/// Words saved from the dictionary lookup, across all books.
abstract interface class SavedWordRepository {
  /// Every saved word, newest first.
  Future<List<SavedWordEntity>> getAll();

  /// Words saved while reading [bookId], newest first.
  Future<List<SavedWordEntity>> getByBookId(String bookId);

  Future<bool> isSaved(String word);

  /// Saves [word], replacing an earlier save of the same word.
  Future<void> save(SavedWordEntity word);

  Future<void> delete(String word);
}
