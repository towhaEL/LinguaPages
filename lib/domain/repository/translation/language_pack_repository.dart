class LanguagePackInfo {
  const LanguagePackInfo({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.version,
    required this.sizeBytes,
    required this.isInstalled,
  });

  final String id;
  final String sourceLanguage;
  final String targetLanguage;
  final String version;
  final int sizeBytes;
  final bool isInstalled;
}

abstract interface class LanguagePackRepository {
  Future<List<LanguagePackInfo>> getAvailablePacks();

  Future<void> install(String packId);

  Future<void> delete(String packId);
}
