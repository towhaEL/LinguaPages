import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/appearance_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../e2e/helpers/test_app_harness.dart';

class _MockPremiumCubit extends Mock implements PremiumCubit {}

PremiumCubit _premium({required bool unlocked}) {
  final cubit = _MockPremiumCubit();
  when(() => cubit.state).thenReturn(PremiumState(unlocked: unlocked));
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.close()).thenAnswer((_) async {});
  return cubit;
}

Finder _lockIn(Finder parent) => find.descendant(
  of: parent,
  matching: find.byIcon(Icons.lock),
);

void main() {
  group('AppearanceSheet Widget Tests', () {
    testWidgets('renders every theme swatch and typography slider', (
      tester,
    ) async {
      ReaderTheme? selectedTheme;
      double? changedSize;

      await tester.pumpHarness(
        AppearanceSheet(
          selectedTheme: ReaderTheme.light,
          onThemeSelected: (val) => selectedTheme = val,
          fontSize: 18,
          onFontSizeChanged: (val) => changedSize = val,
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      for (final theme in ReaderTheme.values) {
        expect(find.byKey(Key('swatch_${theme.name}')), findsOneWidget);
      }

      await tester.tap(find.byKey(const Key('swatch_sepia')));
      await tester.pumpAndSettle();
      expect(selectedTheme, equals(ReaderTheme.sepia));

      await tester.drag(
        find.byKey(const Key('appearance_font_slider')),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(changedSize, isNotNull);
    });

    testWidgets('renders every typeface and responds to selection', (
      tester,
    ) async {
      SettingsEntity? updatedSettings;

      await tester.pumpHarness(
        AppearanceSheet(
          settings: const SettingsEntity(),
          onChanged: (settings) => updatedSettings = settings,
        ),
      );

      expect(find.text('Typeface'), findsOneWidget);
      for (final font in ReaderFont.values) {
        expect(find.byKey(Key('typeface_${font.name}')), findsOneWidget);
      }

      await tester.ensureVisible(find.byKey(const Key('typeface_sans')));
      await tester.tap(find.byKey(const Key('typeface_sans')));
      await tester.pumpAndSettle();
      expect(updatedSettings?.readerFont, equals(ReaderFont.sans));
    });

    testWidgets('reset button triggers onReset callback', (tester) async {
      var resetTapped = false;

      await tester.pumpHarness(
        AppearanceSheet(onReset: () => resetTapped = true),
      );

      expect(find.text('Reset'), findsOneWidget);
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(resetTapped, isTrue);
    });
  });

  group('AppearanceSheet premium', () {
    Future<void> pump(
      WidgetTester tester, {
      required bool unlocked,
      SettingsEntity settings = const SettingsEntity(),
      ValueChanged<SettingsEntity>? onChanged,
    }) => tester.pumpHarness(
      BlocProvider<PremiumCubit>.value(
        value: _premium(unlocked: unlocked),
        child: AppearanceSheet(settings: settings, onChanged: onChanged),
      ),
    );

    testWidgets('locks exactly the premium themes and fonts', (tester) async {
      await pump(tester, unlocked: false);

      for (final theme in ReaderTheme.values) {
        expect(
          _lockIn(find.byKey(Key('swatch_${theme.name}'))),
          theme.isPremium ? findsOneWidget : findsNothing,
          reason: theme.name,
        );
      }
      for (final font in ReaderFont.values) {
        expect(
          _lockIn(find.byKey(Key('typeface_${font.name}'))),
          font.isPremium ? findsOneWidget : findsNothing,
          reason: font.name,
        );
      }
    });

    testWidgets('shows no locks once premium is unlocked', (tester) async {
      await pump(tester, unlocked: true);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('offers every style preset', (tester) async {
      SettingsEntity? updated;
      await pump(tester, unlocked: true, onChanged: (s) => updated = s);

      for (final preset in AppearanceCatalog.presets) {
        expect(find.byKey(Key('preset_${preset.id.name}')), findsOneWidget);
      }
      final airy = AppearanceCatalog.presets.firstWhere(
        (p) => p.id == ReaderStylePresetId.airy,
      );
      await tester.ensureVisible(find.byKey(const Key('preset_airy')));
      await tester.tap(find.byKey(const Key('preset_airy')));
      await tester.pumpAndSettle();
      expect(airy.matches(updated!), isTrue);
    });

    testWidgets('a locked theme previews and says it is not kept', (
      tester,
    ) async {
      SettingsEntity? updated;
      await pump(tester, unlocked: false, onChanged: (s) => updated = s);
      expect(
        find.byKey(const Key('appearance_premium_preview_notice')),
        findsNothing,
      );

      final twilight = find.byKey(const Key('swatch_twilight'));
      await tester.ensureVisible(twilight);
      await tester.tap(twilight);
      await tester.pumpAndSettle();

      expect(updated?.readerTheme, ReaderTheme.twilight);
      expect(
        find.byKey(const Key('appearance_premium_preview_notice')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('appearance_unlock_button')), findsOneWidget);
    });

    testWidgets('an unlocked user sees no preview notice', (tester) async {
      await pump(
        tester,
        unlocked: true,
        settings: const SettingsEntity(readerTheme: ReaderTheme.twilight),
      );
      expect(
        find.byKey(const Key('appearance_premium_preview_notice')),
        findsNothing,
      );
    });
  });
}
