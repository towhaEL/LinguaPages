import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_cubit.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_state.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';
import 'package:share_plus/share_plus.dart';

const _gutter = 16.0;

/// Every highlight, note and bookmark across the library.
@RoutePage()
class AnnotationsScreen extends StatelessWidget {
  const AnnotationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<AnnotationsCubit>()..load(),
      child: const _AnnotationsView(),
    );
  }
}

class _AnnotationsView extends StatelessWidget {
  const _AnnotationsView();

  Future<void> _copy(BuildContext context, String markdown) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.readerExportCopied;
    await Clipboard.setData(ClipboardData(text: markdown));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  Future<void> _share(BuildContext buttonContext, String markdown) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    return SharePlus.instance.share(
      ShareParams(
        text: markdown,
        subject: buttonContext.l10n.annotationsTitle,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AnnotationsCubit, AnnotationsState>(
      builder: (context, state) {
        final visible = state.visible;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.annotationsTitle),
            actions: [
              // Exports exactly what the filters show.
              IconButton(
                tooltip: l10n.readerNotesCopyMarkdown,
                icon: const Icon(Icons.copy_all_outlined),
                onPressed: visible.isEmpty
                    ? null
                    : () => _copy(context, state.toMarkdown()),
              ),
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: l10n.readerNotesShareMarkdown,
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: visible.isEmpty
                      ? null
                      : () => _share(buttonContext, state.toMarkdown()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: switch (state.status) {
            AnnotationsStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            AnnotationsStatus.failure => Center(
              child: StateView(
                icon: Icons.error_outline_rounded,
                iconColor: context.colors.error,
                title: l10n.annotationsLoadError,
                action: FilledButton(
                  onPressed: context.read<AnnotationsCubit>().load,
                  child: Text(l10n.retry),
                ),
              ),
            ),
            AnnotationsStatus.success when state.items.isEmpty => Center(
              child: StateView(
                icon: Icons.sticky_note_2_outlined,
                title: l10n.readerNotesEmptyTitle,
                body: l10n.readerNotesEmptyBody,
              ),
            ),
            AnnotationsStatus.success => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Filters(state: state)),
                if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: StateView(
                      icon: Icons.filter_alt_off_outlined,
                      title: l10n.readerNotesFilterEmpty,
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) =>
                        const Divider(indent: _gutter, endIndent: _gutter),
                    itemBuilder: (context, index) =>
                        _AnnotationRow(item: visible[index]),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          },
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final AnnotationsState state;

  String _colorLabel(BuildContext context, HighlightColor color) =>
      switch (color) {
        HighlightColor.yellow => context.l10n.readerHighlightYellow,
        HighlightColor.green => context.l10n.readerHighlightGreen,
        HighlightColor.blue => context.l10n.readerHighlightBlue,
        HighlightColor.pink => context.l10n.readerHighlightPink,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AnnotationsCubit>();
    final books = state.books;
    final bookTitle = books
        .where((book) => book.id == state.bookId)
        .firstOrNull
        ?.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter, 4),
          child: TextField(
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.annotationsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: _gutter,
              vertical: 4,
            ),
            children: [
              for (final (type, label) in [
                (AnnotationType.all, l10n.annotationsAll),
                (AnnotationType.highlights, l10n.annotationsHighlights),
                (AnnotationType.notes, l10n.annotationsNotes),
                (AnnotationType.bookmarks, l10n.annotationsBookmarks),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: state.type == type,
                    onSelected: (_) => cubit.setType(type),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: _gutter,
              vertical: 4,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String?>(
                  tooltip: l10n.annotationsBook,
                  onSelected: cubit.setBook,
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text(l10n.annotationsAllBooks)),
                    for (final book in books)
                      PopupMenuItem(value: book.id, child: Text(book.title)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.menu_book_outlined, size: 18),
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        bookTitle ?? l10n.annotationsAllBooks,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              for (final color in HighlightColor.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: CircleAvatar(
                      backgroundColor: Color(color.tintArgb(darkPage: true)),
                    ),
                    label: Text(_colorLabel(context, color)),
                    selected: state.color == color,
                    showCheckmark: false,
                    onSelected: (selected) =>
                        cubit.setColor(selected ? color : null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnotationRow extends StatelessWidget {
  const _AnnotationRow({required this.item});

  final AnnotationItem item;

  Future<void> _open(BuildContext context) async {
    final cubit = context.read<AnnotationsCubit>();
    await context.router.push(
      ReaderRoute(book: item.book, openAt: item.note.locator),
    );
    // Notes may have been edited or deleted in the reader.
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final note = item.note;
    final highlight = note.highlight;
    final meta = [
      item.book.title,
      ?locatorLabel(context, note.locator),
      DateFormat.MMMd().format(note.createdAt),
    ].join(' · ');

    return InkWell(
      onTap: () => _open(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_gutter + 4, 12, _gutter, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlight != null)
              // The quote wears its highlight, as in the reader's notes.
              Text.rich(
                TextSpan(
                  text: highlight.selectedText,
                  style: TextStyle(
                    backgroundColor: Color(
                      highlight.color.tintArgb(darkPage: true),
                    ),
                  ),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(height: 1.5),
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.bookmark_rounded,
                    size: 18,
                    color: colors.onSurfaceMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.bookmark!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            if (highlight?.note case final noteText?) ...[
              const SizedBox(height: 8),
              Text(
                noteText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall?.copyWith(
                color: colors.onSurfaceMuted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
