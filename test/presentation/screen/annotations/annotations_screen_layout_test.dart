import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/domain/use_cases/reader/save_reading_progress_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/annotations/annotations_screen.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class _Library extends Mock implements LibraryRepository {}

class _Highlights extends Mock implements HighlightRepository {}

class _Bookmarks extends Mock implements BookmarkRepository {}

class _SaveProgress extends Mock implements SaveReadingProgressUseCase {}

void main() {
  final book = BookEntity(
    id: 'sea',
    title: 'Sea Stories',
    format: DocumentFormat.txt,
    sourceUri: '/sea.txt',
    sourceFileName: 'sea.txt',
    contentFingerprint: 'sea',
    addedAt: DateTime(2026),
  );

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    final library = _Library();
    final highlights = _Highlights();
    final bookmarks = _Bookmarks();
    when(library.getAll).thenAnswer((_) async => [book]);
    when(highlights.getAll).thenAnswer(
      (_) async => [
        for (var i = 0; i < 6; i++)
          HighlightEntity(
            id: 'h$i',
            bookId: book.id,
            selectedText: 'Waves at dawn, line $i, ' * 6,
            locator: const TextLocator(offset: 0),
            color: HighlightColor.values[i % HighlightColor.values.length],
            note: i.isEven ? 'A note on line $i' : null,
            createdAt: DateTime(2026, 1, i + 1),
          ),
      ],
    );
    when(bookmarks.getAll).thenAnswer(
      (_) async => [
        BookmarkEntity(
          id: 'b1',
          bookId: book.id,
          title: 'Chapter 2',
          locator: const TextLocator(offset: 10),
          createdAt: DateTime(2026, 3),
        ),
      ],
    );
    injector
      ..registerFactory(
        () => AnnotationsCubit(
          library,
          highlights,
          bookmarks,
          Logger(level: Level.off),
        ),
      )
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
        home: const AnnotationsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('phone portrait keeps filters above the list', (tester) async {
    await pumpAt(tester, const Size(402, 874));
    expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
    expect(find.byKey(const Key('annotation_detail')), findsNothing);
  });

  testWidgets('phone landscape puts filters in a side panel', (tester) async {
    await pumpAt(tester, const Size(874, 402));
    expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
    expect(find.byKey(const Key('annotation_detail')), findsNothing);
  });

  testWidgets('tablet portrait lays out without a detail pane', (tester) async {
    await pumpAt(tester, const Size(768, 1024));
    expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
    expect(find.byKey(const Key('annotation_detail')), findsNothing);
  });

  testWidgets('tablet landscape shows the selected annotation in full', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.byKey(const Key('annotation_detail')), findsOneWidget);
    expect(find.text('Chapter 2'), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('annotation_item_card_2')));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2'), findsOneWidget);
  });

  testWidgets('a small landscape tablet fits three panes', (tester) async {
    await pumpAt(tester, const Size(1024, 768));
    expect(find.byKey(const Key('annotation_detail')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the search query survives a rotation', (tester) async {
    await pumpAt(tester, const Size(402, 874));
    await tester.enterText(find.byType(TextFormField), 'line 4');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('annotation_item_card_2')), findsNothing);

    tester.view.physicalSize = const Size(874, 402);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'line 4'), findsOneWidget);
    expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
    expect(find.byKey(const Key('annotation_item_card_2')), findsNothing);
  });

  testWidgets('a filter in the side panel narrows the list', (tester) async {
    await pumpAt(tester, const Size(874, 402));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Bookmarks'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annotation_item_card_1')), findsOneWidget);
    expect(find.byKey(const Key('annotation_item_card_2')), findsNothing);
  });

  testWidgets('the detail falls back when a filter hides the selection', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1280, 800));
    // Select a highlight, then show bookmarks only.
    await tester.tap(find.byKey(const Key('annotation_item_card_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Bookmarks'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('annotation_detail')), findsOneWidget);
    expect(find.text('Chapter 2'), findsNWidgets(2));
  });
}
