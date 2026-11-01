import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/repository/dictionary/dictionary_repository.dart';

@singleton
class LookupWordUseCase {
  LookupWordUseCase(this._dictionaryRepository);

  final DictionaryRepository _dictionaryRepository;

  static final _edgePunctuation = RegExp(
    r"^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$",
    unicode: true,
  );
  static final _possessive = RegExp(r"['’]s$");
  static final _whitespace = RegExp(r'\s');

  /// Turns a selection into the word sent to the dictionary, or `null` when
  /// the selection is empty or more than one word.
  static String? normalize(String selection) {
    final trimmed = selection.trim();
    if (trimmed.isEmpty || trimmed.contains(_whitespace)) return null;
    final word = trimmed
        .toLowerCase()
        .replaceAll(_edgePunctuation, '')
        .replaceFirst(_possessive, '')
        .replaceAll(_edgePunctuation, '');
    return word.isEmpty ? null : word;
  }

  /// Looks up [word], which must already be normalized with [normalize].
  Future<DictionaryLookupResult> execute(String word) =>
      _dictionaryRepository.lookup(word);
}
