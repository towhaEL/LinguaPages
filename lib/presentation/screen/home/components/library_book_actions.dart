import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

enum _BookAction {
  favorite,
  shelf,
  collections,
  details,
  trash,
  restore,
  deleteForever,
}

/// The long-press sheet for a book; books in Trash get Restore and Delete.
Future<void> showBookActions(BuildContext context, BookEntity book) async {
  final l10n = context.l10n;
  Widget tile(
    IconData icon,
    String label,
    _BookAction action,
    BuildContext c,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    leading: Icon(icon),
    title: Text(label),
    onTap: () => Navigator.of(c).pop(action),
  );
  final action = await showModalBottomSheet<_BookAction>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetTitle(book.title),
            if (book.isInTrash) ...[
              tile(
                Icons.restore_from_trash_outlined,
                l10n.libraryRestore,
                _BookAction.restore,
                sheetContext,
              ),
              tile(
                Icons.delete_forever_outlined,
                l10n.libraryDeleteForever,
                _BookAction.deleteForever,
                sheetContext,
              ),
            ] else ...[
              tile(
                book.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                book.isFavorite ? l10n.libraryUnfavorite : l10n.libraryFavorite,
                _BookAction.favorite,
                sheetContext,
              ),
              tile(
                Icons.bookmarks_outlined,
                l10n.libraryMoveToShelf,
                _BookAction.shelf,
                sheetContext,
              ),
              tile(
                Icons.collections_bookmark_outlined,
                l10n.libraryCollections,
                _BookAction.collections,
                sheetContext,
              ),
              tile(
                Icons.edit_outlined,
                l10n.libraryEditDetails,
                _BookAction.details,
                sheetContext,
              ),
              tile(
                Icons.delete_outline_rounded,
                l10n.libraryMoveToTrash,
                _BookAction.trash,
                sheetContext,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  final cubit = context.read<LibraryCubit>();
  switch (action) {
    case _BookAction.favorite:
      final favorited = await cubit.toggleFavorite(book);
      if (context.mounted) _report(context, favorited);
    case _BookAction.shelf:
      await _pickShelf(context, book);
    case _BookAction.collections:
      await _pickCollections(context, book);
    case _BookAction.details:
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: _BookDetailsSheet(book: book),
        ),
      );
    case _BookAction.trash:
      final moved = await cubit.moveToTrash(book);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Optional actions; the message still times out.
          persist: false,
          content: Text(
            moved
                ? l10n.libraryMovedToTrash(book.title)
                : l10n.libraryActionFailed,
          ),
          action: moved
              ? SnackBarAction(
                  label: l10n.libraryUndo,
                  onPressed: () => cubit.restoreFromTrash(book),
                )
              : null,
        ),
      );
    case _BookAction.restore:
      final restored = await cubit.restoreFromTrash(book);
      if (context.mounted) _report(context, restored);
    case _BookAction.deleteForever:
      await _deleteForever(context, book);
  }
}

/// Shows a snackbar only when the change failed; success is visible.
void _report(BuildContext context, bool succeeded) {
  if (succeeded) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.libraryActionFailed)));
}

Future<void> _pickShelf(BuildContext context, BookEntity book) async {
  final l10n = context.l10n;
  // null is "Automatic": follow progress.
  final options = <(BookShelf?, String)>[
    (null, l10n.libraryShelfAutomatic),
    (BookShelf.toRead, l10n.libraryShelfToRead),
    (BookShelf.reading, l10n.libraryShelfReading),
    (BookShelf.finished, l10n.libraryShelfFinished),
  ];
  final picked = await showDialog<(BookShelf?,)>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(l10n.libraryMoveToShelf),
      children: [
        for (final (shelf, label) in options)
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop((shelf,)),
            child: Row(
              children: [
                Expanded(child: Text(label)),
                if (book.shelf == shelf) const Icon(Icons.check_rounded),
              ],
            ),
          ),
      ],
    ),
  );
  if (picked == null || !context.mounted) return;
  final saved = await context.read<LibraryCubit>().setShelf(book, picked.$1);
  if (context.mounted) _report(context, saved);
}

Future<void> _pickCollections(BuildContext context, BookEntity book) async {
  final cubit = context.read<LibraryCubit>();
  final chosen = await showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _CollectionsSheet(book: book),
    ),
  );
  if (chosen == null || !context.mounted) return;
  final saved = await cubit.setCollections(book, chosen);
  if (context.mounted) _report(context, saved);
}

