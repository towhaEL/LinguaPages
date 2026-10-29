import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/book/band_progress_bar.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';

const _gutter = 16.0;
const _tabular = [FontFeature.tabularFigures()];

class LibraryContent extends StatefulWidget {
  const LibraryContent({super.key});

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  /// Search opens on demand so the shelf, not a field, follows the card.
  var _searching = false;

  void _closeSearch() {
    setState(() => _searching = false);
    context.read<LibraryCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryCubit, LibraryState>(
      listenWhen: (previous, current) =>
          current.importFeedback != null &&
          (current.importFeedback != previous.importFeedback ||
              current.importMessage != previous.importMessage),
      listener: (context, state) {
        final feedback = state.importFeedback;
        final message = state.importMessage;
        if (feedback == null || message == null) return;
        final text = switch (feedback) {
          LibraryImportFeedback.imported => context.l10n.libraryImportedMessage(
            message,
          ),
          LibraryImportFeedback.duplicate =>
            context.l10n.libraryDuplicateMessage(message),
          LibraryImportFeedback.unsupportedFormat =>
            context.l10n.libraryUnsupportedFormat,
          LibraryImportFeedback.corruptDocument =>
            context.l10n.libraryCorruptDocument,
          LibraryImportFeedback.unavailable =>
            context.l10n.libraryFileUnavailable,
          LibraryImportFeedback.failure => context.l10n.libraryImportFailed,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(text)));
      },
      child: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          if (state.status == LibraryStatus.loading && state.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LibraryStatus.failure) {
            return Center(
              child: StateView(
                icon: Icons.error_outline_rounded,
                iconColor: context.colors.error,
                title: context.l10n.libraryLoadError,
                body: state.errorMessage,
                action: FilledButton.icon(
                  onPressed: context.read<LibraryCubit>().load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.l10n.retry),
                ),
              ),
            );
          }

