import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/vocabulary/saved_word_entity.dart';
import 'package:lingua_pages/domain/repository/vocabulary/saved_word_repository.dart';

@LazySingleton(as: SavedWordRepository)
class DriftSavedWordRepository implements SavedWordRepository {
  DriftSavedWordRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<SavedWordEntity>> getAll() async {
    final rows = await (_database.select(
      _database.savedWords,
    )..orderBy([(word) => OrderingTerm.desc(word.createdAt)])).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<SavedWordEntity>> getByBookId(String bookId) async {
    final rows =
        await (_database.select(_database.savedWords)
              ..where((word) => word.bookId.equals(bookId))
              ..orderBy([(word) => OrderingTerm.desc(word.createdAt)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<bool> isSaved(String word) async {
    final row =
        await (_database.select(_database.savedWords)
              ..where((row) => row.id.equals(SavedWordEntity.normalize(word))))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> save(SavedWordEntity word) async {
    await _database
        .into(_database.savedWords)
        .insertOnConflictUpdate(
          SavedWordsCompanion.insert(
            id: word.id,
            word: word.word.trim(),
            definition: Value(word.definition),
            partOfSpeech: Value(word.partOfSpeech),
            phonetic: Value(word.phonetic),
            bookId: Value(word.bookId),
            bookTitle: Value(word.bookTitle),
            createdAt: word.createdAt,
          ),
        );
  }

  @override
  Future<void> delete(String word) async {
    await (_database.delete(
      _database.savedWords,
    )..where((row) => row.id.equals(SavedWordEntity.normalize(word)))).go();
  }

  SavedWordEntity _toEntity(SavedWord row) => SavedWordEntity(
    word: row.word,
    definition: row.definition,
    partOfSpeech: row.partOfSpeech,
    phonetic: row.phonetic,
    bookId: row.bookId,
    bookTitle: row.bookTitle,
    createdAt: row.createdAt,
  );
}
