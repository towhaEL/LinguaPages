import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/screen/home/home_view.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';

class _MockLibraryCubit extends Mock implements LibraryCubit {}

BookEntity _book(int i, {double progress = 0, DateTime? lastReadAt}) =>
    BookEntity(
      id: 'book-$i',
      title: 'A fairly long book title number $i',
      author: 'Author $i',
      format: DocumentFormat.epub,
      sourceUri: 'file:///book-$i.epub',
      sourceFileName: 'book-$i.epub',
      contentFingerprint: 'fp-$i',
      addedAt: DateTime(2026),
      progress: progress,
      lastReadAt: lastReadAt,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final books = [
    _book(0, progress: 0.4, lastReadAt: DateTime(2026, 11)),
    for (var i = 1; i < 12; i++) _book(i),
  ];

  Future<void> pump(
    WidgetTester tester,
    Size size,
    LibraryLayout layout,
    LibraryState state,
  ) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = _MockLibraryCubit();
    when(() => cubit.state).thenReturn(state);
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<LibraryCubit>.value(
          value: cubit,
          child: HomeView(layout: layout),
        ),
      ),
    );
    await tester.pump();
  }

  final cases = [
    ('phone portrait', const Size(402, 874), LibraryLayout.phone),
    ('phone landscape', const Size(874, 402), LibraryLayout.phoneLandscape),
    ('tablet portrait', const Size(800, 1280), LibraryLayout.tablet),
    ('tablet landscape', const Size(1280, 800), LibraryLayout.tablet),
  ];

  for (final (name, size, layout) in cases) {
    testWidgets('$name lays out a full library without overflow', (
      tester,
    ) async {
      await pump(
        tester,
        size,
        layout,
        LibraryState(status: LibraryStatus.success, books: books),
      );
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('continue_reading_hero_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('library_search_text_field')),
        findsOneWidget,
      );
    });

    testWidgets('$name lays out the empty library without overflow', (
      tester,
    ) async {
      await pump(
        tester,
        size,
        layout,
        const LibraryState(status: LibraryStatus.success),
      );
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('empty_import_files_button')),
        findsOneWidget,
      );
    });
  }

  testWidgets('wide tablet moves the shelves into a side pane', (tester) async {
    await pump(
      tester,
      const Size(1280, 800),
      LibraryLayout.tablet,
      LibraryState(status: LibraryStatus.success, books: books),
    );
    // Shelves are a vertical list, not the horizontal chip row.
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testWidgets('narrow tablet keeps one column with the chip row', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(800, 1280),
      LibraryLayout.tablet,
      LibraryState(status: LibraryStatus.success, books: books),
    );
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.byType(VerticalDivider), findsNothing);
  });

  testWidgets('phone landscape uses an icon-only import button', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(874, 402),
      LibraryLayout.phoneLandscape,
      LibraryState(status: LibraryStatus.success, books: books),
    );
    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const Key('library_import_fab')),
    );
    expect(fab.isExtended, isFalse);
  });
}
