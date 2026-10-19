import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

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
            return _LibraryFailure(message: state.errorMessage);
          }

          return RefreshIndicator(
            onRefresh: context.read<LibraryCubit>().load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstant.horizontalGap16,
                    AppConstant.verticalGap16,
                    AppConstant.horizontalGap16,
                    100,
                  ),
                  sliver: SliverList.list(
                    children: [
                      TextField(
                        onChanged: context.read<LibraryCubit>().search,
                        decoration: InputDecoration(
                          hintText: context.l10n.librarySearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: theme.surfaceElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstant.borderRadius16,
                            ),
                            borderSide: BorderSide(color: theme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstant.borderRadius16,
                            ),
                            borderSide: BorderSide(color: theme.border),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<LibrarySort>(
                              initialValue: state.sort,
                              tooltip: context.l10n.librarySort,
                              icon: const Icon(Icons.sort_rounded),
                              onSelected: context
                                  .read<LibraryCubit>()
                                  .changeSort,
                              itemBuilder: (context) => [
                                _sortItem(
                                  context,
                                  LibrarySort.recent,
                                  context.l10n.librarySortRecent,
                                ),
                                _sortItem(
                                  context,
                                  LibrarySort.title,
                                  context.l10n.librarySortTitle,
                                ),
                                _sortItem(
                                  context,
                                  LibrarySort.author,
                                  context.l10n.librarySortAuthor,
                                ),
                                _sortItem(
                                  context,
                                  LibrarySort.progress,
                                  context.l10n.librarySortProgress,
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: context
                                  .read<LibraryCubit>()
                                  .toggleViewMode,
                              tooltip: state.viewMode == LibraryViewMode.grid
                                  ? context.l10n.libraryListView
                                  : context.l10n.libraryGridView,
                              icon: Icon(
                                state.viewMode == LibraryViewMode.grid
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(AppConstant.verticalGap20),
                      if (state.books.isEmpty)
                        _LibraryEmpty(query: state.query)
                      else if (state.viewMode == LibraryViewMode.list)
                        _BookList(books: state.books)
                      else
                        _BookGrid(books: state.books),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PopupMenuItem<LibrarySort> _sortItem(
    BuildContext context,
    LibrarySort value,
    String label,
  ) {
    return PopupMenuItem<LibrarySort>(value: value, child: Text(label));
  }
}

/*
 * Keep the book cards below the stateful library shell. This makes the sort
 * and view controls rebuild without recreating the card layout code.
 */
class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});

  final List<BookEntity> books;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .61,
      ),
      itemBuilder: (context, index) => _BookCard(book: books[index]),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});

  final List<BookEntity> books;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      separatorBuilder: (_, _) => Gap(AppConstant.verticalGap8),
      itemBuilder: (context, index) => _BookListTile(book: books[index]),
    );
  }
}

