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

enum _Tab { contents, bookmarks, highlights }

/// Side sheet drawer with 3 tabs (Contents, Bookmarks, Highlights) matching Stitch screen 04d_contents_annotations (60c9068e).
class NotesSheet extends StatefulWidget {
  const NotesSheet({
    required this.notes,
    required this.onSelected,
    required this.onDeleted,
    required this.onEdited,
    required this.onExport,
    required this.onShare,
    this.tableOfContents = const [],
    this.onChapterSelected,
    this.activeChapterIndex = 0,
    this.bookTitle,
    this.bookAuthor,
    this.readingProgressLabel = 'Chapter 4 · Page 142 of 380',
    this.readingProgressPercent = '37%',
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
  ) onExport;

  /// Shares what the sheet shows; [origin] anchors the iPad share popover.
  final Future<void> Function(
    List<HighlightEntity> highlights,
    List<BookmarkEntity> bookmarks,
    Rect? origin,
  ) onShare;

  final List<String> tableOfContents;
  final ValueChanged<int>? onChapterSelected;
  final int activeChapterIndex;
  final String? bookTitle;
  final String? bookAuthor;
  final String readingProgressLabel;
  final String readingProgressPercent;
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
    if (widget.tableOfContents.isNotEmpty) return _Tab.contents;
    return _Tab.highlights;
  }

  List<ReaderNote> get _highlights =>
      [..._notes.where((note) => note.isHighlight)];

  List<ReaderNote> get _bookmarks =>
      [..._notes.where((note) => !note.isHighlight)];

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
    final tocCount = widget.tableOfContents.length;
    final bookmarksCount = _bookmarks.length;
    final highlightsCount = _highlights.length;

    return Material(
      color: const Color(0xFFFCF9F4),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action Header & Book Metadata
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: WarmEditorialTokens.subtitleSecondary),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search, color: WarmEditorialTokens.subtitleSecondary),
                              onPressed: () {},
                            ),
                            IconButton(
                              key: const Key('export_markdown_button'),
                              icon: const Icon(Icons.file_download_outlined, color: WarmEditorialTokens.subtitleSecondary),
                              tooltip: 'Export as Markdown',
                              onPressed: _export,
                            ),
                            Builder(
                              builder: (buttonContext) => IconButton(
                                key: const Key('share_markdown_button'),
                                icon: const Icon(Icons.ios_share_outlined, color: WarmEditorialTokens.subtitleSecondary),
                                tooltip: 'Share',
                                onPressed: () => _share(buttonContext),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Book Title & Author
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bookTitle ?? 'The Shadow of the Wind',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Newsreader',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          if (widget.bookAuthor != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.bookAuthor!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3-Tab Segmented Pill Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE8E3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            title: 'Contents',
                            count: tocCount > 0 ? tocCount : 18,
                            active: _activeTab == _Tab.contents,
                            onTap: () => setState(() => _activeTab = _Tab.contents),
                          ),
                          _buildTabButton(
                            title: 'Bookmarks',
                            count: bookmarksCount,
                            active: _activeTab == _Tab.bookmarks,
                            onTap: () => setState(() => _activeTab = _Tab.bookmarks),
                          ),
                          _buildTabButton(
                            title: 'Highlights',
                            count: highlightsCount,
                            active: _activeTab == _Tab.highlights,
                            onTap: () => setState(() => _activeTab = _Tab.highlights),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),

              // Tab Body Content
              Expanded(
                child: switch (_activeTab) {
                  _Tab.contents => _buildContentsTab(),
                  _Tab.bookmarks => _buildBookmarksTab(),
                  _Tab.highlights => _buildHighlightsTab(),
                },
              ),

              // Drawer Sticky Footer
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: WarmEditorialTokens.hairlineDivider)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _export,
                        icon: const Icon(Icons.download, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                        label: const Text(
                          'Export as Markdown (.md)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Local Offline Vault',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: WarmEditorialTokens.subtitleSecondary),
                        ),
                        Text(
                          '24.8 KB',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: WarmEditorialTokens.subtitleSecondary),
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
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? WarmEditorialTokens.accentInkBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
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
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? Colors.white : WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? Colors.white24 : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentsTab() {
    final toc = widget.tableOfContents.isNotEmpty
        ? widget.tableOfContents
        : [
            'Front Matter: Title Page',
            'Chapter 1: The Cemetery of Forgotten Books',
            'Chapter 2: The Bookshop on Santa Ana',
            'Chapter 3: Barceloneta Bells',
            'Chapter Four: The Silent Harbour',
            'Chapter 5: The City of Shadows',
          ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Reading Progress Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: WarmEditorialTokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WarmEditorialTokens.hairlineDivider),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories, size: 16, color: WarmEditorialTokens.accentInkBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.readingProgressLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                    Text(
                      '${widget.readingProgressPercent} completed',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: WarmEditorialTokens.spokenHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.readingProgressPercent,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WarmEditorialTokens.accentInkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // TOC List
        for (final (index, chapter) in toc.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                widget.onChapterSelected?.call(index);
                Navigator.of(context).maybePop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: index == widget.activeChapterIndex
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: index == widget.activeChapterIndex
                      ? Border.all(color: WarmEditorialTokens.hairlineDivider)
                      : null,
                ),
                child: Row(
                  children: [
                    if (index == widget.activeChapterIndex) ...[
                      Container(
                        width: 3.5,
                        height: 28,
                        decoration: BoxDecoration(
                          color: WarmEditorialTokens.accentInkBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: WarmEditorialTokens.accentInkBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chapter,
                                  style: TextStyle(
                                    fontFamily: 'Newsreader',
                                    fontSize: 14,
                                    fontWeight: index == widget.activeChapterIndex
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontStyle: index == widget.activeChapterIndex
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    color: index == widget.activeChapterIndex
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.textPrimaryInk,
                                  ),
                                ),
                              ),
                              if (index == widget.activeChapterIndex)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: WarmEditorialTokens.accentInkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Current',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: WarmEditorialTokens.accentInkBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (index == widget.activeChapterIndex)
                            const Text(
                              'Reading now · Page 142',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: WarmEditorialTokens.subtitleSecondary),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'p. ${index * 36 + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WarmEditorialTokens.subtitleSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
              Icon(Icons.bookmark_outline, size: 40, color: WarmEditorialTokens.subtitleSecondary),
              SizedBox(height: 12),
              Text(
                'No bookmarks yet',
                style: TextStyle(fontFamily: 'Newsreader', fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text(
                'Tap the bookmark icon while reading to save your spot.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WarmEditorialTokens.subtitleSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
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
            Navigator.of(context).maybePop();
          },
          leading: const Icon(Icons.bookmark_rounded, color: WarmEditorialTokens.accentInkBlue),
          title: Text(
            bm.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            meta,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WarmEditorialTokens.subtitleSecondary),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: WarmEditorialTokens.subtitleSecondary),
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
              Icon(Icons.brush_outlined, size: 40, color: WarmEditorialTokens.subtitleSecondary),
              SizedBox(height: 12),
              Text(
                'No highlights yet',
                style: TextStyle(fontFamily: 'Newsreader', fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text(
                'Select text in any chapter to highlight passages and add notes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WarmEditorialTokens.subtitleSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              widget.onSelected(note);
              Navigator.of(context).maybePop();
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
                                const Icon(Icons.edit_note, size: 16, color: WarmEditorialTokens.subtitleSecondary),
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
                                  icon: const Icon(Icons.edit_outlined, size: 16, color: WarmEditorialTokens.subtitleSecondary),
                                  onPressed: () => _edit(note),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: WarmEditorialTokens.subtitleSecondary),
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
