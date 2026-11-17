import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// A bookmark or a highlight in the Notes sheet.
class ReaderNote {
  const ReaderNote.bookmark(BookmarkEntity value)
    : bookmark = value,
      highlight = null;

  const ReaderNote.highlight(HighlightEntity value)
    : bookmark = null,
      highlight = value;

  final BookmarkEntity? bookmark;
  final HighlightEntity? highlight;

  String get id => bookmark?.id ?? highlight!.id;
  DateTime get createdAt => bookmark?.createdAt ?? highlight!.createdAt;
  DocumentLocator get locator => bookmark?.locator ?? highlight!.locator;
  bool get isHighlight => highlight != null;
}

enum _Tab { highlights, bookmarks }

/// The book's highlights and bookmarks, with export and share. Chapters live
/// in the table of contents drawer.
class NotesSheet extends StatefulWidget {
  const NotesSheet({
    required this.notes,
    required this.onSelected,
    required this.onDeleted,
    required this.onEdited,
    required this.onExport,
    required this.onShare,
    this.initialTab,
    super.key,
  });

  final List<ReaderNote> notes;
  final ValueChanged<ReaderNote> onSelected;
  final Future<void> Function(ReaderNote note) onDeleted;
  final Future<HighlightEntity?> Function(HighlightEntity highlight) onEdited;

  /// Exports what the sheet currently shows, after any edits or deletions.
  final Future<void> Function(
    List<HighlightEntity> highlights,
    List<BookmarkEntity> bookmarks,
  )
  onExport;

  /// Shares what the sheet shows; [origin] anchors the iPad share popover.
  final Future<void> Function(
    List<HighlightEntity> highlights,
    List<BookmarkEntity> bookmarks,
    Rect? origin,
  )
  onShare;

  /// 'Bookmarks' opens on bookmarks; anything else on highlights.
  final String? initialTab;

