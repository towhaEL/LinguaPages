import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';
import 'package:lingua_pages/data/remapper/dictionary_remapper.dart';

/// Shape of `GET /api/v2/entries/en/hello` from dictionaryapi.dev.
const helloResponse = '''
[
  {
    "word": "hello",
    "phonetics": [
      {"audio": "https://api.dictionaryapi.dev/media/pronunciations/en/hello-au.mp3"},
      {"text": "/həˈləʊ/", "audio": ""}
    ],
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [
          {"definition": "\\"Hello!\\" or an equivalent greeting.", "synonyms": [], "antonyms": []}
        ],
        "synonyms": ["greeting"],
        "antonyms": []
      },
      {
        "partOfSpeech": "interjection",
        "definitions": [
          {
            "definition": "A greeting (salutation) said when meeting someone.",
            "synonyms": [],
            "antonyms": [],
            "example": "Hello, everyone."
          }
        ],
        "synonyms": [],
        "antonyms": ["bye", "goodbye"]
      }
    ],
    "license": {"name": "CC BY-SA 3.0", "url": "https://creativecommons.org/licenses/by-sa/3.0"},
    "sourceUrls": ["https://en.wiktionary.org/wiki/hello"]
  }
]
''';

void main() {
  test('maps the API response to domain entries', () {
    final models = (jsonDecode(helloResponse) as List<dynamic>)
        .map(
          (json) => DictionaryEntryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    final entry = models.single.toEntity();

    expect(entry.word, 'hello');
    // No top-level phonetic: falls back to the first non-empty text.
    expect(entry.phonetic, '/həˈləʊ/');
    expect(entry.meanings.map((meaning) => meaning.partOfSpeech), [
      'noun',
      'interjection',
    ]);
    expect(entry.meanings.first.synonyms, ['greeting']);
    expect(entry.meanings.last.antonyms, ['bye', 'goodbye']);
    expect(entry.meanings.last.definitions.single.example, 'Hello, everyone.');
    expect(entry.meanings.first.definitions.single.example, isNull);
    expect(entry.license?.name, 'CC BY-SA 3.0');
    expect(entry.sourceUrls, ['https://en.wiktionary.org/wiki/hello']);
  });

  test('tolerates missing optional lists and license', () {
    final entry = DictionaryEntryModel.fromJson(const {
      'word': 'sparse',
      'phonetic': '/spɑːs/',
      'meanings': [
        {
          'partOfSpeech': 'adjective',
          'definitions': [
            {'definition': 'Having widely spaced intervals.'},
          ],
        },
      ],
    }).toEntity();

    expect(entry.phonetic, '/spɑːs/');
    expect(entry.license, isNull);
    expect(entry.sourceUrls, isEmpty);
    expect(entry.meanings.single.synonyms, isEmpty);
  });

  test('survives a cache round trip through toJson', () {
    final model = DictionaryEntryModel.fromJson(
      (jsonDecode(helloResponse) as List<dynamic>).single
          as Map<String, dynamic>,
    );

    final restored = DictionaryEntryModel.fromJson(
      jsonDecode(jsonEncode(model.toJson())) as Map<String, dynamic>,
    ).toEntity();

    expect(restored.meanings, hasLength(2));
    expect(
      restored.license?.url,
      'https://creativecommons.org/licenses/by-sa/3.0',
    );
  });
}
