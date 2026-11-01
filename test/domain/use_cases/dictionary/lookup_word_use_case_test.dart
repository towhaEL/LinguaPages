import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/lookup_word_use_case.dart';

void main() {
  group('LookupWordUseCase.normalize', () {
    final cases = {
      ' Book ': 'book',
      'HELLO!': 'hello',
      '“reading,”': 'reading',
      "author's": 'author',
      'author’s.': 'author',
      "don't": "don't",
      'well-known': 'well-known',
      'Éclair': 'éclair',
      '(1984)': '1984',
    };
    for (final MapEntry(key: input, value: expected) in cases.entries) {
      test('"$input" becomes "$expected"', () {
        expect(LookupWordUseCase.normalize(input), expected);
      });
    }

    for (final input in ['', '   ', '...', 'two words', 'line\nbreak']) {
      test('rejects ${input.isEmpty ? 'empty input' : '"$input"'}', () {
        expect(LookupWordUseCase.normalize(input), isNull);
      });
    }
  });

  test('passes the word to the repository', () async {
    final repository = _RecordingDictionaryRepository();

    final result = await LookupWordUseCase(repository).execute('book');

    expect(result, isA<DictionaryNotFound>());
    expect(repository.words, ['book']);
  });
}

class _RecordingDictionaryRepository implements DictionaryRepository {
  final words = <String>[];

  @override
  Future<DictionaryLookupResult> lookup(String word) async {
    words.add(word);
    return const DictionaryNotFound();
  }

  @override
  Future<void> clearCache() async {}
}