Future<void> _deleteForever(BuildContext context, BookEntity book) async {
  final l10n = context.l10n;
  final data = await showDialog<DeleteBookData>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.libraryDeleteTitle),
      content: Text(l10n.libraryDeleteBody(book.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(DeleteBookData.keep),
          child: Text(l10n.libraryDeleteKeepData),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: () =>
              Navigator.of(dialogContext).pop(DeleteBookData.delete),
          child: Text(l10n.libraryDeleteAllData),
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
            ? l10n.libraryDeletedMessage(book.title)
            : l10n.libraryDeleteFailed,
      ),
    ),
  );
}

/// Asks for a collection name; [initial] prefills a rename.
Future<String?> showCollectionNameDialog(
  BuildContext context, {
  String? initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({this.initial});

  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? l10n.libraryNewCollection
            : l10n.libraryRenameCollection,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          fillColor: context.colors.surfaceElevated,
          labelText: l10n.libraryCollectionName,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

class _CollectionsSheet extends StatefulWidget {
  const _CollectionsSheet({required this.book});

  final BookEntity book;

  @override
  State<_CollectionsSheet> createState() => _CollectionsSheetState();
}

class _CollectionsSheetState extends State<_CollectionsSheet> {
  late final Set<String> _chosen = {
    for (final collection in context.read<LibraryCubit>().state.collections)
      if (collection.bookIds.contains(widget.book.id)) collection.id,
  };

  Future<void> _create() async {
    final name = await showCollectionNameDialog(context);
    if (name == null || !mounted) return;
    final collection = await context.read<LibraryCubit>().createCollection(
      name,
    );
    if (collection != null && mounted) {
      setState(() => _chosen.add(collection.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final collections = context.select(
      (LibraryCubit cubit) => cubit.state.collections,
    );
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitle(l10n.libraryCollections),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final collection in collections)
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    value: _chosen.contains(collection.id),
                    title: Text(collection.name),
                    onChanged: (value) => setState(
                      () => value ?? false
                          ? _chosen.add(collection.id)
                          : _chosen.remove(collection.id),
                    ),
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.add_rounded),
                  title: Text(l10n.libraryNewCollection),
                  onTap: _create,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_chosen),
              child: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookDetailsSheet extends StatefulWidget {
  const _BookDetailsSheet({required this.book});

  final BookEntity book;

  @override
  State<_BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends State<_BookDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.book.title);
  late final _author = TextEditingController(text: widget.book.author);
  late final _series = TextEditingController(text: widget.book.series);
  late final _number = TextEditingController(
    text: _formatNumber(widget.book.seriesIndex),
  );
  late final _language = TextEditingController(text: widget.book.languageCode);
  var _busy = false;

  static String _formatNumber(double? value) => value == null
      ? ''
      : value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void dispose() {
    for (final controller in [_title, _author, _series, _number, _language]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final saved = await context.read<LibraryCubit>().updateDetails(
      widget.book,
      BookDetails(
        title: _title.text,
        author: _author.text,
        series: _series.text,
        seriesIndex: double.tryParse(_number.text.trim()),
        languageCode: _language.text,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved) {
      Navigator.of(context).pop();
    } else {
      _report(context, false);
    }
  }

  Future<void> _reset() async {
    setState(() => _busy = true);
    final details = await context.read<LibraryCubit>().resetDetails(
      widget.book,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (details != null) {
        _title.text = details.title;
        _author.text = details.author ?? '';
        _series.text = details.series ?? '';
        _number.text = _formatNumber(details.seriesIndex);
        _language.text = details.languageCode ?? '';
      }
    });
    if (details == null) _report(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget field(
      TextEditingController controller,
      String label, {
      String? hint,
      TextInputType? keyboard,
      String? Function(String?)? validator,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          // One tonal step above the sheet so the field has an edge.
          fillColor: context.colors.surfaceElevated,
          labelText: label,
          helperText: hint,
        ),
        validator: validator,
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.libraryEditDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                field(
                  _title,
                  l10n.libraryDetailTitle,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.libraryDetailTitleRequired
                      : null,
                ),
                field(
                  _author,
                  l10n.libraryDetailAuthors,
                  hint: l10n.libraryDetailAuthorsHint,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: field(_series, l10n.libraryDetailSeries),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: field(
                        _number,
                        l10n.libraryDetailSeriesNumber,
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            value == null ||
                                value.trim().isEmpty ||
                                double.tryParse(value.trim()) != null
                            ? null
                            : l10n.libraryDetailNumberInvalid,
                      ),
                    ),
                  ],
                ),
                field(
                  _language,
                  l10n.libraryDetailLanguage,
                  hint: l10n.libraryDetailLanguageHint,
                ),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : _reset,
                  child: Text(l10n.libraryDetailReset),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
