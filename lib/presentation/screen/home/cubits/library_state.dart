import 'package:lingua_pages/domain/entity/library/book_entity.dart';

enum LibraryStatus { initial, loading, success, failure }

enum LibraryImportFeedback {
  imported,
  duplicate,
  unsupportedFormat,
  corruptDocument,
  unavailable,
  failure,
}

enum LibraryViewMode { grid, list }

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
    );
  }
}
