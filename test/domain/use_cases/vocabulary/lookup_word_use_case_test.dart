import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/repository/translation/dictionary_repository.dart';
import 'package:lingua_pages/domain/use_cases/vocabulary/lookup_word_use_case.dart';

void main() {
  test('caches normalized lookup responses, including misses', () async {
    final repository = _CountingDictionaryRepository();
    final useCase = LookupWordUseCase(repository);

    final first = await useCase.execute(
      word: ' Book ',
      sourceLanguage: 'EN',
      targetLanguage: 'es',
    );
    final second = await useCase.execute(
      word: 'book',
      sourceLanguage: 'en',
      targetLanguage: 'ES',
    );
    final firstMiss = await useCase.execute(
      word: 'unknown',
      sourceLanguage: 'en',
      targetLanguage: 'es',
    );
    final secondMiss = await useCase.execute(
      word: 'unknown',
      sourceLanguage: 'en',
      targetLanguage: 'es',
    );

    expect(first?.translation, 'libro');
    expect(second?.translation, 'libro');
    expect(firstMiss, isNull);
    expect(secondMiss, isNull);
    expect(repository.lookupCount, 2);
  });

  test('retries a lookup after a provider error', () async {
    final repository = _CountingDictionaryRepository(failFirstLookup: true);
    final useCase = LookupWordUseCase(repository);

    await expectLater(
      useCase.execute(word: 'book', sourceLanguage: 'en', targetLanguage: 'es'),
      throwsStateError,
    );
    final entry = await useCase.execute(
      word: 'book',
      sourceLanguage: 'en',
      targetLanguage: 'es',
    );

    expect(entry?.translation, 'libro');
    expect(repository.lookupCount, 2);
  });
}

class _CountingDictionaryRepository implements DictionaryRepository {
  _CountingDictionaryRepository({this.failFirstLookup = false});

  final bool failFirstLookup;
  var lookupCount = 0;

  @override
  Future<DictionaryEntry?> lookup({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    lookupCount++;
    if (failFirstLookup && lookupCount == 1) {
      throw StateError('Temporary provider error');
    }
    return word == 'book'
        ? const DictionaryEntry(lemma: 'book', translation: 'libro')
        : null;
  }
}
