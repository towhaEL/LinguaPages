import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_cubit.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_state.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';
import 'package:lingua_pages/presentation/widgets/widgets.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_mini_player.dart';
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
      child: const _ResponsiveAnnotations(),
    );
  }
}

/// How the success body is arranged.
enum _Layout {
  /// Phone portrait: filters scroll away above the list.
  compact,

  /// Phone landscape and tablet portrait: filters in a side panel.
  split,

  /// Tablet landscape: filters, list, and the selected annotation in full.
  listDetail,
}

class _ResponsiveAnnotations extends Screen {
  const _ResponsiveAnnotations();

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const _AnnotationsView(layout: _Layout.compact);
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return const _AnnotationsView(layout: _Layout.split);
  }

  @override
  Widget buildTabletView(BuildContext context) {
    return _AnnotationsView(
      layout: Screen.isTabletLandscape(context)
          ? _Layout.listDetail
          : _Layout.split,
    );
  }
}

class _AnnotationsView extends StatelessWidget {
  const _AnnotationsView({required this.layout});

  final _Layout layout;

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
        return ReadAloudMiniPlayerHost(
          child: Scaffold(
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
                    key: const Key('export_markdown_button'),
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
              AnnotationsStatus.success => switch (layout) {
                _Layout.compact => _AnnotationList(
                  visible: visible,
                  header: _Filters(state: state),
                ),
                _Layout.split => TwoPane(
                  startWidth: 300,
                  start: _Filters(state: state, vertical: true),
                  end: _AnnotationList(visible: visible),
                ),
                _Layout.listDetail => TwoPane(
                  startWidth: 280,
                  start: _Filters(state: state, vertical: true),
                  end: _ListDetail(visible: visible),
                ),
              },
            },
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state, this.vertical = false});

  final AnnotationsState state;

  /// A side panel of wrapping chip groups instead of two scrolling rows.
  final bool vertical;

  String _colorLabel(BuildContext context, HighlightColor color) =>
      switch (color) {
        HighlightColor.yellow => context.l10n.readerHighlightYellow,
        HighlightColor.green => context.l10n.readerHighlightGreen,
        HighlightColor.blue => context.l10n.readerHighlightBlue,
        HighlightColor.pink => context.l10n.readerHighlightPink,
        HighlightColor.orange => context.l10n.readerHighlightOrange,
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
    // Initial value only: the cubit owns the query, and this keeps it when
    // a rotation swaps the layout.
    final search = TextFormField(
      initialValue: state.query,
      onChanged: cubit.search,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.annotationsSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
    final typeChips = [
      for (final (type, label) in [
        (AnnotationType.all, l10n.annotationsAll),
        (AnnotationType.highlights, l10n.annotationsHighlights),
        (AnnotationType.notes, l10n.annotationsNotes),
        (AnnotationType.bookmarks, l10n.annotationsBookmarks),
      ])
        ChoiceChip(
          label: Text(label),
          selected: state.type == type,
          onSelected: (_) => cubit.setType(type),
        ),
    ];
    final bookPicker = PopupMenuButton<String?>(
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
          constraints: BoxConstraints(maxWidth: vertical ? 200 : 160),
          child: Text(
            bookTitle ?? l10n.annotationsAllBooks,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    final colorChips = [
      for (final color in HighlightColor.values)
        FilterChip(
          avatar: CircleAvatar(
            backgroundColor: Color(color.tintArgb(darkPage: true)),
          ),
          label: Text(_colorLabel(context, color)),
          selected: state.color == color,
          showCheckmark: false,
          onSelected: (selected) => cubit.setColor(selected ? color : null),
        ),
    ];

    if (vertical) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 24),
        children: [
          search,
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: typeChips),
          const SizedBox(height: 16),
          Align(alignment: AlignmentDirectional.centerStart, child: bookPicker),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: colorChips),
        ],
      );
    }

    Widget chipRow(List<Widget> chips) => SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _gutter, vertical: 4),
        children: [
          for (final chip in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: chip),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter, 4),
          child: search,
        ),
        chipRow(typeChips),
        chipRow([bookPicker, ...colorChips]),
      ],
    );
  }
}

/// The annotation cards, with an optional [header] that scrolls with them.
class _AnnotationList extends StatelessWidget {
  const _AnnotationList({
    required this.visible,
    this.header,
    this.selectedId,
    this.onSelect,
  });

  final List<AnnotationItem> visible;
  final Widget? header;
  final String? selectedId;

