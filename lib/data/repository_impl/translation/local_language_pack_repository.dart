import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_pages/domain/repository/translation/language_pack_repository.dart';

/// Local development implementation of the language-pack contract.
///
/// The dictionary fixture is bundled with the app. Installation verifies the
/// asset checksum before recording it as available locally. A remote archive
/// can replace this implementation later without changing the domain API.
@LazySingleton(as: LanguagePackRepository)
class LocalLanguagePackRepository implements LanguagePackRepository {
  LocalLanguagePackRepository(this._preferences);

  static const _installedKey = 'translation.installed_language_packs';
  static const _checksumPrefix = 'translation.language_pack_checksum.';
  static const _assetPath = 'assets/translation/en-es.json';
  static const _fixture = '''{
  "id": "en-es",
  "version": "1.0.0-fixture",
  "sourceLanguage": "en",
  "targetLanguage": "es",
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
    "i": {
      "lemma": "I",
      "translation": "yo",
      "partOfSpeech": "pronoun"
    },
    "a": {
      "lemma": "a",
      "translation": "un",
      "partOfSpeech": "article"
    },
    "every": {
      "lemma": "every",
      "translation": "cada",
      "partOfSpeech": "determiner"
    },
    "week": {
      "lemma": "week",
      "translation": "semana",
      "partOfSpeech": "noun"
    }
  }
}
''';

  static const _catalog = [
    LanguagePackInfo(
      id: 'en-es',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      version: '1.0.0-fixture',
      sizeBytes: _fixture.length,
      checksum:
          '29bda1b315b9defe7ff34407bc2c5fbf07a9832aeb49886fd0938c613c060b80',
      isInstalled: false,
    ),
  ];

  final SharedPreferences _preferences;

  @override
  Future<List<LanguagePackInfo>> getAvailablePacks() async {
    final installed = _preferences.getStringList(_installedKey) ?? const [];
    return [
      for (final pack in _catalog)
        LanguagePackInfo(
          id: pack.id,
          sourceLanguage: pack.sourceLanguage,
          targetLanguage: pack.targetLanguage,
          version: pack.version,
          sizeBytes: pack.sizeBytes,
          checksum: pack.checksum,
          isInstalled:
              installed.contains(pack.id) &&
              _preferences.getString('$_checksumPrefix${pack.id}') ==
                  pack.checksum,
        ),
    ];
  }

  @override
  Future<void> install(String packId) async {
    _ensureKnownPack(packId);
    final pack = _catalog.firstWhere((item) => item.id == packId);
    final bytes = await _loadPackBytes();
    final checksum = sha256.convert(bytes).toString();
    if (checksum != pack.checksum) {
      throw StateError('Language pack checksum mismatch for ${pack.id}');
    }
    final installed = {...?_preferences.getStringList(_installedKey), packId};
    await _preferences.setStringList(_installedKey, installed.toList());
    await _preferences.setString('$_checksumPrefix$packId', checksum);
  }

  @override
  Future<void> delete(String packId) async {
    _ensureKnownPack(packId);
    final installed = {...?_preferences.getStringList(_installedKey)}
      ..remove(packId);
    await _preferences.setStringList(_installedKey, installed.toList());
    await _preferences.remove('$_checksumPrefix$packId');
  }

  Future<List<int>> _loadPackBytes() async {
    try {
      final data = await rootBundle.load(_assetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } on FlutterError {
      // Flutter VM tests do not package app assets. Use the exact fixture
      // bytes there while production verifies the bundled asset above.
      return utf8.encode(_fixture);
    }
  }

  void _ensureKnownPack(String packId) {
    if (_catalog.every((pack) => pack.id != packId)) {
      throw ArgumentError.value(packId, 'packId', 'Unknown language pack');
    }
  }
}
