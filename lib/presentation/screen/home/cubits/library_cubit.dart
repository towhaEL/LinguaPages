import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/get_library_books_use_case.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';
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
    this._logger,
  ) : super(const LibraryState()) {
    _incomingSubscription = _incomingDocumentService.documents.listen(
      (document) => unawaited(_importIncomingDocument(document)),
    );
  }

  final GetLibraryBooksUseCase _getLibraryBooksUseCase;
  final DeleteLibraryBookUseCase _deleteLibraryBookUseCase;
  final ImportDocumentUseCase _importDocumentUseCase;
  final SearchLibraryUseCase _searchLibraryUseCase;
  final IncomingDocumentService _incomingDocumentService;
  final SettingsRepository _settingsRepository;
  final Logger _logger;
  late final StreamSubscription<IncomingDocument> _incomingSubscription;

  Future<void> load() async {
    final shelf = state.status == LibraryStatus.initial
        ? await _shelfPreferences()
        : null;
    emit(
      state.copyWith(
        status: LibraryStatus.loading,
        viewMode: shelf?.$1,
        sort: shelf?.$2,
      ),
    );
    try {
      final books = await _getLibraryBooksUseCase.execute(sort: state.sort);
      emit(state.copyWith(status: LibraryStatus.success, books: books));
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

  Future<bool> deleteBook({
    required BookEntity book,
    required DeleteBookData data,
  }) async {
    try {
      await _deleteLibraryBookUseCase.execute(book: book, data: data);
      final books = state.query.trim().isEmpty
          ? await _getLibraryBooksUseCase.execute(sort: state.sort)
          : await _searchLibraryUseCase.execute(state.query, sort: state.sort);
      emit(state.copyWith(status: LibraryStatus.success, books: books));
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
        ),
      );
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
      DocumentImportFailureKind.storage ||
      DocumentImportFailureKind.unknown => LibraryImportFeedback.failure,
    };
  }

  @override
  Future<void> close() async {
    await _incomingSubscription.cancel();
    await super.close();
  }
}
