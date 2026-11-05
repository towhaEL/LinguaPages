import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('NotesSheet Widget Tests', () {
    final bookmarks = [
      BookmarkEntity(
        id: 'bm-1',
        bookId: 'book-1',
        title: 'Morning Fog in Chapter 4',
        locator: const PdfLocator(page: 142),
        createdAt: DateTime(2026, 10, 28),
      ),
    ];

    final highlights = [
      HighlightEntity(
        id: 'hl-1',
        bookId: 'book-1',
        selectedText: 'A secret is only as good as the keeper who guards it.',
        color: HighlightColor.blue,
        note: 'Echoes the prologue theme of stewardship',
        locator: const PdfLocator(page: 142),
        createdAt: DateTime(2026, 10, 28),
      ),
    ];

    testWidgets('renders 3 tabs and switches between them', (tester) async {
      await tester.pumpHarness(
        NotesSheet(
          notes: [
            ReaderNote.bookmark(bookmarks.first),
            ReaderNote.highlight(highlights.first),
          ],
          tableOfContents: const ['Prologue', 'Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4: The Silent Harbour'],
          activeChapterIndex: 4,
          bookTitle: 'The Shadow of the Wind',
          bookAuthor: 'Carlos Ruiz Zafón',
          onSelected: (_) {},
          onDeleted: (_) async {},
          onEdited: (_) async => null,
          onExport: (_, _) async {},
          onShare: (_, _, _) async {},
        ),
      );

      // Verify tabs exist
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Highlights'), findsOneWidget);

      // Contents tab shows chapters
      expect(find.text('Chapter 4: The Silent Harbour'), findsOneWidget);
      expect(find.byKey(const Key('export_markdown_button')), findsOneWidget);

      // Tap Bookmarks tab
      await tester.tap(find.text('Bookmarks'));
      await tester.pumpAndSettle();
      expect(find.text('Morning Fog in Chapter 4'), findsOneWidget);

      // Tap Highlights tab
      await tester.tap(find.text('Highlights'));
      await tester.pumpAndSettle();
      expect(find.text('“A secret is only as good as the keeper who guards it.”'), findsOneWidget);
    });

    testWidgets('export markdown button triggers callback', (tester) async {
      var exportTriggered = false;

      await tester.pumpHarness(
        NotesSheet(
          notes: [
            ReaderNote.bookmark(bookmarks.first),
            ReaderNote.highlight(highlights.first),
          ],
          onSelected: (_) {},
          onDeleted: (_) async {},
          onEdited: (_) async => null,
          onExport: (_, _) async => exportTriggered = true,
          onShare: (_, _, _) async {},
        ),
      );

      await tester.tap(find.byKey(const Key('export_markdown_button')));
      await tester.pumpAndSettle();
      expect(exportTriggered, isTrue);
    });
  });
}
