import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database);

  final LinguaPageDatabase _database;

  @override
  Future<SettingsEntity> getSettings() async {
    final rows = await _database.select(_database.appSettings).get();
    final values = <String, dynamic>{
      for (final row in rows) row.key: jsonDecode(row.value),
    };
    return _fromValues(values);
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final values = _toValues(settings);
    await _database.transaction(() async {
      await _database.delete(_database.appSettings).go();
      for (final entry in values.entries) {
        await _database
            .into(_database.appSettings)
            .insert(
              AppSettingsCompanion.insert(
                key: entry.key,
                value: jsonEncode(entry.value),
              ),
            );
      }
    });
  }

  @override
  Future<SettingsEntity> updateSetting<T>({
    required String key,
    required T value,
  }) async {
    final current = _toValues(await getSettings())..[key] = value;
    final settings = _fromValues(current);
    await saveSettings(settings);
    return settings;
  }

  Map<String, dynamic> _toValues(SettingsEntity settings) => {
    'readerTheme': settings.readerTheme.name,
    'readerMode': settings.readerMode.name,
    'fontSize': settings.fontSize,
    'lineSpacing': settings.lineSpacing,
    'margin': settings.margin,
    'readerTextAlignment': settings.readerTextAlignment.name,
    'readerPdfFit': settings.readerPdfFit.name,
    'readerPdfMode': settings.readerPdfMode.name,
    'keepScreenAwake': settings.keepScreenAwake,
    'sourceLanguage': settings.sourceLanguage,
    'targetLanguage': settings.targetLanguage,
    'dailyNewCardLimit': settings.dailyNewCardLimit,
    'reviewNotificationsEnabled': settings.reviewNotificationsEnabled,
  };

  SettingsEntity _fromValues(Map<String, dynamic> values) {
    return SettingsEntity(
      readerTheme: _enumValue(
        ReaderTheme.values,
        values['readerTheme'],
        ReaderTheme.light,
      ),
      readerMode: _enumValue(
        ReaderMode.values,
        values['readerMode'],
        ReaderMode.paginated,
      ),
      fontSize: (values['fontSize'] as num?)?.toDouble() ?? 18,
      lineSpacing: (values['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      margin: (values['margin'] as num?)?.toDouble() ?? 16,
      readerTextAlignment: _enumValue(
        ReaderTextAlignment.values,
        values['readerTextAlignment'],
        ReaderTextAlignment.left,
      ),
      readerPdfFit: _enumValue(
        ReaderPdfFit.values,
        values['readerPdfFit'],
        ReaderPdfFit.page,
      ),
      readerPdfMode: _enumValue(
        ReaderPdfMode.values,
        values['readerPdfMode'],
        ReaderPdfMode.visual,
      ),
      keepScreenAwake: values['keepScreenAwake'] as bool? ?? false,
      sourceLanguage: values['sourceLanguage'] as String? ?? 'en',
      targetLanguage: values['targetLanguage'] as String? ?? 'es',
      dailyNewCardLimit: values['dailyNewCardLimit'] as int? ?? 15,
      reviewNotificationsEnabled:
          values['reviewNotificationsEnabled'] as bool? ?? false,
    );
  }

  T _enumValue<T extends Enum>(List<T> values, dynamic name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
