import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/lookup_word_use_case.dart';

void main() {
  test('caches normalized lookup responses, including misses', () async {
    final repository = _CountingDictionaryRepository();
    final useCase = LookupWordUseCase(repository);

    final first = await useCase.execute(' Book ');
    final second = await useCase.execute('book');
    final firstMiss = await useCase.execute('unknown');
    final secondMiss = await useCase.execute('unknown');

    expect(first?.definition, 'A bound collection of pages.');
    expect(second?.definition, 'A bound collection of pages.');
    expect(firstMiss, isNull);
    expect(secondMiss, isNull);
    expect(repository.lookupCount, 2);
  });

  test('retries a lookup after a provider error', () async {
    final repository = _CountingDictionaryRepository(failFirstLookup: true);
    final useCase = LookupWordUseCase(repository);

    await expectLater(useCase.execute('book'), throwsStateError);
    final entry = await useCase.execute('book');

    expect(entry?.word, 'book');
    expect(repository.lookupCount, 2);
  });
}

class _CountingDictionaryRepository implements DictionaryRepository {
  _CountingDictionaryRepository({this.failFirstLookup = false});

  final bool failFirstLookup;
  var lookupCount = 0;

  @override
  Future<DictionaryEntry?> lookup(String word) async {
    lookupCount++;
    if (failFirstLookup && lookupCount == 1) {
      throw StateError('Temporary provider error');
    }
    return word == 'book'
        ? const DictionaryEntry(
            word: 'book',
            definition: 'A bound collection of pages.',
          )
        : null;
  }
}
