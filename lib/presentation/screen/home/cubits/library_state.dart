import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/library/collection_entity.dart';
import 'package:lingua_pages/domain/use_cases/library/import_folder_use_case.dart';

enum LibraryStatus { initial, loading, success, failure }

enum LibraryImportFeedback {
  imported,
  duplicate,
  unsupportedFormat,
  corruptDocument,
  drmProtected,
  unavailable,
  failure,
}

enum LibraryViewMode { grid, list }

/// Which part of the library the shelf shows.
enum LibraryView {
  all,
  toRead,
  reading,
  finished,
  favorites,
  collection,
  authors,
  series,
  trash,
}

class LibraryState {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.books = const [],
    this.query = '',
    this.errorMessage,
    this.isImporting = false,
    this.importFeedback,
    this.importMessage,
    this.viewMode = LibraryViewMode.grid,
    this.sort = LibrarySort.recent,
    this.view = LibraryView.all,
    this.viewKey,
    this.collections = const [],
    this.trash = const [],
    this.duplicateBookId,
    this.folderResult,
  });

  final LibraryStatus status;
  final List<BookEntity> books;
  final String query;
  final String? errorMessage;
  final bool isImporting;
  final LibraryImportFeedback? importFeedback;
  final String? importMessage;
  final LibraryViewMode viewMode;
  final LibrarySort sort;
  final LibraryView view;

  /// The collection id, author or series picked within [view]; null lists
  /// the authors or series to pick from.
  final String? viewKey;
  final List<CollectionEntity> collections;
  final List<BookEntity> trash;

  /// The library book matching a rejected duplicate import.
  final String? duplicateBookId;

  /// The outcome of a folder import, for one emission.
  final FolderImportResult? folderResult;

  CollectionEntity? get selectedCollection => view == LibraryView.collection
      ? collections.where((c) => c.id == viewKey).firstOrNull
      : null;

  /// [books] narrowed to [view]. Authors and series without a pick show
  /// their groups instead (see [authorGroups] and [seriesGroups]).
  List<BookEntity> get visibleBooks {
    final key = viewKey;
    return switch (view) {
      LibraryView.all => books,
      LibraryView.toRead => _onShelf(BookShelf.toRead),
      LibraryView.reading => _onShelf(BookShelf.reading),
      LibraryView.finished => _onShelf(BookShelf.finished),
      LibraryView.favorites => [
        for (final book in books)
          if (book.isFavorite) book,
      ],
      LibraryView.collection => [
        for (final book in books)
          if (selectedCollection?.bookIds.contains(book.id) ?? false) book,
      ],
      LibraryView.authors => [
        for (final book in books)
          if (key != null && book.authors.contains(key)) book,
      ],
      LibraryView.series => [
        for (final book in books)
          if (key != null && book.series == key) book,
      ]..sort((a, b) => (a.seriesIndex ?? 1e9).compareTo(b.seriesIndex ?? 1e9)),
      LibraryView.trash => trash,
    };
  }

  /// Author names with their book counts, alphabetically.
  List<(String, int)> get authorGroups =>
      _groups([for (final book in books) ...book.authors]);

  /// Series names with their book counts, alphabetically.
  List<(String, int)> get seriesGroups =>
      _groups([for (final book in books) ?book.series]);

  /// Authors or series are listed rather than books.
  bool get showsGroups =>
      viewKey == null &&
      (view == LibraryView.authors || view == LibraryView.series);

  List<BookEntity> _onShelf(BookShelf shelf) => [
    for (final book in books)
      if (book.readingShelf == shelf) book,
  ];

  static List<(String, int)> _groups(List<String> names) {
    final counts = <String, int>{};
    for (final name in names) {
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts.entries.map((entry) => (entry.key, entry.value)).toList()
      ..sort((a, b) => a.$1.toLowerCase().compareTo(b.$1.toLowerCase()));
  }

  LibraryState copyWith({
    LibraryStatus? status,
    List<BookEntity>? books,
    String? query,
    String? errorMessage,
    bool? isImporting,
    LibraryImportFeedback? importFeedback,
    String? importMessage,
    LibraryViewMode? viewMode,
    LibrarySort? sort,
    LibraryView? view,
    String? Function()? viewKey,
    List<CollectionEntity>? collections,
    List<BookEntity>? trash,
    String? duplicateBookId,
    FolderImportResult? folderResult,
  }) {
    return LibraryState(
      status: status ?? this.status,
      books: books ?? this.books,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
      isImporting: isImporting ?? this.isImporting,
      importFeedback: importFeedback,
      importMessage: importMessage,
      viewMode: viewMode ?? this.viewMode,
      sort: sort ?? this.sort,
      view: view ?? this.view,
      viewKey: viewKey == null ? this.viewKey : viewKey(),
      collections: collections ?? this.collections,
      trash: trash ?? this.trash,
      // Like the import feedback, it only lasts one emission.
      duplicateBookId: duplicateBookId,
      folderResult: folderResult,
    );
  }
}
