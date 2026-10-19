import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';

@LazySingleton(as: VocabularyRepository)
class DriftVocabularyRepository implements VocabularyRepository {
  DriftVocabularyRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<List<VocabItemEntity>> getAll() async {
    final rows = await (_database.select(
      _database.vocabItems,
    )..orderBy([(item) => OrderingTerm.desc(item.createdAt)])).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<VocabItemEntity>> getByBookId(String bookId) async {
    final rows =
        await (_database.select(_database.vocabItems)
              ..where((item) => item.bookId.equals(bookId))
              ..orderBy([(item) => OrderingTerm.desc(item.createdAt)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<VocabItemEntity>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final items = await getAll();
    if (normalizedQuery.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.word.toLowerCase().contains(normalizedQuery) ||
              item.lemma.toLowerCase().contains(normalizedQuery) ||
              item.translation.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  @override
  Future<VocabItemEntity> save(VocabItemEntity item) async {
    await _database
        .into(_database.vocabItems)
        .insertOnConflictUpdate(
          VocabItemsCompanion.insert(
            id: item.id,
            word: item.word,
            lemma: item.lemma,
            sourceSentence: Value(item.sourceSentence),
            translation: item.translation,
            bookId: Value(item.bookId),
            locatorJson: Value(
              item.locator == null ? null : jsonEncode(item.locator!.toJson()),
            ),
            sourceLanguage: item.sourceLanguage,
            targetLanguage: item.targetLanguage,
            notes: Value(item.notes),
            createdAt: item.createdAt,
          ),
        );
    return item;
  }

  @override
  Future<void> delete(String vocabItemId) async {
    await (_database.delete(
      _database.vocabItems,
    )..where((item) => item.id.equals(vocabItemId))).go();
  }

  @override
  Future<int> totalCount() async {
    final rows = await _database.select(_database.vocabItems).get();
    return rows.length;
  }

  VocabItemEntity _toEntity(VocabItem row) => VocabItemEntity(
    id: row.id,
    word: row.word,
    lemma: row.lemma,
    sourceSentence: row.sourceSentence,
    translation: row.translation,
    bookId: row.bookId,
    locator: row.locatorJson == null
        ? null
        : DocumentLocator.fromJson(
            jsonDecode(row.locatorJson!) as Map<String, dynamic>,
          ),
    sourceLanguage: row.sourceLanguage,
    targetLanguage: row.targetLanguage,
    notes: row.notes,
    createdAt: row.createdAt,
  );
}
