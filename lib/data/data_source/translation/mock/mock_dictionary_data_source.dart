import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';

/// Bundled dictionary source used until licensed data is selected.
///
/// The JSON asset is deliberately small in this development build, but the
/// loading contract is the same one a production language pack can use. A
/// fallback keeps Flutter VM unit tests deterministic because test assets are
/// not loaded by [rootBundle].
@LazySingleton(as: DictionaryRepository)
class MockDictionaryDataSource implements DictionaryRepository {
  MockDictionaryDataSource();

  static const _assetPath = 'assets/translation/en-es.json';
  static const _fixture = '''{
  "entries": {
    "book": {
      "lemma": "book",
      "translation": "libro",
      "partOfSpeech": "noun",
      "example": "I read a book every week."
    },
    "read": {
      "lemma": "read",
      "translation": "leer",
      "partOfSpeech": "verb",
      "example": "She likes to read before bed."
    },
    "i": {"lemma": "I", "translation": "yo", "partOfSpeech": "pronoun"},
    "a": {"lemma": "a", "translation": "un", "partOfSpeech": "article"},
    "every": {
      "lemma": "every",
      "translation": "cada",
      "partOfSpeech": "determiner"
    },
    "week": {"lemma": "week", "translation": "semana", "partOfSpeech": "noun"}
  }
}
''';

  final AssetBundle _bundle = rootBundle;
  late final Future<Map<String, DictionaryEntry>> _entries = _loadEntries();

  @override
  Future<DictionaryEntry?> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (sourceLanguage != 'en' || targetLanguage != 'es') {
      return null;
    }

    final entries = await _entries;
    return entries[word.trim().toLowerCase()];
  }

  Future<Map<String, DictionaryEntry>> _loadEntries() async {
    String raw;
    try {
      raw = await _bundle.loadString(_assetPath);
    } on FlutterError {
      raw = _fixture;
    }

    final document = jsonDecode(raw) as Map<String, dynamic>;
    final entries = document['entries'] as Map<String, dynamic>;
    return {
      for (final entry in entries.entries)
        entry.key: _toDictionaryEntry(entry.value as Map<String, dynamic>),
    };
  }

  DictionaryEntry _toDictionaryEntry(Map<String, dynamic> raw) {
    return DictionaryEntry(
      lemma: raw['lemma'] as String,
      translation: raw['translation'] as String,
      partOfSpeech: raw['partOfSpeech'] as String?,
      example: raw['example'] as String?,
    );
  }
}