  /// When set, tapping a card selects it instead of opening the reader.
  final ValueChanged<AnnotationItem>? onSelect;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (header case final header?) SliverToBoxAdapter(child: header),
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: StateView(
              icon: Icons.filter_alt_off_outlined,
              title: context.l10n.readerNotesFilterEmpty,
            ),
          )
        else
          SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final item = visible[index];
              return _AnnotationRow(
                item: item,
                index: index,
                selected: item.note.id == selectedId,
                onTap: onSelect == null ? null : () => onSelect!(item),
              );
            },
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

/// The list beside the selected annotation shown in full. Selection falls
/// back to the first visible annotation when filters hide the selected one.
class _ListDetail extends StatefulWidget {
  const _ListDetail({required this.visible});

  final List<AnnotationItem> visible;

  @override
  State<_ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<_ListDetail> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final visible = widget.visible;
    if (visible.isEmpty) return _AnnotationList(visible: visible);
    final selected =
        visible.where((item) => item.note.id == _selectedId).firstOrNull ??
        visible.first;
    return TwoPane(
      startWidth: 360,
      start: _AnnotationList(
        visible: visible,
        selectedId: selected.note.id,
        onSelect: (item) => setState(() => _selectedId = item.note.id),
      ),
      end: _AnnotationDetail(key: ValueKey(selected.note.id), item: selected),
    );
  }
}

/// Opens the reader at [item], then reloads: notes may have been edited or
/// deleted there.
Future<void> _openInReader(BuildContext context, AnnotationItem item) async {
  final cubit = context.read<AnnotationsCubit>();
  await context.router.push(
    ReaderRoute(book: item.book, openAt: item.note.locator),
  );
  await cubit.load();
}

String _meta(BuildContext context, AnnotationItem item) => [
  item.book.title,
  ?locatorLabel(context, item.note.locator),
  DateFormat.MMMd().format(item.note.createdAt),
].join(' · ');

Color _stripColor(BuildContext context, AnnotationItem item) {
  final highlight = item.note.highlight;
  return highlight != null
      ? Color(highlight.color.tintArgb(darkPage: false))
      : context.accent;
}

/// One annotation at reading size, untruncated, with a way back to the book.
class _AnnotationDetail extends StatelessWidget {
  const _AnnotationDetail({super.key, required this.item});

  final AnnotationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final note = item.note;
    final highlight = note.highlight;
    return ListView(
      key: const Key('annotation_detail'),
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      children: [
        Text(
          _meta(context, item),
          style: text.bodySmall?.copyWith(
            color: colors.onSurfaceMuted,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsetsDirectional.only(start: 16),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: _stripColor(context, item), width: 4),
            ),
          ),
          child: highlight != null
              ? SelectableText(
                  '“${highlight.selectedText}”',
                  style: GoogleFonts.newsreader(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: colors.onSurface,
                    height: 1.5,
                  ),
                )
              : Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: context.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.bookmark!.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (highlight?.note case final noteText?) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.hairline),
            ),
            child: SelectableText(
              noteText,
              style: GoogleFonts.inter(fontSize: 15, height: 1.5),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            key: const Key('annotation_detail_open'),
            onPressed: () => _openInReader(context, item),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: Text(context.l10n.readAloudOpenBook(item.book.title)),
          ),
        ),
      ],
    );
  }
}

class _AnnotationRow extends StatelessWidget {
  const _AnnotationRow({
    required this.item,
    required this.index,
    this.selected = false,
    this.onTap,
  });

  final AnnotationItem item;
  final int index;
  final bool selected;

  /// Replaces opening the reader, for list–detail selection.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final note = item.note;
    final highlight = note.highlight;
    final meta = _meta(context, item);
    final stripColor = _stripColor(context, item);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter, vertical: 6),
      child: Card(
        key: Key('annotation_item_card_${index + 1}'),
        elevation: 0,
        color: WarmEditorialTokens.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: selected
              ? BorderSide(color: context.accent, width: 1.5)
              : const BorderSide(color: WarmEditorialTokens.hairlineDivider),
        ),
        child: InkWell(
          onTap: onTap ?? () => _openInReader(context, item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: stripColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (highlight != null)
                        Text(
                          '“${highlight.selectedText}”',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.newsreader(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: colors.onSurface,
                            height: 1.45,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              size: 18,
                              color: context.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note.bookmark!.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.newsreader(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (highlight?.note case final noteText?) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.hairline),
                          ),
                          child: Text(
                            noteText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 11,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
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
