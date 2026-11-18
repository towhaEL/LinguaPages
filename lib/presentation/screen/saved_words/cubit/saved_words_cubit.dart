import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/domain/entity/vocabulary/saved_word_entity.dart';
import 'package:lingua_pages/domain/repository/vocabulary/saved_word_repository.dart';

enum SavedWordsStatus { loading, success, failure }

class SavedWordsState {
  const SavedWordsState({
    this.status = SavedWordsStatus.loading,
    this.words = const [],
    this.query = '',
  });

  final SavedWordsStatus status;

  /// Every saved word, newest first.
  final List<SavedWordEntity> words;
  final String query;

  /// [words] matching [query] by word or definition.
  List<SavedWordEntity> get visible {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return words;
    return [
      for (final word in words)
        if (word.word.toLowerCase().contains(needle) ||
            (word.definition?.toLowerCase().contains(needle) ?? false))
          word,
    ];
  }

  SavedWordsState copyWith({
    SavedWordsStatus? status,
    List<SavedWordEntity>? words,
    String? query,
  }) {
    return SavedWordsState(
      status: status ?? this.status,
      words: words ?? this.words,
      query: query ?? this.query,
    );
  }
}

@injectable
class SavedWordsCubit extends Cubit<SavedWordsState> {
  SavedWordsCubit(this._repository, this._logger)
    : super(const SavedWordsState());

  final SavedWordRepository _repository;
  final Logger _logger;

  Future<void> load() async {
    try {
      final words = await _repository.getAll();
      emit(state.copyWith(status: SavedWordsStatus.success, words: words));
    } catch (error, stackTrace) {
      _logger.e(
        'Unable to load saved words',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(status: SavedWordsStatus.failure));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  /// Removes [word]; false if it could not be.
  Future<bool> delete(SavedWordEntity word) async {
    try {
      await _repository.delete(word.word);
    } catch (_) {
      return false;
    }
    emit(
      state.copyWith(
        words: [
          for (final saved in state.words)
            if (saved.id != word.id) saved,
        ],
      ),
    );
    return true;
  }

  /// Puts back a word just deleted.
  Future<void> restore(SavedWordEntity word) async {
    try {
      await _repository.save(word);
    } catch (_) {
      return;
    }
    await load();
  }
}
