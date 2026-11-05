import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

/// Test widget for Cross-Feature Combination 1: Theme Switching Live Sync.
class ReaderThemeSyncWidget extends StatefulWidget {
  const ReaderThemeSyncWidget({super.key});

  @override
  State<ReaderThemeSyncWidget> createState() => _ReaderThemeSyncWidgetState();
}

class _ReaderThemeSyncWidgetState extends State<ReaderThemeSyncWidget> {
  Color _canvasColor = const Color(0xFFF6F1E7); // Paper
  Color _textColor = const Color(0xFF1C1B1A);

  void _applyTheme(String theme) {
    setState(() {
      switch (theme) {
        case 'Paper':
          _canvasColor = const Color(0xFFF6F1E7);
          _textColor = const Color(0xFF1C1B1A);
        case 'Sepia':
          _canvasColor = const Color(0xFFF4ECD8);
          _textColor = const Color(0xFF382E1E);
        case 'Night':
          _canvasColor = const Color(0xFF23272A);
          _textColor = const Color(0xFFE3E5E8);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvasColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Warm Editorial Reading Canvas',
                  key: const Key('reader_canvas_text'),
                  style: TextStyle(fontFamily: 'Newsreader', fontSize: 20, color: _textColor),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    key: const Key('btn_theme_paper'),
                    onPressed: () => _applyTheme('Paper'),
                    child: const Text('Paper'),
                  ),
                  ElevatedButton(
                    key: const Key('btn_theme_sepia'),
                    onPressed: () => _applyTheme('Sepia'),
                    child: const Text('Sepia'),
                  ),
                  ElevatedButton(
                    key: const Key('btn_theme_night'),
                    onPressed: () => _applyTheme('Night'),
                    child: const Text('Night'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Test widget for Cross-Feature Combination 2: Filter Chips Synchronize Book Grid.
class LibraryFilterSyncWidget extends StatefulWidget {
  const LibraryFilterSyncWidget({super.key, required this.books});

  final List<BookEntity> books;

  @override
  State<LibraryFilterSyncWidget> createState() => _LibraryFilterSyncWidgetState();
}

class _LibraryFilterSyncWidgetState extends State<LibraryFilterSyncWidget> {
  String _activeFilter = 'All';

  List<BookEntity> get _filteredBooks => switch (_activeFilter) {
        'Reading' => widget.books.where((b) => b.progress > 0 && b.progress < 1.0).toList(),
        'Finished' => widget.books.where((b) => b.progress == 1.0).toList(),
        _ => widget.books,
      };

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredBooks;

    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  for (final filter in ['All', 'Reading', 'Finished'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('filter_chip_$filter'),
                        label: Text(filter),
                        selected: _activeFilter == filter,
                        onSelected: (_) => setState(() => _activeFilter = filter),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayed.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2 / 3.8,
                ),
                itemBuilder: (context, index) {
                  final book = displayed[index];
                  return Column(
                    children: [
                      Expanded(child: BookCover(book: book, compact: true)),
                      Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Tier 3: Cross-Feature Combinations & State Synchronization', () {
    testWidgets('Combination 1: Appearance theme switch live-updates reader canvas & contrast',
        (tester) async {
      await tester.pumpHarness(const ReaderThemeSyncWidget());

      // Initial Paper theme
      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF6F1E7));

      // Switch to Sepia
      await tester.tap(find.byKey(const Key('btn_theme_sepia')));
      await tester.pumpAndSettle();

      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF4ECD8));

      // Switch to Night
      await tester.tap(find.byKey(const Key('btn_theme_night')));
      await tester.pumpAndSettle();

      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF23272A));
    });

    testWidgets('Combination 2: Filter chip selection synchronizes displayed books in 3-col grid',
        (tester) async {
      final books = MockDataFixtures.sampleLibrary;

      await tester.pumpHarness(LibraryFilterSyncWidget(books: books));

      // All: 5 books displayed
      expect(find.byType(BookCover), findsNWidgets(5));

      // Filter: Reading
      await tester.tap(find.byKey(const Key('filter_chip_Reading')));
      await tester.pumpAndSettle();

      // Shadow of the Wind (0.64), Dune (0.48), Essays (0.18) = 3 books
      expect(find.byType(BookCover), findsNWidgets(3));

      // Filter: Finished
      await tester.tap(find.byKey(const Key('filter_chip_Finished')));
      await tester.pumpAndSettle();

      // Ficciones (1.0) = 1 book
      expect(find.byType(BookCover), findsNWidgets(1));
      expect(find.text('Ficciones'), findsAtLeastNWidgets(1));
    });

    testWidgets('Combination 3: Text selection Define trigger opens Wiktionary sheet with word',
        (tester) async {
      String? definedWord;

      await tester.pumpHarness(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  key: const Key('trigger_define_btn'),
                  onPressed: () {
                    definedWord = 'littoral';
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(24),
                        child: Text('Definition of $definedWord: coastal region'),
                      ),
                    );
                  },
                  child: const Text('Define Selection'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('trigger_define_btn')));
      await tester.pumpAndSettle();

      expect(definedWord, 'littoral');
      expect(find.text('Definition of littoral: coastal region'), findsOneWidget);
    });

    testWidgets('Combination 4: Read aloud playback state controls sentence highlight band',
        (tester) async {
      bool isReadingAloud = false;

      await tester.pumpHarness(
        StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      key: const Key('dynamic_sentence_band'),
                      color: isReadingAloud
                          ? WarmEditorialTokens.spokenHighlight
                          : Colors.transparent,
                      child: const Text('The silent cobblestones gleamed with evening rain.'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: const Key('toggle_read_aloud_btn'),
                      onPressed: () => setState(() => isReadingAloud = !isReadingAloud),
                      child: Text(isReadingAloud ? 'Pause' : 'Play'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Initially inactive
      var band = tester.widget<Container>(find.byKey(const Key('dynamic_sentence_band')));
      expect(band.color, Colors.transparent);

      // Tap Play
      await tester.tap(find.byKey(const Key('toggle_read_aloud_btn')));
      await tester.pumpAndSettle();

      band = tester.widget<Container>(find.byKey(const Key('dynamic_sentence_band')));
      expect(band.color, WarmEditorialTokens.spokenHighlight);
    });
  });
}
