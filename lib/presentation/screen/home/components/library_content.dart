import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/components/book_details_sheet.dart';
import 'package:lingua_pages/presentation/screen/home/components/filter_sort_sheet.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_book_actions.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';

const _gutter = 20.0;
const _tabular = [FontFeature.tabularFigures()];

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  var _searching = false;

  void _closeSearch() {
    setState(() => _searching = false);
    context.read<LibraryCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryCubit, LibraryState>(
      listenWhen: (previous, current) => current.folderResult != null,
      listener: (context, state) {
        final result = state.folderResult!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.imported + result.duplicates + result.failed == 0
                  ? context.l10n.libraryFolderEmpty
                  : context.l10n.libraryFolderImported(
                      result.imported,
                      result.duplicates + result.failed,
                    ),
            ),
          ),
        );
      },
      child: BlocListener<LibraryCubit, LibraryState>(
        listenWhen: (previous, current) =>
            current.importFeedback != null &&
            (current.importFeedback != previous.importFeedback ||
                current.importMessage != previous.importMessage),
        listener: (context, state) {
          final feedback = state.importFeedback;
          final message = state.importMessage;
          if (feedback == null || message == null) return;
          final text = switch (feedback) {
            LibraryImportFeedback.imported =>
              context.l10n.libraryImportedMessage(message),
            LibraryImportFeedback.duplicate =>
              context.l10n.libraryDuplicateMessage(message),
            LibraryImportFeedback.unsupportedFormat =>
              context.l10n.libraryUnsupportedFormat,
            LibraryImportFeedback.corruptDocument =>
              context.l10n.libraryCorruptDocument,
            LibraryImportFeedback.drmProtected =>
              context.l10n.libraryDrmProtected,
            LibraryImportFeedback.unavailable =>
              context.l10n.libraryFileUnavailable,
            LibraryImportFeedback.failure => context.l10n.libraryImportFailed,
          };
          final duplicateId = state.duplicateBookId;
          final cubit = context.read<LibraryCubit>();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              persist: false,
              content: Text(text),
              action: duplicateId == null
                  ? null
                  : SnackBarAction(
                      label: context.l10n.libraryOpenExisting,
                      onPressed: () async {
                        final book = await cubit.bookById(duplicateId);
                        if (book != null && context.mounted) {
                          await _openBook(context, book);
                        }
                      },
                    ),
            ),
          );
        },
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            if ((state.status == LibraryStatus.initial ||
                    state.status == LibraryStatus.loading) &&
                state.books.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == LibraryStatus.failure) {
              return Center(
                child: StateView(
                  icon: Icons.error_outline_rounded,
                  iconColor: context.colors.error,
                  title: context.l10n.libraryLoadError,
                  body: context.l10n.libraryLoadErrorBody,
                  action: FilledButton.icon(
                    onPressed: context.read<LibraryCubit>().load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.retry),
                  ),
                ),
              );
            }

            final hasQuery = state.query.trim().isNotEmpty;
            final isEmptyLibrary =
                state.books.isEmpty && state.trash.isEmpty && !hasQuery;
            final current = hasQuery || state.view != LibraryView.all
                ? null
                : _continueReading(state.books);
            final recentBooks = state.books
                .where((b) => b.lastReadAt != null && b.progress > 0 && b.progress < 1)
                .toList();
            final visible = state.visibleBooks;

            return RefreshIndicator(
              onRefresh: context.read<LibraryCubit>().load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (current != null) ...[
                    _SectionTitle(title: context.l10n.libraryContinueReading),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: _gutter),
                      sliver: SliverToBoxAdapter(
                        child: _ContinueReadingCard(book: current),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                  if (recentBooks.length > 1 && !hasQuery && state.view == LibraryView.all) ...[
                    _SectionTitle(title: 'Recent'),
                    SliverToBoxAdapter(
                      child: _RecentBooksCarousel(books: recentBooks),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                  if (!isEmptyLibrary) ...[
                    SliverToBoxAdapter(
                      child: _ShelfHeader(
                        state: state,
                        onSearch: _searching || hasQuery
                            ? null
                            : () => setState(() => _searching = true),
                      ),
                    ),
                    SliverToBoxAdapter(child: _ViewChips(state: state)),
                    if (_searching || hasQuery)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          _gutter,
                          4,
                          _gutter,
                          8,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: TextField(
                            autofocus: _searching && !hasQuery,
                            onChanged: context.read<LibraryCubit>().search,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: context.l10n.librarySearchHint,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(
                                tooltip: context.l10n.librarySearchClose,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: _closeSearch,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                  if (state.view == LibraryView.trash && visible.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _TrashHeader(count: visible.length),
                    ),
                  if (state.showsGroups)
                    _GroupList(state: state)
                  else if (isEmptyLibrary)
                    SliverToBoxAdapter(
                      child: _LibraryEmpty(
                        query: state.query,
                        onClearSearch: _closeSearch,
                      ),
                    )
                  else if (visible.isEmpty)
                    SliverToBoxAdapter(
                      child: hasQuery
                          ? _LibraryEmpty(
                              query: state.query,
                              onClearSearch: _closeSearch,
                            )
                          : StateView(
                              icon: state.view == LibraryView.trash
                                  ? Icons.delete_outline_rounded
                                  : Icons.collections_bookmark_outlined,
                              title: state.view == LibraryView.trash
                                  ? context.l10n.libraryTrashEmptyTitle
                                  : context.l10n.libraryViewEmptyTitle,
                              body: state.view == LibraryView.trash
                                  ? context.l10n.libraryTrashNote
                                  : context.l10n.libraryViewEmptyBody,
                            ),
                    )
                  else if (state.viewMode == LibraryViewMode.list)
                    _BookList(books: visible)
                  else
                    _BookGrid(books: visible),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BookEntity? _continueReading(List<BookEntity> books) {
    BookEntity? latest;
    for (final book in books) {
      final readAt = book.lastReadAt;
      if (readAt == null || book.progress >= 1) continue;
      if (latest == null || readAt.isAfter(latest.lastReadAt!)) latest = book;
    }
    return latest;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 8),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: GoogleFonts.newsreader(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final lastReadDays = _daysSince(book.lastReadAt);

    return Card(
      key: const Key('continue_reading_hero_card'),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
        side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
      ),
      color: WarmEditorialTokens.cardSurface,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        label: [
          book.title,
          ?book.author,
          formatCode(book.format),
          _progressLabel(context, book),
          if (lastReadDays != null) context.l10n.libraryLastRead(lastReadDays),
        ].join(', '),
        onTap: () => _openBook(context, book),
        child: InkWell(
          onTap: () => _openBook(context, book),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  height: 144,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius / 2),
                      child: BookCover(book: book),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 144,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: WarmEditorialTokens.canvasBackground,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                                  ),
                                  child: Text(
                                    formatCode(book.format),
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                  ),
                                ),
                                if (lastReadDays != null)
                                  Text(
                                    context.l10n.libraryLastRead(lastReadDays),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.newsreader(
                                fontSize: 18,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                                color: WarmEditorialTokens.textPrimaryInk,
                              ),
                            ),
                            if (book.author != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                book.author!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: WarmEditorialTokens.subtitleSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  book.currentChapterTitle ?? 'Reading',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                                Text(
                                  '${(book.progress * 100).round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: WarmEditorialTokens.accentInkBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: book.progress.clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: WarmEditorialTokens.hairlineDivider,
                                valueColor: const AlwaysStoppedAnimation(WarmEditorialTokens.accentInkBlue),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: FilledButton.icon(
                                key: const Key('resume_reading_button'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: WarmEditorialTokens.accentInkBlue,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () => _openBook(context, book),
                                icon: const Icon(Icons.auto_stories, size: 17),
                                label: Text(
                                  context.l10n.libraryResume,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentBooksCarousel extends StatelessWidget {
  const _RecentBooksCarousel({required this.books});

  final List<BookEntity> books;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('recent_books_carousel'),
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _gutter),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return Container(
            width: 210,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WarmEditorialTokens.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarmEditorialTokens.hairlineDivider),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openBook(context, book),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 54,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: BookCover(book: book, compact: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.newsreader(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                        if (book.author != null)
                          Text(
                            book.author!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: WarmEditorialTokens.subtitleSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: book.progress.clamp(0.0, 1.0),
                      strokeWidth: 2.5,
                      backgroundColor: WarmEditorialTokens.hairlineDivider,
                      valueColor: const AlwaysStoppedAnimation(WarmEditorialTokens.accentInkBlue),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({required this.state, required this.onSearch});

  final LibraryState state;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 16, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.libraryShelf,
                    style: GoogleFonts.newsreader(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: WarmEditorialTokens.textPrimaryInk,
                    ),
                  ),
                  if (!state.showsGroups) ...[
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: context.l10n.libraryBookCount(
                        state.visibleBooks.length,
                      ),
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filter & Sort',
            icon: const Icon(Icons.tune_rounded, size: 20, color: WarmEditorialTokens.subtitleSecondary),
            onPressed: () => showFilterSortSheet(context),
          ),
        ],
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});

  final List<BookEntity> books;

  static const _maxTileWidth = 132.0;
  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    final textHeight =
        scaler.scale(text.bodyMedium!.fontSize!) * 1.2 * 2 +
        scaler.scale(text.bodySmall!.fontSize!) * 1.4 +
        12;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = ((width + _spacing) / (_maxTileWidth + _spacing)).ceil();
          final tileWidth = (width - _spacing * (columns - 1)) / columns;
          return SliverGrid.builder(
            key: const Key('library_books_3col_grid'),
            itemCount: books.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: _spacing,
              mainAxisSpacing: 20,
              mainAxisExtent: tileWidth * 1.5 + textHeight,
            ),
            itemBuilder: (context, index) => _GridBook(book: books[index]),
          );
        },
      ),
    );
  }
}

class _GridBook extends StatelessWidget {
  const _GridBook({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${book.title}, ${formatCode(book.format)}, '
          '${_progressLabel(context, book)}',
      onTap: () => showBookDetailsSheet(context, book),
      customSemanticsActions: {
        CustomSemanticsAction(label: context.l10n.libraryBookActions): () =>
            showBookActions(context, book),
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => showBookDetailsSheet(context, book),
        onLongPress: () => showBookActions(context, book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                BookCover(book: book, compact: true),
                if (book.progress >= 1.0)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: WarmEditorialTokens.accentInkBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.newsreader(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: WarmEditorialTokens.textPrimaryInk,
              ),
            ),
            const SizedBox(height: 2),
            _ProgressCaption(book: book),
          ],
        ),
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});

  final List<BookEntity> books;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 4),
      sliver: SliverList.separated(
        itemCount: books.length,
        separatorBuilder: (_, _) =>
            const Divider(indent: _gutter, endIndent: _gutter, color: WarmEditorialTokens.hairlineDivider),
        itemBuilder: (context, index) => _ListBook(book: books[index]),
      ),
    );
  }
}

