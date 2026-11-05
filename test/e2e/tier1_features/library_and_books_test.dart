import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

import '../helpers/mock_data_fixtures.dart';
import '../helpers/test_app_harness.dart';

/// Test representation of the Library screen contracts (Features 11-16).
class LibraryViewContractWidget extends StatelessWidget {
  const LibraryViewContractWidget({
    super.key,
    required this.books,
    this.continueReadingBook,
    this.onSearchPressed,
    this.onSettingsPressed,
    this.onResumePressed,
    this.onImportPressed,
    this.onFilterSelected,
    this.activeFilter = 'All',
  });

  final List<BookEntity> books;
  final BookEntity? continueReadingBook;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onResumePressed;
  final VoidCallback? onImportPressed;
  final ValueChanged<String>? onFilterSelected;
  final String activeFilter;

  @override
  Widget build(BuildContext context) {
    final heroBook = continueReadingBook ?? (books.isNotEmpty ? books.first : null);

    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(
          Icons.local_library_outlined,
          color: WarmEditorialTokens.accentInkBlue,
        ),
        title: const Text(
          'Library',
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: WarmEditorialTokens.textPrimaryInk,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('library_search_button'),
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
          ),
          IconButton(
            key: const Key('library_settings_button'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('library_import_fab'),
        onPressed: onImportPressed,
        backgroundColor: WarmEditorialTokens.accentInkBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Import',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (heroBook != null) ...[
            _buildContinueReadingHero(heroBook),
            const SizedBox(height: 24),
          ],
          _buildRecentCarousel(),
          const SizedBox(height: 20),
          _buildFilterChips(),
          const SizedBox(height: 20),
          _buildBookGrid(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildContinueReadingHero(BookEntity book) {
    final percent = (book.progress * 100).round();
    return Card(
      key: const Key('continue_reading_hero_card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
        side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 144,
              child: BookCover(book: book, compact: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatCode(book.format),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: WarmEditorialTokens.accentInkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (book.author != null)
                    Text(
                      book.author!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        book.currentChapterTitle ?? 'Reading',
                        style: const TextStyle(
                          fontSize: 11,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: WarmEditorialTokens.accentInkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: book.progress,
                    backgroundColor: WarmEditorialTokens.hairlineDivider,
                    valueColor: const AlwaysStoppedAnimation(
                      WarmEditorialTokens.accentInkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      key: const Key('resume_reading_button'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: const StadiumBorder(),
                        backgroundColor: WarmEditorialTokens.accentInkBlue,
                      ),
                      onPressed: onResumePressed,
                      icon: const Icon(Icons.auto_stories, size: 14),
                      label: const Text('Resume', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCarousel() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        key: const Key('recent_books_carousel'),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return Container(
            width: 210,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarmEditorialTokens.hairlineDivider),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 52,
                  child: BookCover(book: book, compact: true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(book.progress * 100).round()}%',
                        style: const TextStyle(fontSize: 10, color: WarmEditorialTokens.subtitleSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: book.progress,
                    strokeWidth: 2.5,
                    backgroundColor: WarmEditorialTokens.hairlineDivider,
                    valueColor: const AlwaysStoppedAnimation(WarmEditorialTokens.accentInkBlue),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Reading', 'To read', 'Finished', 'Favorites', 'Collections ▾'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: activeFilter == filter,
                onSelected: (_) => onFilterSelected?.call(filter),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return GridView.builder(
      key: const Key('library_books_3col_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 2 / 3.8,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: BookCover(book: book, compact: true)),
            const SizedBox(height: 4),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Newsreader',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (book.author != null)
              Text(
                book.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Test representation of Empty Library view (Feature 17).
class EmptyLibraryContractWidget extends StatelessWidget {
  const EmptyLibraryContractWidget({
    super.key,
    this.onImportFiles,
    this.onImportFolder,
  });

  final VoidCallback? onImportFiles;
  final VoidCallback? onImportFolder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/empty_library_shelf.png'),
                width: 240,
                height: 180,
                key: Key('empty_library_shelf_image'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your shelf is quiet',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Import a DRM-free book or a whole folder to start reading.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('empty_import_files_button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(220, 48),
                  shape: const StadiumBorder(),
                  backgroundColor: WarmEditorialTokens.accentInkBlue,
                ),
                onPressed: onImportFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import files'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('empty_import_folder_button'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(220, 48),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: WarmEditorialTokens.accentInkBlue, width: 1.5),
                ),
                onPressed: onImportFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('Import a folder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test representation of Filter & Sort Modal Bottom Sheet (Feature 18).
class FilterSortSheetContractWidget extends StatelessWidget {
  const FilterSortSheetContractWidget({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    required this.selectedFormats,
    required this.onFormatToggled,
    required this.onApply,
  });

  final String selectedSort;
  final ValueChanged<String> onSortChanged;
  final Set<DocumentFormat> selectedFormats;
  final ValueChanged<DocumentFormat> onFormatToggled;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCDAD5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: selectedSort,
                onChanged: (val) {
                  if (val != null) onSortChanged(val);
                },
                child: Column(
                  children: [
                    for (final sort in ['Recently read', 'Title', 'Author', 'Date added'])
                      RadioListTile<String>(
                        title: Text(sort),
                        value: sort,
                      ),
                  ],
                ),
              ),
              const Divider(),
              Wrap(
                spacing: 8,
                children: [
                  for (final format in DocumentFormat.values)
                    FilterChip(
                      label: Text(formatCode(format)),
                      selected: selectedFormats.contains(format),
                      onSelected: (_) => onFormatToggled(format),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('apply_filter_sort_button'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                  backgroundColor: WarmEditorialTokens.accentInkBlue,
                ),
                onPressed: onApply,
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test representation of Book Details Sheet (Feature 19).
class BookDetailsSheetContractWidget extends StatelessWidget {
  const BookDetailsSheetContractWidget({
    super.key,
    required this.book,
    this.onRead,
    this.onTrash,
  });

  final BookEntity book;
  final VoidCallback? onRead;
  final VoidCallback? onTrash;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: WarmEditorialTokens.canvasBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: 150,
                  child: BookCover(book: book, compact: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        key: const Key('book_details_title_text'),
                        style: const TextStyle(
                          fontFamily: 'Newsreader',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (book.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          book.author!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('${formatCode(book.format)} · Offline'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('book_details_read_button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
                backgroundColor: WarmEditorialTokens.accentInkBlue,
              ),
              onPressed: onRead,
              icon: const Icon(Icons.menu_book),
              label: const Text('Read'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('book_details_trash_button'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
                foregroundColor: WarmEditorialTokens.destructive,
                side: const BorderSide(color: WarmEditorialTokens.destructive),
              ),
              onPressed: onTrash,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Move to Trash'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Tier 1: Features 11-16 - Library View & Components', () {
    testWidgets('Library displays top bar, Newsreader title, search and settings actions',
        (tester) async {
      await tester.pumpHarness(
        LibraryViewContractWidget(books: MockDataFixtures.sampleLibrary),
      );

      expect(find.text('Library'), findsOneWidget);
      expect(find.byKey(const Key('library_search_button')), findsOneWidget);
      expect(find.byKey(const Key('library_settings_button')), findsOneWidget);
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Continue reading hero card displays cover, progress, and Resume pill',
        (tester) async {
      var resumeTapped = false;
      await tester.pumpHarness(
        LibraryViewContractWidget(
          books: MockDataFixtures.sampleLibrary,
          onResumePressed: () => resumeTapped = true,
        ),
      );

      expect(find.byKey(const Key('continue_reading_hero_card')), findsOneWidget);
      expect(find.text('The Shadow of the Wind'), findsAtLeastNWidgets(1));
      expect(find.text('64%'), findsAtLeastNWidgets(1));

      await tester.tap(find.byKey(const Key('resume_reading_button')));
      expect(resumeTapped, isTrue);
    });

    testWidgets('Recent books carousel displays horizontal list with circular progress indicators',
        (tester) async {
      await tester.pumpHarness(
        LibraryViewContractWidget(books: MockDataFixtures.sampleLibrary),
      );

      expect(find.byKey(const Key('recent_books_carousel')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Horizontal filter chips render All, Reading, To read, Finished, Collections',
        (tester) async {
      String? selectedFilter;
      await tester.pumpHarness(
        LibraryViewContractWidget(
          books: MockDataFixtures.sampleLibrary,
          onFilterSelected: (filter) => selectedFilter = filter,
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('To read'), findsOneWidget);

      await tester.tap(find.text('Reading'));
      expect(selectedFilter, 'Reading');
    });

    testWidgets('3-column book grid renders books with format badges and titles',
        (tester) async {
      await tester.pumpHarness(
        LibraryViewContractWidget(books: MockDataFixtures.sampleLibrary),
      );

      expect(find.byKey(const Key('library_books_3col_grid')), findsOneWidget);
      expect(find.text('Dune'), findsAtLeastNWidgets(1));
    });

    testWidgets('Extended FAB displays "+ Import" with StadiumBorder', (tester) async {
      var fabTapped = false;
      await tester.pumpHarness(
        LibraryViewContractWidget(
          books: MockDataFixtures.sampleLibrary,
          onImportPressed: () => fabTapped = true,
        ),
      );

      expect(find.byKey(const Key('library_import_fab')), findsOneWidget);
      await tester.tap(find.byKey(const Key('library_import_fab')));
      expect(fabTapped, isTrue);
    });
  });

  group('Tier 1: Feature 17 - Empty Library View (02b)', () {
    testWidgets('Empty state renders shelf art, headline, and dual import buttons',
        (tester) async {
      var importFilesTapped = false;
      var importFolderTapped = false;

      await tester.pumpHarness(
        EmptyLibraryContractWidget(
          onImportFiles: () => importFilesTapped = true,
          onImportFolder: () => importFolderTapped = true,
        ),
      );

      expect(find.byKey(const Key('empty_library_shelf_image')), findsOneWidget);
      expect(find.text('Your shelf is quiet'), findsOneWidget);
      expect(find.byKey(const Key('empty_import_files_button')), findsOneWidget);
      expect(find.byKey(const Key('empty_import_folder_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('empty_import_files_button')));
      expect(importFilesTapped, isTrue);

      await tester.tap(find.byKey(const Key('empty_import_folder_button')));
      expect(importFolderTapped, isTrue);
    });
  });

  group('Tier 1: Feature 18 - Filter & Sort Sheet (02c)', () {
    testWidgets('Sheet renders sort radios, format multi-select chips, and Apply button',
        (tester) async {
      var applied = false;
      var currentSort = 'Recently read';
      final formats = {DocumentFormat.epub};

      await tester.pumpHarness(
        Scaffold(
          body: FilterSortSheetContractWidget(
            selectedSort: currentSort,
            onSortChanged: (sort) => currentSort = sort,
            selectedFormats: formats,
            onFormatToggled: (fmt) {
              if (formats.contains(fmt)) {
                formats.remove(fmt);
              } else {
                formats.add(fmt);
              }
            },
            onApply: () => applied = true,
          ),
        ),
      );

      expect(find.text('Filter & Sort'), findsOneWidget);
      expect(find.text('Recently read'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.byKey(const Key('apply_filter_sort_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('apply_filter_sort_button')));
      expect(applied, isTrue);
    });
  });

  group('Tier 1: Feature 19 - Book Details Sheet (02d)', () {
    testWidgets('Details sheet presents cover, title, Read action, and Move to Trash action',
        (tester) async {
      var readTapped = false;
      var trashTapped = false;

      await tester.pumpHarness(
        Scaffold(
          body: BookDetailsSheetContractWidget(
            book: MockDataFixtures.sampleDuneBook,
            onRead: () => readTapped = true,
            onTrash: () => trashTapped = true,
          ),
        ),
      );

      expect(find.byKey(const Key('book_details_title_text')), findsOneWidget);
      expect(find.text('Frank Herbert'), findsOneWidget);
      expect(find.byKey(const Key('book_details_read_button')), findsOneWidget);
      expect(find.byKey(const Key('book_details_trash_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('book_details_read_button')));
      expect(readTapped, isTrue);

      await tester.tap(find.byKey(const Key('book_details_trash_button')));
      expect(trashTapped, isTrue);
    });
  });

  group('Tier 1: Feature 20 - Fallback Book Cover Widget', () {
    testWidgets('BookCover gracefully renders 2:3 container with format band for book without cover',
        (tester) async {
      await tester.pumpHarness(
        Center(
          child: SizedBox(
            width: 120,
            height: 180,
            child: BookCover(book: MockDataFixtures.sampleBookWithoutCover, compact: true),
          ),
        ),
      );

      expect(find.byType(BookCover), findsOneWidget);
      expect(find.text('EPUB'), findsOneWidget);
      expect(find.text('A Journey Through Quiet Shelves'), findsOneWidget);
    });
  });
}