          final hasQuery = state.query.trim().isNotEmpty;
          final isEmptyLibrary = state.books.isEmpty && !hasQuery;
          final current = hasQuery ? null : _continueReading(state.books);

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
                if (state.books.isEmpty)
                  SliverToBoxAdapter(child: _LibraryEmpty(query: state.query))
                else if (state.viewMode == LibraryViewMode.list)
                  _BookList(books: state.books)
                else
                  _BookGrid(books: state.books),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// The most recently opened book that is not finished yet.
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
      padding: const EdgeInsets.fromLTRB(_gutter + 4, 8, _gutter, 12),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final band = context.bands.forFormat(book.format);
    final percent = (book.progress * 100).round();
    final lastReadDays = _daysSince(book.lastReadAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openBook(context, book),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 96, child: BookCover(book: book)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge?.copyWith(
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (book.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    BandProgressBar(progress: book.progress, color: band),
                    const SizedBox(height: 6),
                    // Books carry no chapter or reading-speed data; position
                    // is shown as percent read and recency.
                    DefaultTextStyle.merge(
                      style: text.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontFeatures: _tabular,
                      ),
                      child: Row(
                        children: [
                          Text(context.l10n.libraryProgressPercent(percent)),
                          const Spacer(),
                          if (lastReadDays != null)
                            Text(context.l10n.libraryLastRead(lastReadDays)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _openBook(context, book),
                      child: Text(context.l10n.libraryResume),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({required this.state, required this.onSearch});

  final LibraryState state;

  /// Null while the inline search field is open; the field owns closing.
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final cubit = context.read<LibraryCubit>();
    final isGrid = state.viewMode == LibraryViewMode.grid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter + 4, 16, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: context.l10n.libraryShelf),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: context.l10n.libraryBookCount(state.books.length),
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      fontFeatures: _tabular,
                    ),
                  ),
                ],
              ),
              semanticsLabel:
                  '${context.l10n.libraryShelf}, '
                  '${context.l10n.libraryBookCount(state.books.length)}',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (onSearch != null)
            IconButton(
              onPressed: onSearch,
              tooltip: context.l10n.librarySearchHint,
              icon: const Icon(Icons.search_rounded),
            ),
          PopupMenuButton<LibrarySort>(
            initialValue: state.sort,
            tooltip: context.l10n.librarySort,
            icon: const Icon(Icons.sort_rounded),
            onSelected: cubit.changeSort,
            itemBuilder: (context) => [
              for (final (sort, label) in [
                (LibrarySort.recent, context.l10n.librarySortRecent),
                (LibrarySort.title, context.l10n.librarySortTitle),
                (LibrarySort.author, context.l10n.librarySortAuthor),
                (LibrarySort.progress, context.l10n.librarySortProgress),
              ])
                PopupMenuItem(value: sort, child: Text(label)),
            ],
          ),
          IconButton(
            onPressed: cubit.toggleViewMode,
            tooltip: isGrid
                ? context.l10n.libraryListView
                : context.l10n.libraryGridView,
            icon: Icon(
              isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
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
    // Two title lines and one caption line, measured at the user's text size.
    final textHeight =
        scaler.scale(text.bodyMedium!.fontSize!) * 1.2 * 2 +
        scaler.scale(text.bodySmall!.fontSize!) * 1.4 +
        12;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final columns = ((width + _spacing) / (_maxTileWidth + _spacing))
              .ceil();
          final tileWidth = (width - _spacing * (columns - 1)) / columns;
          return SliverGrid.builder(
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
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _openBook(context, book),
      onLongPress: () => _showBookActions(context, book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(book: book, compact: true),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          _ProgressCaption(book: book),
        ],
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
            const Divider(indent: _gutter, endIndent: _gutter),
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
      onTap: () => _openBook(context, book),
      onLongPress: () => _showBookActions(context, book),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, 12, 4, 12),
        child: Row(
          children: [
            SizedBox(width: 44, child: BookCover(book: book, compact: true)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (book.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  _ProgressCaption(book: book),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.libraryBookActions,
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showBookActions(context, book),
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
    final l10n = context.l10n;
    final label = switch (book.progress) {
      <= 0 => l10n.libraryProgressNotStarted,
      >= 1 => l10n.libraryProgressFinished,
      final progress => l10n.libraryProgressPercent((progress * 100).round()),
    };
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: context.colors.onSurfaceMuted,
        fontFeatures: _tabular,
      ),
    );
  }
}

/// Whole calendar days since [date], or null when it was never read.
int? _daysSince(DateTime? date) {
  if (date == null) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  return today.difference(day).inDays.clamp(0, 9999);
}

/// Opens the reader, then refreshes progress and the continue-reading card.
Future<void> _openBook(BuildContext context, BookEntity book) async {
  final cubit = context.read<LibraryCubit>();
  await context.router.push(ReaderRoute(book: book));
  await cubit.load();
}

Future<void> _showBookActions(BuildContext context, BookEntity book) async {
  final remove = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(sheetContext.l10n.libraryDelete),
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (remove != true || !context.mounted) return;
  await _showDeleteBookDialog(context, book);
}

Future<void> _showDeleteBookDialog(
  BuildContext context,
  BookEntity book,
) async {
  final data = await showDialog<DeleteBookData>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.libraryDeleteTitle),
      content: Text(context.l10n.libraryDeleteBody(book.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(DeleteBookData.keep),
          child: Text(context.l10n.libraryDeleteKeepData),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: () =>
              Navigator.of(dialogContext).pop(DeleteBookData.delete),
          child: Text(context.l10n.libraryDeleteAllData),
        ),
      ],
    ),
  );
  if (data == null || !context.mounted) return;

  final deleted = await context.read<LibraryCubit>().deleteBook(
    book: book,
    data: data,
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        deleted
            ? context.l10n.libraryDeletedMessage(book.title)
            : context.l10n.libraryDeleteFailed,
      ),
    ),
  );
}

class _LibraryEmpty extends StatelessWidget {
  const _LibraryEmpty({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return StateView(
      icon: hasQuery ? Icons.search_off_rounded : Icons.auto_stories_outlined,
      title: hasQuery
          ? context.l10n.libraryNoResultsTitle
          : context.l10n.libraryEmptyTitle,
      body: hasQuery
          ? context.l10n.libraryNoResultsBody
          : context.l10n.libraryEmptyBody,
      action: hasQuery
          ? null
          : FilledButton.icon(
              onPressed: context.read<LibraryCubit>().importDocument,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.libraryImport),
            ),
    );
  }
}
