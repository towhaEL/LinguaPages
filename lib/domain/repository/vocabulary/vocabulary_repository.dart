import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';

/// Manages saved vocabulary items.
abstract interface class VocabularyRepository {
  Future<List<VocabItemEntity>> getAll();

  Future<List<VocabItemEntity>> getByBookId(String bookId);

  Future<List<VocabItemEntity>> search(String query);

  Future<VocabItemEntity> save(VocabItemEntity item);

  Future<void> delete(String vocabItemId);

  Future<int> totalCount();
}