class _ListBook extends StatelessWidget {
  const _ListBook({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => showBookDetailsSheet(context, book),
      onLongPress: () => showBookActions(context, book),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, 12, 4, 12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                excludeSemantics: true,
                label: [
                  book.title,
                  ?book.author,
                  formatCode(book.format),
                  _progressLabel(context, book),
                ].join(', '),
                onTap: () => showBookDetailsSheet(context, book),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: BookCover(book: book, compact: true),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.newsreader(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          if (book.author != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              book.author!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          _ProgressCaption(book: book),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.libraryBookActions,
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => showBookActions(context, book),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCaption extends StatelessWidget {
  const _ProgressCaption({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Text(
      _progressLabel(context, book),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: text.bodySmall?.copyWith(
        color: colors.onSurfaceMuted,
        fontFeatures: _tabular,
      ),
    );
  }
}

String _progressLabel(BuildContext context, BookEntity book) {
  final l10n = context.l10n;
  return switch (book.progress) {
    <= 0 => l10n.libraryProgressNotStarted,
    >= 1 => l10n.libraryProgressFinished,
    final progress => switch (book.currentChapterTitle) {
      final chapter? => l10n.libraryProgressChapter(
        chapter,
        (progress * 100).round(),
      ),
      null => l10n.libraryProgressPercent((progress * 100).round()),
    },
  };
}

int? _daysSince(DateTime? date) {
  if (date == null) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  return today.difference(day).inDays.clamp(0, 9999);
}

Future<void> _openBook(BuildContext context, BookEntity book) async {
  if (book.isInTrash) return showBookActions(context, book);
  final cubit = context.read<LibraryCubit>();
  await context.router.push(ReaderRoute(book: book));
  await cubit.load();
}

class _ViewChips extends StatelessWidget {
  const _ViewChips({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LibraryCubit>();
    Widget chip(String label, LibraryView view, {String? key}) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected:
            state.view == view &&
            (key == null
                ? view != LibraryView.collection
                : state.viewKey == key),
        onSelected: (_) => cubit.selectView(view, key: key),
        selectedColor: WarmEditorialTokens.accentInkBlue,
        backgroundColor: WarmEditorialTokens.cardSurface,
        labelStyle: TextStyle(
          color: state.view == view &&
                  (key == null ? view != LibraryView.collection : state.viewKey == key)
              ? Colors.white
              : WarmEditorialTokens.textPrimaryInk,
          fontWeight: FontWeight.w500,
        ),
        shape: const StadiumBorder(side: BorderSide(color: WarmEditorialTokens.hairlineDivider)),
      ),
    );

    return SizedBox(
      height: 56,
      child: ListView(
        key: const PageStorageKey('library-views'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: _gutter,
          vertical: 4,
        ),
        children: [
          chip(l10n.libraryViewAll, LibraryView.all),
          chip(l10n.libraryShelfReading, LibraryView.reading),
          chip(l10n.libraryShelfToRead, LibraryView.toRead),
          chip(l10n.libraryShelfFinished, LibraryView.finished),
          chip(l10n.libraryFavorites, LibraryView.favorites),
          for (final collection in state.collections)
            GestureDetector(
              onLongPress: () => _collectionActions(
                context,
                collection.id,
                collection.name,
              ),
              child: chip(
                collection.name,
                LibraryView.collection,
                key: collection.id,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.libraryNewCollection),
              backgroundColor: WarmEditorialTokens.cardSurface,
              shape: const StadiumBorder(side: BorderSide(color: WarmEditorialTokens.hairlineDivider)),
              onPressed: () async {
                final name = await showCollectionNameDialog(context);
                if (name == null || !context.mounted) return;
                await cubit.createCollection(name);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _collectionActions(
  BuildContext context,
  String id,
  String name,
) async {
  final l10n = context.l10n;
  final cubit = context.read<LibraryCubit>();
  final rename = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.libraryRenameCollection),
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(l10n.libraryDeleteCollection),
            onTap: () => Navigator.of(sheetContext).pop(false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (rename == null || !context.mounted) return;
  if (rename) {
    final newName = await showCollectionNameDialog(context, initial: name);
    if (newName != null) await cubit.renameCollection(id, newName);
  } else {
    await cubit.deleteCollection(id);
  }
}

class _GroupList extends StatelessWidget {
  const _GroupList({required this.state});

  final LibraryState state;

  @override
  Widget build(BuildContext context) {
    final groups = state.view == LibraryView.authors
        ? state.authorGroups
        : state.seriesGroups;
    if (groups.isEmpty) {
      return SliverToBoxAdapter(
        child: StateView(
          icon: Icons.collections_bookmark_outlined,
          title: context.l10n.libraryViewEmptyTitle,
          body: context.l10n.libraryViewEmptyBody,
        ),
      );
    }
    final cubit = context.read<LibraryCubit>();
    return SliverList.separated(
      itemCount: groups.length,
      separatorBuilder: (_, _) =>
          const Divider(indent: _gutter, endIndent: _gutter, color: WarmEditorialTokens.hairlineDivider),
      itemBuilder: (context, index) {
        final (name, count) = groups[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: _gutter),
          title: Text(
            name,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(context.l10n.libraryGroupCount(count)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => cubit.selectView(state.view, key: name),
        );
      },
    );
  }
}

class _TrashHeader extends StatelessWidget {
  const _TrashHeader({required this.count});

  final int count;

  Future<void> _empty(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.libraryEmptyTrashTitle),
        content: Text(l10n.libraryEmptyTrashBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.libraryEmptyTrash),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<LibraryCubit>().emptyTrash();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.libraryTrashNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceMuted,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            onPressed: () => _empty(context),
            child: Text(context.l10n.libraryEmptyTrash),
          ),
        ],
      ),
    );
  }
}

class _LibraryEmpty extends StatelessWidget {
  const _LibraryEmpty({required this.query, required this.onClearSearch});

  final String query;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    if (hasQuery) {
      return StateView(
        icon: Icons.search_off_rounded,
        title: context.l10n.libraryNoResultsTitle,
        body: context.l10n.libraryNoResultsBody,
        action: OutlinedButton(
          onPressed: onClearSearch,
          child: Text(context.l10n.librarySearchClear),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/images/empty_library_shelf.png',
                key: const Key('empty_library_shelf_image'),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.auto_stories_outlined,
                  size: 80,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your shelf is quiet',
              textAlign: TextAlign.center,
              style: GoogleFonts.newsreader(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: WarmEditorialTokens.textPrimaryInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Import a DRM-free book or a whole folder to start reading.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: WarmEditorialTokens.subtitleSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      key: const Key('empty_import_files_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: WarmEditorialTokens.accentInkBlue,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => context.read<LibraryCubit>().importDocument(),
                      icon: const Icon(Icons.upload_file_rounded, size: 20),
                      label: Text(
                        'Import files',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      key: const Key('empty_import_folder_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WarmEditorialTokens.accentInkBlue,
                        side: const BorderSide(color: WarmEditorialTokens.accentInkBlue, width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => context.read<LibraryCubit>().importFolder(),
                      icon: const Icon(Icons.folder_open_rounded, size: 20),
                      label: Text(
                        'Import a folder',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: WarmEditorialTokens.cardSurface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: WarmEditorialTokens.hairlineDivider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Supports EPUB, PDF, TXT, Markdown, HTML, FB2 · Stored locally',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: WarmEditorialTokens.subtitleSecondary,
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
}
