import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
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

enum _Filter { all, highlights, bookmarks }

/// Every highlight and bookmark in the book, newest first.
class NotesSheet extends StatefulWidget {
  const NotesSheet({
    required this.notes,
    required this.onSelected,
    required this.onDeleted,
    required this.onEdited,
    required this.onExport,
    required this.onShare,
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

  @override
  State<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<NotesSheet> {
  late final List<ReaderNote> _notes = [...widget.notes]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  var _filter = _Filter.all;
  String? _busyId;

  List<ReaderNote> get _visible => switch (_filter) {
    _Filter.all => _notes,
    _Filter.highlights => [..._notes.where((note) => note.isHighlight)],
    _Filter.bookmarks => [..._notes.where((note) => !note.isHighlight)],
  };

  Future<void> _delete(ReaderNote note) async {
    final l10n = context.l10n;
    // Annotations are durable work, so deleting one asks first.
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
    setState(() => _busyId = note.id);
    try {
      await widget.onDeleted(note);
      if (mounted) setState(() => _notes.removeWhere((n) => n.id == note.id));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _edit(ReaderNote note) async {
    setState(() => _busyId = note.id);
    try {
      final updated = await widget.onEdited(note.highlight!);
      if (updated == null || !mounted) return;
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        setState(() => _notes[index] = ReaderNote.highlight(updated));
      }
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
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
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final highlights = _notes.where((note) => note.isHighlight).length;
    final visible = _visible;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.readerToolNotes,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (_notes.isNotEmpty)
                    TextButton.icon(
                      onPressed: _export,
                      icon: const Icon(Icons.copy_all_outlined),
                      label: Text(l10n.readerNotesCopyMarkdown),
                    ),
                  if (_notes.isNotEmpty)
                    Builder(
                      builder: (buttonContext) => IconButton(
                        onPressed: () => _share(buttonContext),
                        tooltip: l10n.readerNotesShareMarkdown,
                        icon: const Icon(Icons.ios_share_outlined),
                      ),
                    ),
                ],
              ),
            ),
            if (_notes.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Row(
                  children: [
                    for (final (filter, label) in [
                      (_Filter.all, l10n.readerNotesAll(_notes.length)),
                      (
                        _Filter.highlights,
                        l10n.readerNotesHighlights(highlights),
                      ),
                      (
                        _Filter.bookmarks,
                        l10n.readerNotesBookmarks(_notes.length - highlights),
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: _notes.isEmpty
                  ? _Empty(
                      title: l10n.readerNotesEmptyTitle,
                      body: l10n.readerNotesEmptyBody,
                    )
                  : visible.isEmpty
                  ? _Empty(title: l10n.readerNotesFilterEmpty)
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) =>
                          const Divider(indent: 24, endIndent: 24),
                      itemBuilder: (context, index) {
                        final note = visible[index];
                        return _NoteRow(
                          note: note,
                          busy: _busyId == note.id,
                          onTap: () => widget.onSelected(note),
                          onEdit: note.isHighlight ? () => _edit(note) : null,
                          onDelete: () => _delete(note),
                        );
                      },
                    ),
            ),
            if (_notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(
                  l10n.readerNotesExportHint,
                  style: text.bodySmall?.copyWith(color: colors.onSurfaceMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.busy,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  final ReaderNote note;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final highlight = note.highlight;
    final meta = [
      ?locatorLabel(context, note.locator),
      DateFormat.MMMd().format(note.createdAt),
    ].join(' · ');

    return InkWell(
      onTap: busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (highlight != null)
                    // The quote wears its highlight, in the deep tint that
                    // keeps paper text readable on the dark sheet.
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
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              PopupMenuButton<VoidCallback>(
                tooltip: l10n.readerNotesActions,
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: onEdit,
                      child: Text(l10n.readerNotesEdit),
                    ),
                  PopupMenuItem(value: onDelete, child: Text(l10n.delete)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 40,
              color: colors.onSurfaceMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
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
