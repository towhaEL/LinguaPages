import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';
import 'package:lingua_pages/l10n/l10n.dart';

@RoutePage()
class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) => const _VocabularyView();
}

class _VocabularyView extends StatefulWidget {
  const _VocabularyView();

  @override
  State<_VocabularyView> createState() => _VocabularyViewState();
}

class _VocabularyViewState extends State<_VocabularyView> {
  late final VocabularyRepository _vocabularyRepository =
      injector<VocabularyRepository>();
  late final LibraryRepository _libraryRepository =
      injector<LibraryRepository>();
  late final ReviewRepository _reviewRepository = injector<ReviewRepository>();
  late final TextEditingController _searchController = TextEditingController(
    text: '',
  );

  List<VocabItemEntity> _items = const [];
  List<BookEntity> _books = const [];
  Map<String, ReviewCardEntity> _cardsByVocabularyId = const {};
  String _bookFilterId = '';
  String _languageFilter = '';
  _VocabularyStatusFilter _statusFilter = _VocabularyStatusFilter.all;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final query = _searchController.text.trim();
      final results = await Future.wait<Object>([
        query.isEmpty
            ? _vocabularyRepository.getAll()
            : _vocabularyRepository.search(query),
        _libraryRepository.getAll(),
        _reviewRepository.getAllCards(),
      ]);
      final allItems = results[0] as List<VocabItemEntity>;
      final books = results[1] as List<BookEntity>;
      final cards = results[2] as List<ReviewCardEntity>;
      if (!mounted) return;
      setState(() {
        _books = books;
        _cardsByVocabularyId = {
          for (final card in cards) card.vocabItemId: card,
        };
        _items = _filterItems(allItems);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _isLoading = false;
        _errorMessage = context.l10n.vocabularyLoadFailed;
      });
    }
  }

  List<VocabItemEntity> _filterItems(List<VocabItemEntity> items) {
    final now = DateTime.now();
    return items.where((item) {
      if (_bookFilterId.isNotEmpty && item.bookId != _bookFilterId) {
        return false;
      }
      if (_languageFilter.isNotEmpty &&
          item.sourceLanguage != _languageFilter) {
        return false;
      }
      final card = _cardsByVocabularyId[item.id];
      return switch (_statusFilter) {
        _VocabularyStatusFilter.all => true,
        _VocabularyStatusFilter.newCard =>
          card == null || card.state == ReviewCardState.newCard,
        _VocabularyStatusFilter.due => card?.isDue(now) ?? false,
        _VocabularyStatusFilter.learned => card != null && card.repetitions > 0,
      };
    }).toList();
  }

  Future<void> _delete(VocabItemEntity item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.vocabularyDeleteTitle),
        content: Text(item.word),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _vocabularyRepository.delete(item.id);
      await _reviewRepository.deleteForVocabItem(item.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.vocabularyDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.vocabularyTitle),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: context.l10n.vocabularySearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
              ),
            ),
          ),
          _buildFilters(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _FilterDropdown<String>(
            label: context.l10n.vocabularyFilterBook,
            value: _bookFilterId,
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(context.l10n.vocabularyFilterAllBooks),
              ),
              ..._books.map(
                (book) => DropdownMenuItem(
                  value: book.id,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(book.title, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _bookFilterId = value ?? '');
              _load();
            },
          ),
          const SizedBox(width: 8),
          _FilterDropdown<String>(
            label: context.l10n.vocabularyFilterLanguage,
            value: _languageFilter,
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(context.l10n.vocabularyFilterAllLanguages),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(context.l10n.languageEnglish),
              ),
              DropdownMenuItem(
                value: 'es',
                child: Text(context.l10n.languageSpanish),
              ),
            ],
            onChanged: (value) {
              setState(() => _languageFilter = value ?? '');
              _load();
            },
          ),
          const SizedBox(width: 8),
          _FilterDropdown<_VocabularyStatusFilter>(
            label: context.l10n.vocabularyFilterStatus,
            value: _statusFilter,
            items: [
              DropdownMenuItem(
                value: _VocabularyStatusFilter.all,
                child: Text(context.l10n.vocabularyFilterAllStatuses),
              ),
              DropdownMenuItem(
                value: _VocabularyStatusFilter.newCard,
                child: Text(context.l10n.vocabularyFilterNew),
              ),
              DropdownMenuItem(
                value: _VocabularyStatusFilter.due,
                child: Text(context.l10n.vocabularyFilterDue),
              ),
              DropdownMenuItem(
                value: _VocabularyStatusFilter.learned,
                child: Text(context.l10n.vocabularyFilterLearned),
              ),
            ],
            onChanged: (value) {
              setState(
                () => _statusFilter = value ?? _VocabularyStatusFilter.all,
              );
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final error = _errorMessage;
    if (error != null) return Center(child: Text(error));
    if (_items.isEmpty) {
      return Center(child: Text(context.l10n.vocabularyEmpty));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: ListTile(
            title: Text(
              item.word,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                [
                  item.translation,
                  if (item.sourceSentence.isNotEmpty) item.sourceSentence,
                ].join('\n'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            isThreeLine: item.sourceSentence.isNotEmpty,
            trailing: IconButton(
              onPressed: () => _delete(item),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: context.l10n.delete,
            ),
          ),
        );
      },
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

enum _VocabularyStatusFilter { all, newCard, due, learned }
