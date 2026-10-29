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

      expect(settings.readerTheme, ReaderTheme.light);
      expect(settings.readerMode, ReaderMode.paginated);
      expect(settings.fontSize, 18);
    });

    test('persists settings and updates a single key', () async {
      await repository.saveSettings(
        const SettingsEntity(
          readerTheme: ReaderTheme.sepia,
          readerMode: ReaderMode.continuous,
          readerTextAlignment: ReaderTextAlignment.justify,
          readerPdfFit: ReaderPdfFit.width,
          readerPdfMode: ReaderPdfMode.text,
          keepScreenAwake: true,
          fontSize: 20,
        ),
      );

      final updated = await repository.updateSetting(
        key: 'lineSpacing',
        value: 1.8,
      );

      expect(updated.readerTheme, ReaderTheme.sepia);
      expect(updated.readerMode, ReaderMode.continuous);
      expect(updated.readerTextAlignment, ReaderTextAlignment.justify);
      expect(updated.readerPdfFit, ReaderPdfFit.width);
      expect(updated.readerPdfMode, ReaderPdfMode.text);
      expect(updated.keepScreenAwake, isTrue);
      expect(updated.fontSize, 20);
      expect(updated.lineSpacing, 1.8);
    });
  });
}
