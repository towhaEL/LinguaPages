import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

/// Persists and retrieves user settings (reader preferences, study config).
abstract interface class SettingsRepository {
  Future<SettingsEntity> getSettings();

  Future<void> saveSettings(SettingsEntity settings);

  /// Update a single setting by key. Returns the full updated entity.
  Future<SettingsEntity> updateSetting<T>({
    required String key,
    required T value,
  });
}
