import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/library/collection_entity.dart';
import 'package:lingua_pages/domain/repository/library/collection_repository.dart';

@LazySingleton(as: CollectionRepository)
class DriftCollectionRepository implements CollectionRepository {
  DriftCollectionRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<CollectionEntity>> getAll() async {
    final collections = await (_database.select(
      _database.collections,
    )..orderBy([(item) => OrderingTerm.asc(item.name.lower())])).get();
    final members = await _database.select(_database.bookCollections).get();
    return [
      for (final collection in collections)
        CollectionEntity(
          id: collection.id,
          name: collection.name,
          bookIds: {
            for (final member in members)
              if (member.collectionId == collection.id) member.bookId,
          },
        ),
    ];
  }

  @override
  Future<CollectionEntity> create(String name) async {
    final now = DateTime.now();
    final collection = CollectionEntity(
      id: 'collection-${now.microsecondsSinceEpoch}',
      name: _validName(name),
    );
    await _database
        .into(_database.collections)
        .insert(
          CollectionsCompanion.insert(
            id: collection.id,
            name: collection.name,
            createdAt: now,
          ),
        );
    return collection;
  }

  @override
  Future<void> rename({required String id, required String name}) =>
      (_database.update(_database.collections)
            ..where((item) => item.id.equals(id)))
          .write(CollectionsCompanion(name: Value(_validName(name))));

  @override
  Future<void> delete(String id) => _database.transaction(() async {
    await (_database.delete(
      _database.bookCollections,
    )..where((item) => item.collectionId.equals(id))).go();
    await (_database.delete(
      _database.collections,
    )..where((item) => item.id.equals(id))).go();
  });

  @override
  Future<void> setBookCollections({
    required String bookId,
    required Set<String> collectionIds,
  }) => _database.transaction(() async {
    await (_database.delete(
      _database.bookCollections,
    )..where((item) => item.bookId.equals(bookId))).go();
    for (final collectionId in collectionIds) {
      await _database
          .into(_database.bookCollections)
          .insert(
            BookCollectionsCompanion.insert(
              bookId: bookId,
              collectionId: collectionId,
            ),
          );
    }
  });

  String _validName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    return trimmed;
  }
}
