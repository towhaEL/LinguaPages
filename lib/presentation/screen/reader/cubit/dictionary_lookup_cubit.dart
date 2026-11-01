import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/lookup_word_use_case.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_state.dart';

@injectable
class DictionaryLookupCubit extends Cubit<DictionaryLookupState> {
  DictionaryLookupCubit(this._lookupWord)
    : super(const DictionaryLookupState());

  final LookupWordUseCase _lookupWord;

  /// Looks up the word in [selection], or reports that it is not one word.
  Future<void> lookup(String selection) async {
    final word = LookupWordUseCase.normalize(selection);
    if (word == null) {
      emit(
        const DictionaryLookupState(status: DictionaryLookupStatus.notAWord),
      );
      return;
    }
    await _run(word);
  }

  Future<void> retry() async {
    final word = state.word;
    if (word != null) await _run(word);
  }

  Future<void> _run(String word) async {
    emit(DictionaryLookupState(word: word));
    final result = await _lookupWord.execute(word);
    if (isClosed) return;
    emit(switch (result) {
      DictionaryFound(:final entries) => DictionaryLookupState(
        status: DictionaryLookupStatus.found,
        word: word,
        entries: entries,
      ),
      DictionaryNotFound() => DictionaryLookupState(
        status: DictionaryLookupStatus.notFound,
        word: word,
      ),
      DictionaryOffline() => DictionaryLookupState(
        status: DictionaryLookupStatus.offline,
        word: word,
      ),
      DictionaryFailed() => DictionaryLookupState(
        status: DictionaryLookupStatus.failed,
        word: word,
      ),
    });
  }
}
