import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
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
  }) {
    // One transaction per update, so two quick updates cannot both read the
    // old settings and drop each other's change.
    return _database.transaction(() async {
      final current = _toValues(await getSettings())..[key] = value;
      final settings = _fromValues(current);
      await saveSettings(settings);
      return settings;
    });
  }

  Map<String, dynamic> _toValues(SettingsEntity settings) => {
    'readerTheme': settings.readerTheme.name,
    'readerFont': settings.readerFont.name,
    'readerMode': settings.readerMode.name,
    'fontSize': settings.fontSize,
    'lineSpacing': settings.lineSpacing,
    'margin': settings.margin,
    'readerTextAlignment': settings.readerTextAlignment.name,
    'readerPdfFit': settings.readerPdfFit.name,
    'readerPdfMode': settings.readerPdfMode.name,
    'keepScreenAwake': settings.keepScreenAwake,
    'onlineDictionary': settings.onlineDictionary,
    'libraryListView': settings.libraryListView,
    'librarySort': settings.librarySort.name,
  };

  SettingsEntity _fromValues(Map<String, dynamic> values) {
    return SettingsEntity(
      readerTheme: _enumValue(
        ReaderTheme.values,
        values['readerTheme'],
        ReaderTheme.light,
      ),
      readerFont: _enumValue(
        ReaderFont.values,
        values['readerFont'],
        ReaderFont.original,
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
      onlineDictionary: values['onlineDictionary'] as bool? ?? true,
      libraryListView: values['libraryListView'] as bool? ?? false,
      librarySort: _enumValue(
        LibrarySort.values,
        values['librarySort'],
        LibrarySort.recent,
      ),
    );
  }

  T _enumValue<T extends Enum>(List<T> values, dynamic name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
