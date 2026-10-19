import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';
import 'package:lingua_pages/data/repository_impl/settings/drift_settings_repository.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

void main() {
  group('DriftSettingsRepository', () {
    late LinguaPageDatabase database;
    late DriftSettingsRepository repository;

    setUp(() {
      database = LinguaPageDatabase(NativeDatabase.memory());
      repository = DriftSettingsRepository(database);
    });

    tearDown(() => database.close());

    test('returns stable defaults for an empty database', () async {
      final settings = await repository.getSettings();

      expect(settings.sourceLanguage, 'en');
      expect(settings.targetLanguage, 'es');
      expect(settings.readerMode, ReaderMode.paginated);
      expect(settings.dailyNewCardLimit, 15);
    });

    test('persists settings and updates a single key', () async {
      await repository.saveSettings(
        const SettingsEntity(
          readerTheme: ReaderTheme.sepia,
          readerMode: ReaderMode.continuous,
          readerTextAlignment: ReaderTextAlignment.justify,
          readerPdfFit: ReaderPdfFit.width,
          fontSize: 20,
        ),
      );

      final updated = await repository.updateSetting(
        key: 'targetLanguage',
        value: 'es',
      );

      expect(updated.readerTheme, ReaderTheme.sepia);
      expect(updated.readerMode, ReaderMode.continuous);
      expect(updated.readerTextAlignment, ReaderTextAlignment.justify);
      expect(updated.readerPdfFit, ReaderPdfFit.width);
      expect(updated.fontSize, 20);
      expect(updated.targetLanguage, 'es');
    });
  });
}
