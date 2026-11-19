import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/privacy/privacy_screen.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';

class _MockSaveReadingProgress extends Mock
    implements SaveReadingProgressUseCase {}

void main() {
  // The page hosts the read-aloud mini player, which stays hidden while
  // nothing is being read.
  setUp(() {
    if (injector.isRegistered<ReadAloudSession>()) {
      injector.unregister<ReadAloudSession>();
    }
    injector.registerSingleton(ReadAloudSession(_MockSaveReadingProgress()));
  });

  tearDown(() async => injector.reset(dispose: false));

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PrivacyScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone portrait shows a single column without an index', (
    tester,
  ) async {
    await pump(tester, const Size(402, 874));
    expect(find.byKey(const Key('privacy_index_pane')), findsNothing);
  });

  for (final (name, size) in [
    ('phone landscape', const Size(874, 402)),
    ('tablet landscape', const Size(1280, 800)),
  ]) {
    testWidgets('$name shows the section index beside the text', (
      tester,
    ) async {
      await pump(tester, size);
      expect(find.byKey(const Key('privacy_index_pane')), findsOneWidget);

      await tester.tap(find.byKey(const Key('privacy_index_4')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  bool selected(WidgetTester tester, int index) =>
      tester.widget<ListTile>(find.byKey(Key('privacy_index_$index'))).selected;

  testWidgets('tablet portrait lays out without overflow', (tester) async {
    await pump(tester, const Size(800, 1280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a late section keeps it highlighted', (tester) async {
    await pump(tester, const Size(874, 402));

    await tester.tap(find.byKey(const Key('privacy_index_3')));
    await tester.pumpAndSettle();

    expect(selected(tester, 3), isTrue);
    expect(selected(tester, 4), isFalse);
  });

  testWidgets('the highlight follows manual scrolling', (tester) async {
    await pump(tester, const Size(874, 402));
    expect(selected(tester, 0), isTrue);

    final text = find.byType(SingleChildScrollView);
    await tester.drag(text, const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(selected(tester, 4), isTrue);

    await tester.drag(text, const Offset(0, 5000));
    await tester.pumpAndSettle();
    expect(selected(tester, 0), isTrue);
  });
}
