import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_pages/domain/repository/translation/language_pack_repository.dart';

/// Local development implementation of the language-pack contract.
///
/// The dictionary fixture is already bundled with the app, so installing a
/// pack currently records its availability locally instead of downloading a
/// remote archive. Keeping that state behind the repository makes the UI and
/// lookup flow ready for a checksum-validated asset downloader later.
@LazySingleton(as: LanguagePackRepository)
class LocalLanguagePackRepository implements LanguagePackRepository {
  LocalLanguagePackRepository(this._preferences);

  static const _installedKey = 'translation.installed_language_packs';

  static const _catalog = [
    LanguagePackInfo(
      id: 'en-es',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      version: '1.0.0-fixture',
      sizeBytes: 2 * 1024 * 1024,
      isInstalled: false,
    ),
  ];

  final SharedPreferences _preferences;

  @override
  Future<List<LanguagePackInfo>> getAvailablePacks() async {
    final installed = _preferences.getStringList(_installedKey) ?? const [];
    return [
      for (final pack in _catalog)
        LanguagePackInfo(
          id: pack.id,
          sourceLanguage: pack.sourceLanguage,
          targetLanguage: pack.targetLanguage,
          version: pack.version,
          sizeBytes: pack.sizeBytes,
          isInstalled: installed.contains(pack.id),
        ),
    ];
  }

  @override
  Future<void> install(String packId) async {
    _ensureKnownPack(packId);
    final installed = {...?_preferences.getStringList(_installedKey), packId};
    await _preferences.setStringList(_installedKey, installed.toList());
  }

  @override
  Future<void> delete(String packId) async {
    _ensureKnownPack(packId);
    final installed = {...?_preferences.getStringList(_installedKey)}
      ..remove(packId);
    await _preferences.setStringList(_installedKey, installed.toList());
  }

  void _ensureKnownPack(String packId) {
    if (_catalog.every((pack) => pack.id != packId)) {
      throw ArgumentError.value(packId, 'packId', 'Unknown language pack');
    }
  }
}
