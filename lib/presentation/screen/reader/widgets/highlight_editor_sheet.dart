import 'package:flutter/material.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// The colour and note the reader chose for a highlight.
typedef HighlightChoice = ({HighlightColor color, String? note});

/// Opens the highlight sheet for [quote].
///
/// New highlights save on the first colour tap, with the note if one was
/// typed. Editing an existing highlight ([initial] set) picks a colour and
/// saves with an explicit button, so a mistaken tap changes nothing.
/// Swatches show the tint the current page will draw ([darkPage]).
Future<HighlightChoice?> showHighlightEditor(
  BuildContext context, {
  required String quote,
  required bool darkPage,
  HighlightChoice? initial,
}) => showModalBottomSheet<HighlightChoice>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) =>
      _HighlightEditorSheet(quote: quote, darkPage: darkPage, initial: initial),
);

class _HighlightEditorSheet extends StatefulWidget {
  const _HighlightEditorSheet({
    required this.quote,
    required this.darkPage,
    this.initial,
  });

  final String quote;
  final bool darkPage;
  final HighlightChoice? initial;

  @override
  State<_HighlightEditorSheet> createState() => _HighlightEditorSheetState();
}

class _HighlightEditorSheetState extends State<_HighlightEditorSheet> {
  late final _note = TextEditingController(text: widget.initial?.note ?? '');
  late HighlightColor _color = widget.initial?.color ?? HighlightColor.yellow;

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _finish(HighlightColor color) {
    final note = _note.text.trim();
    Navigator.of(context).pop((color: color, note: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;

    return Padding(
      // Keeps the note field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  _editing ? l10n.readerEditHighlight : l10n.readerHighlight,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.quote,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  // One tonal step above the sheet so the field has an edge.
                  fillColor: colors.surfaceElevated,
                  hintText: l10n.readerNoteHint,
                ),
              ),
              const SizedBox(height: 20),
              if (!_editing) ...[
                Text(
                  l10n.readerHighlightChooseColor,
                  style: text.titleSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final color in HighlightColor.values)
                    _Swatch(
                      color: color,
                      darkPage: widget.darkPage,
                      selected: _editing && _color == color,
                      label: highlightColorLabel(context, color),
                      onTap: _editing
                          ? () => setState(() => _color = color)
                          : () => _finish(color),
                    ),
                ],
              ),
              if (_editing) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _finish(_color),
                  child: Text(l10n.save),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.darkPage,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final HighlightColor color;
  final bool darkPage;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(color.tintArgb(darkPage: darkPage)),
                  shape: BoxShape.circle,
                  // Selection is the orange ring; otherwise a rule gives the
                  // deep tints an edge on the card.
                  border: Border.all(
                    color: selected ? colors.primary : colors.border,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.onSurface : colors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String highlightColorLabel(BuildContext context, HighlightColor color) =>
    switch (color) {
      HighlightColor.yellow => context.l10n.readerHighlightYellow,
      HighlightColor.green => context.l10n.readerHighlightGreen,
      HighlightColor.blue => context.l10n.readerHighlightBlue,
      HighlightColor.pink => context.l10n.readerHighlightPink,
    };
