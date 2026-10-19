/// Reduces a surface-form word to the lookup form used by a language pack.
abstract interface class Lemmatizer {
  Future<String> lemmatize({required String word, required String language});
}
