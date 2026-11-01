import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

void main() {
  test('only the extra themes, fonts and presets are premium', () {
    expect(ReaderTheme.values.where((theme) => !theme.isPremium), [
      ReaderTheme.light,
      ReaderTheme.sepia,
      ReaderTheme.dark,
    ]);
    expect(ReaderFont.values.where((font) => !font.isPremium), [
      ReaderFont.original,
      ReaderFont.serif,
      ReaderFont.sans,
    ]);
    expect(
      AppearanceCatalog.presets.where((preset) => !preset.isPremium).single.id,
      ReaderStylePresetId.standard,
    );
    // Every premium preset uses a premium font, so it falls back with it.
    for (final preset in AppearanceCatalog.presets.where((p) => p.isPremium)) {
      expect(preset.font.isPremium, isTrue, reason: preset.id.name);
    }
  });

  test('the standard preset matches the default settings', () {
    expect(
      AppearanceCatalog.presets.first.matches(const SettingsEntity()),
      isTrue,
    );
  });

  const premiumLook = SettingsEntity(
    readerTheme: ReaderTheme.twilight,
    readerFont: ReaderFont.literata,
    fontSize: 21,
  );

  group('effective', () {
    test('keeps premium items while unlocked', () {
      final shown = AppearanceCatalog.effective(premiumLook, premium: true);
      expect(shown.readerTheme, ReaderTheme.twilight);
      expect(shown.readerFont, ReaderFont.literata);
    });

    test('falls back to the closest free look when locked', () {
      final shown = AppearanceCatalog.effective(premiumLook, premium: false);
      expect(shown.readerTheme, ReaderTheme.dark);
      expect(shown.readerFont, ReaderFont.original);
      expect(shown.fontSize, 21, reason: 'free settings are untouched');

      expect(
        ReaderTheme.values
            .map((theme) => theme.freeFallback)
            .every((theme) => !theme.isPremium),
        isTrue,
      );
    });
  });

  group('persistable', () {
    test('does not save a previewed premium item', () {
      const saved = SettingsEntity(readerTheme: ReaderTheme.sepia);
      final next = AppearanceCatalog.persistable(
        premiumLook,
        saved: saved,
        premium: false,
      );
      expect(next.readerTheme, ReaderTheme.sepia);
      expect(next.readerFont, ReaderFont.original);
      expect(next.fontSize, 21);
    });

    test("keeps an expired user's saved premium choice", () {
      // The sheet starts from the fallback look; changing the size must not
      // overwrite the saved Twilight theme or Literata font.
      final shown = AppearanceCatalog.effective(premiumLook, premium: false);
      final next = AppearanceCatalog.persistable(
        shown.copyWith(fontSize: 24),
        saved: premiumLook,
        premium: false,
      );
      expect(next.readerTheme, ReaderTheme.twilight);
      expect(next.readerFont, ReaderFont.literata);
      expect(next.fontSize, 24);
    });

    test('saves a different free item picked while locked', () {
      final next = AppearanceCatalog.persistable(
        const SettingsEntity(readerTheme: ReaderTheme.sepia),
        saved: premiumLook,
        premium: false,
      );
      expect(next.readerTheme, ReaderTheme.sepia);
    });

    test('saves premium items once unlocked', () {
      final next = AppearanceCatalog.persistable(
        premiumLook,
        saved: const SettingsEntity(),
        premium: true,
      );
      expect(next.readerTheme, ReaderTheme.twilight);
      expect(next.readerFont, ReaderFont.literata);
    });
  });
}
