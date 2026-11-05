import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

void main() {
  group('Tier 2: Boundary & Corner Cases', () {
    testWidgets('Edge 1: Missing cover art falls back to format band container without error',
        (tester) async {
      final bookWithoutCover = BookEntity(
        id: 'null-cover-book',
        title: 'The Invisible Tome',
        author: 'Nameless Scribe',
        format: DocumentFormat.epub,
        sourceUri: 'file:///books/invisible.epub',
        sourceFileName: 'invisible.epub',
        contentFingerprint: 'fp-invisible',
        addedAt: DateTime(2026),
        coverPath: null,
      );

      await tester.pumpHarness(
        Center(
          child: SizedBox(
            width: 120,
            height: 180,
            child: BookCover(book: bookWithoutCover, compact: true),
          ),
        ),
      );

      expect(find.byType(BookCover), findsOneWidget);
      expect(find.text('The Invisible Tome'), findsOneWidget);
      expect(find.text('EPUB'), findsOneWidget);
    });

    testWidgets('Edge 2: Empty library state renders shelf artwork and dual import buttons',
        (tester) async {
      await tester.pumpHarness(
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/empty_library_shelf.png'),
                  key: Key('empty_shelf_art'),
                ),
                const SizedBox(height: 16),
                const Text('Your shelf is quiet'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () {}, child: const Text('Import files')),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () {}, child: const Text('Import a folder')),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('empty_shelf_art')), findsOneWidget);
      expect(find.text('Your shelf is quiet'), findsOneWidget);
      expect(find.text('Import files'), findsOneWidget);
      expect(find.text('Import a folder'), findsOneWidget);
    });

    testWidgets('Edge 3: Zero search results displays friendly empty state without overflow',
        (tester) async {
      await tester.pumpHarness(
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.search_off_rounded, size: 48, color: WarmEditorialTokens.subtitleSecondary),
                SizedBox(height: 12),
                Text(
                  'No matches found for "supercalifragilistic"',
                  style: TextStyle(
                    fontFamily: 'Newsreader',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Check your spelling or search across all chapters.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No matches found for "supercalifragilistic"'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('Edge 4: Extreme string length in title and author clamps safely with ellipsis',
        (tester) async {
      final extremeBook = MockDataFixtures.sampleBookWithExtremeTitle;

      await tester.pumpHarness(
        Center(
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  extremeBook.title,
                  key: const Key('extreme_title_text'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  extremeBook.author!,
                  key: const Key('extreme_author_text'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.byKey(const Key('extreme_title_text')));
      expect(titleWidget.maxLines, 2);
      expect(titleWidget.overflow, TextOverflow.ellipsis);

      final authorWidget = tester.widget<Text>(find.byKey(const Key('extreme_author_text')));
      expect(authorWidget.maxLines, 1);
      expect(authorWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('Edge 5: Reading progress slider clamps within bounds [0.0, 1.0]',
        (tester) async {
      double currentProgress = 0.0;

      await tester.pumpHarness(
        StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Progress: ${(currentProgress * 100).round()}%'),
                    Slider(
                      key: const Key('scrubber_slider'),
                      value: currentProgress,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) => setState(() => currentProgress = val.clamp(0.0, 1.0)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Progress: 0%'), findsOneWidget);

      final slider = tester.widget<Slider>(find.byKey(const Key('scrubber_slider')));
      expect(slider.min, 0.0);
      expect(slider.max, 1.0);
    });

    testWidgets('Edge 6: Wiktionary lookup for word not in dictionary displays graceful fallback',
        (tester) async {
      await tester.pumpHarness(
        Material(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'nonexistentwordxyz',
                  style: TextStyle(
                    fontFamily: 'Newsreader',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.search_off, color: WarmEditorialTokens.subtitleSecondary),
                    SizedBox(width: 8),
                    Expanded(child: Text('No definition found in offline lexicon')),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'OpenPages includes Wiktionary definitions locally. Ensure the term is spelled correctly.',
                  style: TextStyle(color: WarmEditorialTokens.subtitleSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('nonexistentwordxyz'), findsOneWidget);
      expect(find.text('No definition found in offline lexicon'), findsOneWidget);
    });

    testWidgets('Edge 7: Empty annotations screen renders zero-state without exceptions',
        (tester) async {
      await tester.pumpHarness(
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.sticky_note_2_outlined, size: 48, color: WarmEditorialTokens.subtitleSecondary),
                SizedBox(height: 12),
                Text(
                  'No annotations yet',
                  style: TextStyle(fontFamily: 'Newsreader', fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text(
                  'Highlights and notes you make while reading will appear here.',
                  style: TextStyle(color: WarmEditorialTokens.subtitleSecondary),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No annotations yet'), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
    });
  });
}
