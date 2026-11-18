import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/use_cases/backup/create_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/backup/restore_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/clear_dictionary_cache_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/app/cubit/app_preferences_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/screen/settings/settings_screen.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockCreateBackup extends Mock implements CreateBackupUseCase {}

class _MockRestoreBackup extends Mock implements RestoreBackupUseCase {}

class _MockClearDictionaryCache extends Mock
    implements ClearDictionaryCacheUseCase {}

class _MockPremiumCubit extends Mock implements PremiumCubit {}

class _MockAppPreferencesCubit extends Mock implements AppPreferencesCubit {}

void _register<T extends Object>(T instance) {
  if (injector.isRegistered<T>()) injector.unregister<T>();
  injector.registerSingleton<T>(instance);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final settings = _MockSettingsRepository();
    when(settings.getSettings).thenAnswer((_) async => const SettingsEntity());
    _register<SettingsRepository>(settings);
    _register<CreateBackupUseCase>(_MockCreateBackup());
    _register<RestoreBackupUseCase>(_MockRestoreBackup());
    _register<ClearDictionaryCacheUseCase>(_MockClearDictionaryCache());
  });

  tearDown(() async => injector.reset(dispose: false));

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final premium = _MockPremiumCubit();
    when(() => premium.state).thenReturn(const PremiumState(unlocked: false));
    when(() => premium.stream).thenAnswer((_) => const Stream.empty());
    when(() => premium.close()).thenAnswer((_) async {});
    final preferences = _MockAppPreferencesCubit();
    when(() => preferences.state).thenReturn(const AppPreferences());
    when(() => preferences.stream).thenAnswer((_) => const Stream.empty());
    when(() => preferences.close()).thenAnswer((_) async {});
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PremiumCubit>.value(value: premium),
            BlocProvider<AppPreferencesCubit>.value(value: preferences),
          ],
          child: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  const navPane = Key('settings_nav_pane');

  final cases = [
    ('phone portrait', const Size(402, 874), false),
    ('phone landscape', const Size(874, 402), true),
    ('tablet portrait', const Size(800, 1280), false),
    ('tablet landscape', const Size(1280, 800), true),
  ];

  for (final (name, size, twoPane) in cases) {
    testWidgets('$name lays out without overflow', (tester) async {
      await pump(tester, size);

      expect(tester.takeException(), isNull);
      expect(find.byKey(navPane), twoPane ? findsOneWidget : findsNothing);
    });
  }

  for (final (name, size) in [
    ('phone landscape', const Size(874, 402)),
    ('tablet landscape', const Size(1280, 800)),
  ]) {
    testWidgets('$name shows every group without overflow', (tester) async {
      await pump(tester, size);

      for (final id in [
        'appearance',
        'reading_defaults',
        'read_aloud',
        'backup',
        'about',
      ]) {
        await tester.tap(find.byKey(Key('settings_nav_$id')));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: id);
        expect(find.byKey(Key('settings_card_$id')), findsOneWidget);
      }
    });
  }

  testWidgets('two panes show the patron banner only with appearance', (
    tester,
  ) async {
    await pump(tester, const Size(1280, 800));
    expect(find.byKey(const Key('settings_patron_banner')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings_nav_backup')));
    await tester.pump();
    expect(find.byKey(const Key('settings_patron_banner')), findsNothing);
  });
}
