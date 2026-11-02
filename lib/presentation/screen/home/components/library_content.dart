import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_book_actions.dart';
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
            LibraryImportFeedback.unavailable =>
              context.l10n.libraryFileUnavailable,
            LibraryImportFeedback.failure => context.l10n.libraryImportFailed,
          };
          final duplicateId = state.duplicateBookId;
          final cubit = context.read<LibraryCubit>();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // Optional actions; the message still times out.
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
            // Before the first load starts the status is still initial.
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
                  // The raw error is logged; the reader gets reassurance.
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
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        ),
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
    final lastReadDays = _daysSince(book.lastReadAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      // Read once as "title, author, format, progress, recency"; the Resume
      // button below is the single action.
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
                      DefaultTextStyle.merge(
                        style: text.labelMedium?.copyWith(
                          color: colors.onSurfaceMuted,
                          fontFeatures: _tabular,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _progressLabel(context, book),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                  // Author and series lists count groups, not books.
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
              semanticsLabel:
                  '${context.l10n.libraryShelf}, '
                  '${context.l10n.libraryBookCount(state.visibleBooks.length)}',
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
    // One announcement per book; long-press actions stay reachable from
    // TalkBack's actions menu.
    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${book.title}, ${formatCode(book.format)}, '
          '${_progressLabel(context, book)}',
      onTap: () => _openBook(context, book),
      customSemanticsActions: {
        CustomSemanticsAction(label: context.l10n.libraryBookActions): () =>
            showBookActions(context, book),
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _openBook(context, book),
        onLongPress: () => showBookActions(context, book),
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
      onLongPress: () => showBookActions(context, book),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter, 12, 4, 12),
        child: Row(
          children: [
            // The row announces title, author, format and progress once; the
            // trailing actions button stays a separate target.
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
                onTap: () => _openBook(context, book),
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
    return Text(
      _progressLabel(context, book),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: context.colors.onSurfaceMuted,
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
  // A book in Trash is restored before it is read again.
  if (book.isInTrash) return showBookActions(context, book);
  final cubit = context.read<LibraryCubit>();
  await context.router.push(ReaderRoute(book: book));
  await cubit.load();
}

/// Shelves, collections, authors, series and Trash as one chip row.
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
      ),
    );
    final picked = state.viewKey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            // Keeps the row where it was when the cards above come and go.
            key: const PageStorageKey('library-views'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: _gutter,
              vertical: 4,
            ),
            children: [
              chip(l10n.libraryViewAll, LibraryView.all),
              chip(l10n.libraryShelfToRead, LibraryView.toRead),
              chip(l10n.libraryShelfReading, LibraryView.reading),
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
                  onPressed: () async {
                    final name = await showCollectionNameDialog(context);
                    if (name == null) return;
                    final created = await cubit.createCollection(name);
                    if (created != null) {
                      cubit.selectView(LibraryView.collection, key: created.id);
                    }
                  },
                ),
              ),
              chip(l10n.libraryAuthors, LibraryView.authors),
              chip(l10n.librarySeries, LibraryView.series),
              chip(l10n.libraryTrash, LibraryView.trash),
            ],
          ),
        ),
        // An author or series picked from its group list, with a way back.
        if (picked != null &&
            (state.view == LibraryView.authors ||
                state.view == LibraryView.series))
          Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 4),
            child: InputChip(
              label: Text(picked),
              onDeleted: () => cubit.selectView(state.view),
              deleteButtonTooltipMessage: state.view == LibraryView.authors
                  ? l10n.libraryAuthors
                  : l10n.librarySeries,
            ),
          ),
        if (state.selectedCollection case final collection?)
          Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 0, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    collection.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.libraryRenameCollection,
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: () => _collectionActions(
                    context,
                    collection.id,
                    collection.name,
                  ),
                ),
              ],
            ),
          ),
      ],
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
    // The books stay in the library; only the grouping goes.
    await cubit.deleteCollection(id);
  }
}

/// Authors or series with their book counts; tapping one shows its books.
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
          const Divider(indent: _gutter, endIndent: _gutter),
      itemBuilder: (context, index) {
        final (name, count) = groups[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: _gutter + 4),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.fromLTRB(_gutter + 4, 0, _gutter, 4),
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
    return StateView(
      icon: hasQuery ? Icons.search_off_rounded : Icons.auto_stories_outlined,
      title: hasQuery
          ? context.l10n.libraryNoResultsTitle
          : context.l10n.libraryEmptyTitle,
      body: hasQuery
          ? context.l10n.libraryNoResultsBody
          : context.l10n.libraryEmptyBody,
      action: hasQuery
          ? OutlinedButton(
              onPressed: onClearSearch,
              child: Text(context.l10n.librarySearchClear),
            )
          : FilledButton.icon(
              onPressed: context.read<LibraryCubit>().importDocument,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.libraryImport),
            ),
    );
  }
}
