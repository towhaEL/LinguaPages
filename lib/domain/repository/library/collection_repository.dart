import 'package:lingua_pages/domain/entity/library/collection_entity.dart';

abstract interface class CollectionRepository {
  /// Every collection with its member book ids, by name.
  Future<List<CollectionEntity>> getAll();

  Future<CollectionEntity> create(String name);

  Future<void> rename({required String id, required String name});

  /// Removes the collection; its books stay in the library.
  Future<void> delete(String id);

  /// Puts [bookId] in exactly [collectionIds].
  Future<void> setBookCollections({
    required String bookId,
    required Set<String> collectionIds,
  });
}
