class RecapEntity {
  const RecapEntity({
    required this.summary,
    required this.characters,
    required this.sourceLocator,
    required this.generatedAt,
  });

  final String summary;
  final List<String> characters;
  final String sourceLocator;
  final DateTime generatedAt;
}