  @override
  State<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<NotesSheet> {
  late final List<ReaderNote> _notes = [...widget.notes]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  late _Tab _activeTab = _parseInitialTab(widget.initialTab);

  _Tab _parseInitialTab(String? tab) {
    if (tab == 'Bookmarks') return _Tab.bookmarks;
    if (tab == 'Highlights') return _Tab.highlights;
    // Open where there is something to see.
    final hasHighlights = widget.notes.any((note) => note.isHighlight);
    return hasHighlights || widget.notes.isEmpty
        ? _Tab.highlights
        : _Tab.bookmarks;
  }

  List<ReaderNote> get _highlights => [
    ..._notes.where((note) => note.isHighlight),
  ];

  List<ReaderNote> get _bookmarks => [
    ..._notes.where((note) => !note.isHighlight),
  ];

  Future<void> _delete(ReaderNote note) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          note.isHighlight
              ? l10n.readerNotesDeleteHighlightTitle
              : l10n.readerNotesDeleteBookmarkTitle,
        ),
        content: Text(
          note.highlight?.note != null
              ? l10n.readerNotesDeleteWithNoteBody
              : l10n.readerNotesDeleteBody,
        ),
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
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.onDeleted(note);
      if (mounted) setState(() => _notes.removeWhere((n) => n.id == note.id));
    } finally {}
  }

  Future<void> _edit(ReaderNote note) async {
    try {
      final updated = await widget.onEdited(note.highlight!);
      if (updated == null || !mounted) return;
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        setState(() => _notes[index] = ReaderNote.highlight(updated));
      }
    } finally {}
  }

  Future<void> _export() => widget.onExport(
    [for (final note in _notes) ?note.highlight],
    [for (final note in _notes) ?note.bookmark],
  );

  Future<void> _share(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    return widget.onShare(
      [for (final note in _notes) ?note.highlight],
      [for (final note in _notes) ?note.bookmark],
      box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final highlightsCount = _highlights.length;
    final bookmarksCount = _bookmarks.length;
    final empty = _notes.isEmpty;

    // Transparent: the sheet paints the surface; this hosts ink and tiles.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: SizedBox(
          // A fixed height so switching tabs does not resize the sheet.
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontFamily: 'Newsreader',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          Text(
                            '$highlightsCount '
                            '${highlightsCount == 1 ? 'highlight' : 'highlights'}'
                            ' · $bookmarksCount '
                            '${bookmarksCount == 1 ? 'bookmark' : 'bookmarks'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: WarmEditorialTokens.subtitleSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('export_markdown_button'),
                      icon: const Icon(Icons.content_copy_rounded, size: 20),
                      color: WarmEditorialTokens.subtitleSecondary,
                      tooltip: 'Copy as Markdown',
                      onPressed: empty ? null : _export,
                    ),
                    Builder(
                      builder: (buttonContext) => IconButton(
                        key: const Key('share_markdown_button'),
                        icon: const Icon(Icons.ios_share_rounded, size: 20),
                        color: WarmEditorialTokens.subtitleSecondary,
                        tooltip: 'Share',
                        onPressed: empty ? null : () => _share(buttonContext),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: WarmEditorialTokens.hairlineDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        title: 'Highlights',
                        count: highlightsCount,
                        active: _activeTab == _Tab.highlights,
                        accent: accent,
                        onTap: () =>
                            setState(() => _activeTab = _Tab.highlights),
                      ),
                      _buildTabButton(
                        title: 'Bookmarks',
                        count: bookmarksCount,
                        active: _activeTab == _Tab.bookmarks,
                        accent: accent,
                        onTap: () =>
                            setState(() => _activeTab = _Tab.bookmarks),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: switch (_activeTab) {
                  _Tab.highlights => _buildHighlightsTab(),
                  _Tab.bookmarks => _buildBookmarksTab(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool active,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(19),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? WarmEditorialTokens.textPrimaryInk
                          : WarmEditorialTokens.subtitleSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? accent
                        : WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksTab() {
    final bookmarks = _bookmarks;
    if (bookmarks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_outline,
                size: 40,
                color: WarmEditorialTokens.subtitleSecondary,
              ),
              SizedBox(height: 12),
              Text(
                'No bookmarks yet',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tap the bookmark icon while reading to save your spot.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
      itemBuilder: (context, index) {
        final note = bookmarks[index];
        final bm = note.bookmark!;
        final meta = [
          ?locatorLabel(context, note.locator),
          DateFormat.MMMd().format(note.createdAt),
        ].join(' · ');

        return ListTile(
          onTap: () {
            widget.onSelected(note);
          },
          leading: Icon(
            Icons.bookmark_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            bm.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            meta,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
            onPressed: () => _delete(note),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsTab() {
    final highlights = _highlights;
    if (highlights.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.brush_outlined,
                size: 40,
                color: WarmEditorialTokens.subtitleSecondary,
              ),
              SizedBox(height: 12),
              Text(
                'No highlights yet',
                style: TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Select text in any chapter to highlight passages and add notes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: highlights.length,
      itemBuilder: (context, index) {
        final note = highlights[index];
        final hl = note.highlight!;
        final meta = [
          ?locatorLabel(context, note.locator),
          DateFormat.MMMd().format(note.createdAt),
        ].join(' · ');

        final stripColor = switch (hl.color) {
          HighlightColor.yellow => WarmEditorialTokens.highlightYellow,
          HighlightColor.green => WarmEditorialTokens.highlightGreen,
          HighlightColor.blue => WarmEditorialTokens.highlightBlue,
          HighlightColor.pink => WarmEditorialTokens.highlightPink,
          HighlightColor.orange => WarmEditorialTokens.highlightOrange,
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              widget.onSelected(note);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WarmEditorialTokens.hairlineDivider),
              ),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“${hl.selectedText}”',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                        if (hl.note != null && hl.note!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: WarmEditorialTokens.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_note,
                                  size: 16,
                                  color: WarmEditorialTokens.subtitleSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    hl.note!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: WarmEditorialTokens.textPrimaryInk,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              meta,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color:
                                        WarmEditorialTokens.subtitleSecondary,
                                  ),
                                  onPressed: () => _edit(note),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color:
                                        WarmEditorialTokens.subtitleSecondary,
                                  ),
                                  onPressed: () => _delete(note),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Where a note sits: a percent for EPUB, a page for paged formats.
String? locatorLabel(BuildContext context, DocumentLocator locator) {
  final l10n = context.l10n;
  switch (locator) {
    case PdfLocator(:final page):
      return l10n.readerBookmarkPage(page);
    case TextLocator(:final offset):
      return l10n.readerBookmarkPage(offset ~/ 2400 + 1);
    case EpubLocator(:final locatorJson?):
      try {
        final json = jsonDecode(locatorJson) as Map<String, dynamic>;
        final locations = json['locations'] as Map<String, dynamic>?;
        final progression = locations?['totalProgression'] as num?;
        if (progression == null) return null;
        return l10n.libraryProgressPercent((progression * 100).round());
      } on FormatException {
        return null;
      }
    case EpubLocator():
      return null;
  }
}
