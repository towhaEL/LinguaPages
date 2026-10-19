/// Installed state for an offline translation language pack.
class LanguagePackEntity {
  const LanguagePackEntity({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.version,
    required this.sizeBytes,
    required this.checksum,
    required this.isInstalled,
    this.installedAt,
  });

  final String id;
  final String sourceLanguage;
  final String targetLanguage;
  final String version;
  final int sizeBytes;
  final String checksum;
  final bool isInstalled;
  final DateTime? installedAt;
}
