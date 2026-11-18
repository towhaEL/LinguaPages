import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/vocabulary/saved_word_entity.dart';
import 'package:lingua_pages/domain/repository/vocabulary/saved_word_repository.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';
import 'package:lingua_pages/presentation/screen/saved_words/cubit/saved_words_cubit.dart';
import 'package:lingua_pages/presentation/screen/saved_words/saved_words_screen.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class _Words extends Mock implements SavedWordRepository {}

class _SaveProgress extends Mock implements SaveReadingProgressUseCase {}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late _Words words;

  setUp(() {
    words = _Words();
    when(() => words.delete(any())).thenAnswer((_) async {});
    when(words.getAll).thenAnswer(
      (_) async => [
        for (var i = 0; i < 7; i++)
          SavedWordEntity(
            word: 'word$i',
            createdAt: DateTime(2026, 1, i + 1),
            phonetic: '/wɜːd/',
            partOfSpeech: 'noun',
            definition: i.isEven ? 'A unit of language. ' * 8 : 'Short.',
            bookTitle: 'Sea Stories',
          ),
        // Last, so word0 and word1 share the first row.
        SavedWordEntity(
          word: 'Pneumonoultramicroscopicsilicovolcanoconiosis',
          createdAt: DateTime(2025),
          phonetic: '/ˌnjuːmənəʊˌʌltrəˌmaɪkrəˌskɒpɪkˌsɪlɪkəʊvɒlˌkeɪnəʊ/',
          partOfSpeech: 'noun',
          definition: 'A lung disease caused by fine dust. ' * 6,
          bookTitle: 'A very long book title that goes on for a while',
        ),
      ],
    );
    injector
      ..registerFactory(() => SavedWordsCubit(words, Logger(level: Level.off)))
      ..registerSingleton(ReadAloudSession(_SaveProgress()));
  });

  tearDown(injector.reset);

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SavedWordsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone portrait shows a single-column list', (tester) async {
    await pumpAt(tester, const Size(402, 874));
    expect(find.text('word0'), findsOneWidget);
    expect(find.byKey(const Key('saved_words_grid')), findsNothing);
  });

  for (final (name, size) in [
    ('phone landscape', const Size(874, 402)),
    ('tablet portrait', const Size(768, 1024)),
    ('tablet landscape', const Size(1280, 800)),
  ]) {
    testWidgets('$name shows cards in a grid', (tester) async {
      await pumpAt(tester, size);
      expect(find.byKey(const Key('saved_words_grid')), findsOneWidget);
      // word0 and word1 share the first row.
      expect(
        tester.getTopLeft(find.text('word1')).dy,
        tester.getTopLeft(find.text('word0')).dy,
      );
    });
  }

  for (final (name, size) in [
    ('narrow phone', const Size(320, 640)),
    ('small landscape tablet', const Size(1024, 768)),
  ]) {
    testWidgets('$name fits a very long word without overflow', (
      tester,
    ) async {
      await pumpAt(tester, size);
      await tester.scrollUntilVisible(
        find.text('Pneumonoultramicroscopicsilicovolcanoconiosis'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the search query survives a rotation', (tester) async {
    await pumpAt(tester, const Size(402, 874));
    await tester.enterText(
      find.byKey(const Key('saved_words_search')),
      'word3',
    );
    await tester.pumpAndSettle();
    expect(find.text('word2'), findsNothing);

    tester.view.physicalSize = const Size(874, 402);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saved_words_grid')), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'word3'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('saved_words_grid')),
        matching: find.text('word3'),
      ),
      findsOneWidget,
    );
    expect(find.text('word2'), findsNothing);
  });

  testWidgets('a card in the grid can be deleted', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    final card = find.ancestor(
      of: find.text('word0'),
      matching: find.byType(Row),
    ).first;
    await tester.tap(
      find.descendant(of: card, matching: find.byIcon(Icons.delete_outline)),
    );
    await tester.pumpAndSettle();

    verify(() => words.delete('word0')).called(1);
  });
}