class _BookListTile extends StatelessWidget {
  const _BookListTile({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: theme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstant.borderRadius16),
        side: BorderSide(color: theme.border),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => context.router.push(ReaderRoute(book: book)),
            child: Padding(
              padding: EdgeInsets.all(AppConstant.horizontalGap12),
              child: Row(
                children: [
                  _BookCoverPlaceholder(book: book, size: 76),
                  Gap(AppConstant.horizontalGap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyle.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gap(AppConstant.verticalGap4),
                        Text(
                          book.author ?? context.l10n.libraryUnknownAuthor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyle.bodySmall.copyWith(
                            color: theme.onSurface.withAlpha(153),
                          ),
                        ),
                        Gap(AppConstant.verticalGap12),
                        _BookProgressIndicator(progress: book.progress),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: 2, right: 2, child: _BookMenu(book: book)),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: theme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstant.borderRadius16),
        side: BorderSide(color: theme.border),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => context.router.push(ReaderRoute(book: book)),
            child: Padding(
              padding: EdgeInsets.all(AppConstant.horizontalGap12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BookCoverPlaceholder(
                      book: book,
                      size: double.infinity,
                    ),
                  ),
                  Gap(AppConstant.verticalGap12),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap(AppConstant.verticalGap4),
                  Text(
                    book.author ?? context.l10n.libraryUnknownAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyle.bodySmall.copyWith(
                      color: theme.onSurface.withAlpha(153),
                    ),
                  ),
                  Gap(AppConstant.verticalGap12),
                  _BookProgressIndicator(progress: book.progress),
                ],
              ),
            ),
          ),
          Positioned(top: 2, right: 2, child: _BookMenu(book: book)),
        ],
      ),
    );
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder({required this.book, required this.size});

  final BookEntity book;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Container(
      width: size == double.infinity ? double.infinity : size,
      height: size == double.infinity ? null : size * 1.25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _formatIcon(book.format),
              color: theme.primary,
              size: size == double.infinity ? 44 : 30,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _FormatBadge(format: book.format),
          ),
        ],
      ),
    );
  }

  IconData _formatIcon(DocumentFormat format) {
    return switch (format) {
      DocumentFormat.pdf => Icons.picture_as_pdf_rounded,
      DocumentFormat.epub => Icons.menu_book_rounded,
      _ => Icons.article_rounded,
    };
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});

  final DocumentFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.border),
      ),
      child: Text(
        _formatLabel(format),
        style: context.textStyle.labelSmall.copyWith(
          color: theme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }

  String _formatLabel(DocumentFormat format) {
    return switch (format) {
      DocumentFormat.epub => 'EPUB',
      DocumentFormat.pdf => 'PDF',
      DocumentFormat.txt => 'TXT',
      DocumentFormat.markdown => 'MD',
      DocumentFormat.html => 'HTML',
      DocumentFormat.fb2 => 'FB2',
    };
  }
}

class _BookProgressIndicator extends StatelessWidget {
  const _BookProgressIndicator({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: progress, minHeight: 5),
        ),
        Gap(AppConstant.verticalGap4),
        _BookProgressLabel(progress: progress),
      ],
    );
  }
}

class _BookProgressLabel extends StatelessWidget {
  const _BookProgressLabel({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final description = switch (progress) {
      <= 0 => context.l10n.libraryProgressNotStarted,
      >= 1 => context.l10n.libraryProgressFinished,
      _ => context.l10n.libraryProgressInProgress,
    };
    return Text(
      '$percent% • $description',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textStyle.labelSmall.copyWith(
        color: context.colors.primary,
      ),
    );
  }
}

enum _BookMenuAction { delete }

class _BookMenu extends StatelessWidget {
  const _BookMenu({required this.book});

  final BookEntity book;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BookMenuAction>(
      tooltip: context.l10n.libraryDelete,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (_) => _showDeleteBookDialog(context, book),
      itemBuilder: (context) => [
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.delete,
          child: Text(context.l10n.libraryDelete),
        ),
      ],
    );
  }
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
        FilledButton.tonal(
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
    final theme = context.colors;
    final hasQuery = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, color: theme.primary, size: 64),
            Gap(AppConstant.verticalGap16),
            Text(
              hasQuery
                  ? context.l10n.libraryNoResultsTitle
                  : context.l10n.libraryEmptyTitle,
              style: context.textStyle.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(AppConstant.verticalGap8),
            Text(
              hasQuery
                  ? context.l10n.libraryNoResultsBody
                  : context.l10n.libraryEmptyBody,
              textAlign: TextAlign.center,
              style: context.textStyle.bodyMedium.copyWith(
                color: theme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryFailure extends StatelessWidget {
  const _LibraryFailure({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstant.horizontalGap20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: theme.error, size: 56),
            Gap(AppConstant.verticalGap12),
            Text(
              context.l10n.libraryLoadError,
              style: context.textStyle.titleMedium,
            ),
            if (message != null) ...[
              Gap(AppConstant.verticalGap4),
              Text(message!, textAlign: TextAlign.center),
            ],
            Gap(AppConstant.verticalGap12),
            FilledButton.icon(
              onPressed: context.read<LibraryCubit>().load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
