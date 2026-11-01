import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';

/// Source of English definitions. Implementations throw a [DioException]
/// on failure; an unknown word is an HTTP 404 response.
abstract interface class DictionaryDataSource {
  Future<List<DictionaryEntryModel>> entries(String word);
}
