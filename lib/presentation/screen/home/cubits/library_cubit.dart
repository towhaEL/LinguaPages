import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/library/collection_entity.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/repository/library/collection_repository.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/get_library_books_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_folder_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/purge_trash_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/reset_book_details_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/search_library_use_case.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';

@injectable
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(
    this._getLibraryBooksUseCase,
    this._deleteLibraryBookUseCase,
    this._importDocumentUseCase,
    this._searchLibraryUseCase,
    this._incomingDocumentService,
    this._settingsRepository,
    this._libraryRepository,
    this._collectionRepository,
    this._purgeTrashUseCase,
    this._resetBookDetailsUseCase,
    this._importFolderUseCase,
    this._logger,
  ) : super(const LibraryState()) {
    _incomingSubscription = _incomingDocumentService.documents.listen(
      (document) => unawaited(_importIncomingDocument(document)),
    );
    // Writes from elsewhere (a restore, the reader) reach the shelf too.
    _changesSubscription = _libraryRepository.changes.listen((_) {
      _changeDebounce?.cancel();
      _changeDebounce = Timer(const Duration(milliseconds: 300), () {
        if (!isClosed && state.status == LibraryStatus.success) {
          unawaited(_refresh().catchError((Object _) {}));
        }
      });
    });
  }

  final GetLibraryBooksUseCase _getLibraryBooksUseCase;
  final DeleteLibraryBookUseCase _deleteLibraryBookUseCase;
  final ImportDocumentUseCase _importDocumentUseCase;
  final SearchLibraryUseCase _searchLibraryUseCase;
  final IncomingDocumentService _incomingDocumentService;
  final SettingsRepository _settingsRepository;
  final LibraryRepository _libraryRepository;
  final CollectionRepository _collectionRepository;
  final PurgeTrashUseCase _purgeTrashUseCase;
  final ResetBookDetailsUseCase _resetBookDetailsUseCase;
  final ImportFolderUseCase _importFolderUseCase;
  final Logger _logger;
  late final StreamSubscription<IncomingDocument> _incomingSubscription;
  late final StreamSubscription<void> _changesSubscription;
  Timer? _changeDebounce;

  Future<void> load() async {
    final firstLoad = state.status == LibraryStatus.initial;
    final shelf = firstLoad ? await _shelfPreferences() : null;
    if (firstLoad) await _purgeOldTrash();
    emit(
      state.copyWith(
        status: LibraryStatus.loading,
        viewMode: shelf?.$1,
        sort: shelf?.$2,
      ),
    );
    try {
      final books = await _getLibraryBooksUseCase.execute(sort: state.sort);
      final collections = await _collectionRepository.getAll();
      final trash = await _libraryRepository.getTrash();
      emit(
        state.copyWith(
          status: LibraryStatus.success,
          books: books,
          collections: collections,
          trash: trash,
        ),
      );
    } catch (error, stackTrace) {
      _logger.e('Unable to load library', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }

    try {
      final incomingDocument = await _incomingDocumentService
          .takeInitialDocument();
      if (incomingDocument != null) {
        await _importIncomingDocument(incomingDocument);
      }
    } catch (error, stackTrace) {
      _logger.w(
        'Unable to process the document used to launch the app',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(query: query));
    try {
      final books = await _searchLibraryUseCase.execute(
        query,
        sort: state.sort,
      );
      emit(state.copyWith(status: LibraryStatus.success, books: books));
    } catch (error, stackTrace) {
      _logger.e(
        'Unable to search library',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void toggleViewMode() {
    final list = state.viewMode == LibraryViewMode.grid;
    emit(
      state.copyWith(
        viewMode: list ? LibraryViewMode.list : LibraryViewMode.grid,
      ),
    );
    unawaited(_saveShelfPreference('libraryListView', list));
  }

  Future<void> changeSort(LibrarySort sort) async {
    if (sort == state.sort) return;
    emit(state.copyWith(sort: sort, status: LibraryStatus.loading));
    unawaited(_saveShelfPreference('librarySort', sort.name));
    try {
      final books = state.query.trim().isEmpty
          ? await _getLibraryBooksUseCase.execute(sort: sort)
          : await _searchLibraryUseCase.execute(state.query, sort: sort);
      emit(state.copyWith(status: LibraryStatus.success, books: books));
    } catch (error, stackTrace) {
      _logger.e('Unable to sort library', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// The saved view mode and sort, or null to keep the defaults.
  Future<(LibraryViewMode, LibrarySort)?> _shelfPreferences() async {
    try {
      final settings = await _settingsRepository.getSettings();
      return (
        settings.libraryListView ? LibraryViewMode.list : LibraryViewMode.grid,
        settings.librarySort,
      );
    } catch (error) {
      _logger.w('Unable to restore shelf preferences', error: error);
      return null;
    }
  }

  Future<void> _saveShelfPreference(String key, Object value) async {
    try {
      await _settingsRepository.updateSetting(key: key, value: value);
    } catch (error) {
      _logger.w('Unable to save shelf preference', error: error);
    }
  }

  /// Shows [view]; [key] picks a collection, author or series within it.
  void selectView(LibraryView view, {String? key}) {
    emit(state.copyWith(view: view, viewKey: () => key));
  }

  Future<bool> toggleFavorite(BookEntity book) => _change(
    () => _libraryRepository.setFavorite(
      bookId: book.id,
      favorite: !book.isFavorite,
    ),
    'favorite',
  );

  /// Null puts the book back on the shelf its progress implies.
  Future<bool> setShelf(BookEntity book, BookShelf? shelf) => _change(
    () => _libraryRepository.setShelf(bookId: book.id, shelf: shelf),
    'shelf',
  );

  Future<bool> setCollections(BookEntity book, Set<String> collectionIds) =>
      _change(
        () => _collectionRepository.setBookCollections(
          bookId: book.id,
          collectionIds: collectionIds,
        ),
        'collections',
      );

  Future<CollectionEntity?> createCollection(String name) async {
    try {
      final collection = await _collectionRepository.create(name);
      await _refresh();
      return collection;
    } catch (error, stackTrace) {
      _logger.e(
        'Unable to create collection',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> renameCollection(String id, String name) => _change(
    () => _collectionRepository.rename(id: id, name: name),
    'collection name',
  );

  Future<bool> deleteCollection(String id) async {
    final deleted = await _change(
      () => _collectionRepository.delete(id),
      'collection',
    );
    if (deleted && state.viewKey == id) selectView(LibraryView.all);
    return deleted;
  }

  Future<bool> updateDetails(BookEntity book, BookDetails details) => _change(
    () => _libraryRepository.updateDetails(bookId: book.id, details: details),
    'book details',
  );

  /// The details read back from the file, or null when that failed.
  Future<BookDetails?> resetDetails(BookEntity book) async {
    try {
      final details = await _resetBookDetailsUseCase.execute(book);
      await _refresh();
      return details;
    } catch (error, stackTrace) {
      _logger.e(
        'Unable to reset details',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> moveToTrash(BookEntity book) =>
      _change(() => _libraryRepository.moveToTrash(book.id), 'trash');

  Future<bool> restoreFromTrash(BookEntity book) =>
      _change(() => _libraryRepository.restoreFromTrash(book.id), 'restore');

  /// Removes every file in Trash, keeping annotations archived.
  Future<bool> emptyTrash() => _change(
    () => _purgeTrashUseCase.execute(everything: true),
    'empty trash',
  );

  /// The live library book with [id], for opening a duplicate import.
  Future<BookEntity?> bookById(String id) => _libraryRepository.getById(id);

  Future<void> _purgeOldTrash() async {
    try {
      await _purgeTrashUseCase.execute();
    } catch (error) {
      // Trash is purged again on the next start.
      _logger.w('Unable to purge old trash', error: error);
    }
  }

  /// Runs [change], then reloads books, collections and Trash.
  Future<bool> _change(Future<Object?> Function() change, String what) async {
    try {
      await change();
      await _refresh();
      return true;
    } catch (error, stackTrace) {
      _logger.e('Unable to update $what', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _refresh() async {
    final books = state.query.trim().isEmpty
        ? await _getLibraryBooksUseCase.execute(sort: state.sort)
        : await _searchLibraryUseCase.execute(state.query, sort: state.sort);
    emit(
      state.copyWith(
        status: LibraryStatus.success,
        books: books,
        collections: await _collectionRepository.getAll(),
        trash: await _libraryRepository.getTrash(),
      ),
    );
  }

  Future<bool> deleteBook({
    required BookEntity book,
    required DeleteBookData data,
  }) async {
    try {
      await _deleteLibraryBookUseCase.execute(book: book, data: data);
      await _refresh();
      return true;
    } catch (error, stackTrace) {
      _logger.e('Unable to delete book', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> importDocument() async {
    if (state.isImporting) return;
    emit(state.copyWith(isImporting: true));
    try {
      final importedBook = await _importDocumentUseCase.execute();
      if (importedBook == null) {
        emit(state.copyWith(isImporting: false));
        return;
      }
      final books = await _getLibraryBooksUseCase.execute(sort: state.sort);
      emit(
        state.copyWith(
          status: LibraryStatus.success,
          books: books,
          isImporting: false,
          importFeedback: LibraryImportFeedback.imported,
          importMessage: importedBook.title,
        ),
      );
    } on DuplicateDocumentException catch (error) {
      emit(
        state.copyWith(
          isImporting: false,
          importFeedback: LibraryImportFeedback.duplicate,
          importMessage: error.fileName,
          duplicateBookId: error.existingBookId,
        ),
      );
    } catch (error, stackTrace) {
      _emitImportFailure(error, stackTrace);
    }
  }

  bool get canImportFolder => _importFolderUseCase.isAvailable;

  Future<void> importFolder() async {
    if (state.isImporting) return;
    emit(state.copyWith(isImporting: true));
    try {
      final result = await _importFolderUseCase.execute();
      if (result == null) {
        emit(state.copyWith(isImporting: false));
        return;
      }
      await _refresh();
      emit(state.copyWith(isImporting: false, folderResult: result));
    } catch (error, stackTrace) {
      _emitImportFailure(error, stackTrace);
    }
  }

  Future<void> _importIncomingDocument(IncomingDocument document) async {
    if (state.isImporting) return;
    emit(state.copyWith(isImporting: true));
    try {
      final importedBook = await _importDocumentUseCase.executeIncoming(
        document,
      );
      final books = await _getLibraryBooksUseCase.execute(sort: state.sort);
      emit(
        state.copyWith(
          status: LibraryStatus.success,
          books: books,
          isImporting: false,
          importFeedback: LibraryImportFeedback.imported,
          importMessage: importedBook.title,
        ),
      );
    } on DuplicateDocumentException catch (error) {
      emit(
        state.copyWith(
          isImporting: false,
          importFeedback: LibraryImportFeedback.duplicate,
          importMessage: error.fileName,
          duplicateBookId: error.existingBookId,
        ),
      );
    } catch (error, stackTrace) {
      _emitImportFailure(error, stackTrace);
    }
  }

  void _emitImportFailure(Object error, StackTrace stackTrace) {
    _logger.e(
      'Unable to import document',
      error: error,
      stackTrace: stackTrace,
    );
    emit(
      state.copyWith(
        isImporting: false,
        importFeedback: _feedbackFor(error),
        importMessage: error.toString(),
      ),
    );
  }

  LibraryImportFeedback _feedbackFor(Object error) {
    if (error is! DocumentImportException) {
      return LibraryImportFeedback.failure;
    }
    return switch (error.kind) {
      DocumentImportFailureKind.unsupportedFormat =>
        LibraryImportFeedback.unsupportedFormat,
      DocumentImportFailureKind.unavailable =>
        LibraryImportFeedback.unavailable,
      DocumentImportFailureKind.emptyFile ||
      DocumentImportFailureKind.invalidSignature ||
      DocumentImportFailureKind.corruptDocument =>
        LibraryImportFeedback.corruptDocument,
      DocumentImportFailureKind.drmProtected =>
        LibraryImportFeedback.drmProtected,
      DocumentImportFailureKind.storage ||
      DocumentImportFailureKind.unknown => LibraryImportFeedback.failure,
    };
  }

  @override
  Future<void> close() async {
    _changeDebounce?.cancel();
    await _changesSubscription.cancel();
    await _incomingSubscription.cancel();
    await super.close();
  }
}
