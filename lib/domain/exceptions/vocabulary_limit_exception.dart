class VocabularyLimitException implements Exception {
  const VocabularyLimitException(this.limit);

  final int limit;

  @override
  String toString() => 'The free vocabulary limit of $limit items was reached.';
}
