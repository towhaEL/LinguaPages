import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/lookup_word_use_case.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_state.dart';

void main() {
  late _QueuedDictionaryRepository repository;
  late DictionaryLookupCubit cubit;

  setUp(() {
    repository = _QueuedDictionaryRepository();
    cubit = DictionaryLookupCubit(LookupWordUseCase(repository));
  });

  tearDown(() => cubit.close());

  Future<List<DictionaryLookupStatus>> statuses(
    Future<void> Function() action,
  ) async {
    final seen = <DictionaryLookupStatus>[];
    final subscription = cubit.stream.listen((state) => seen.add(state.status));
    await action();
    // Stream events are delivered asynchronously after emit.
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return seen;
  }

  test('a phrase is not looked up', () async {
    expect(await statuses(() => cubit.lookup('two words')), [
      DictionaryLookupStatus.notAWord,
    ]);
    expect(repository.words, isEmpty);
  });

  test('normalizes the selection and shows the definition', () async {
    repository.results.add(
      const DictionaryFound([DictionaryEntry(word: 'book', meanings: [])]),
    );

    expect(await statuses(() => cubit.lookup(' Book, ')), [
      DictionaryLookupStatus.loading,
      DictionaryLookupStatus.found,
    ]);
    expect(repository.words, ['book']);
    expect(cubit.state.word, 'book');
    expect(cubit.state.entries.single.word, 'book');
  });

  test('maps every lookup result to a status', () async {
    final expected = {
      const DictionaryNotFound(): DictionaryLookupStatus.notFound,
      const DictionaryOffline(): DictionaryLookupStatus.offline,
      const DictionaryFailed(): DictionaryLookupStatus.failed,
    };
    for (final MapEntry(key: result, value: status) in expected.entries) {
      repository.results.add(result);
      await cubit.lookup('book');
      expect(cubit.state.status, status);
    }
  });

  test('retry looks the same word up again', () async {
    repository.results
      ..add(const DictionaryFailed())
      ..add(
        const DictionaryFound([DictionaryEntry(word: 'book', meanings: [])]),
      );
    await cubit.lookup('book');

    expect(await statuses(cubit.retry), [
      DictionaryLookupStatus.loading,
      DictionaryLookupStatus.found,
    ]);
    expect(repository.words, ['book', 'book']);
  });
}

class _QueuedDictionaryRepository implements DictionaryRepository {
  final results = <DictionaryLookupResult>[];
  final words = <String>[];

  @override
  Future<DictionaryLookupResult> lookup(String word) async {
    words.add(word);
    return results.removeAt(0);
  }

  @override
  Future<void> clearCache() async {}
}
