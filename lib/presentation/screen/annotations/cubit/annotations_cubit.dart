import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_state.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';

@injectable
class AnnotationsCubit extends Cubit<AnnotationsState> {
  AnnotationsCubit(
    this._libraryRepository,
    this._highlightRepository,
    this._bookmarkRepository,
    this._logger,
  ) : super(const AnnotationsState());

  final LibraryRepository _libraryRepository;
  final HighlightRepository _highlightRepository;
  final BookmarkRepository _bookmarkRepository;
  final Logger _logger;

  /// Loads annotations of books in the library; those of books in Trash or
  /// removed earlier cannot be opened and are left out.
  Future<void> load() async {
    try {
      final books = {
        for (final book in await _libraryRepository.getAll()) book.id: book,
      };
      final (highlights, bookmarks) = await (
        _highlightRepository.getAll(),
        _bookmarkRepository.getAll(),
      ).wait;
      final items = [
        for (final highlight in highlights)
          if (books[highlight.bookId] case final book?)
            AnnotationItem(note: ReaderNote.highlight(highlight), book: book),
        for (final bookmark in bookmarks)
          if (books[bookmark.bookId] case final book?)
            AnnotationItem(note: ReaderNote.bookmark(bookmark), book: book),
      ]..sort((a, b) => b.note.createdAt.compareTo(a.note.createdAt));
      emit(state.copyWith(status: AnnotationsStatus.success, items: items));
    } catch (error, stackTrace) {
      _logger.e(
        'Unable to load annotations',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(status: AnnotationsStatus.failure));
    }
  }

  void setType(AnnotationType type) => emit(state.copyWith(type: type));

  void setColor(HighlightColor? color) =>
      emit(state.copyWith(color: () => color));

  void setBook(String? bookId) => emit(state.copyWith(bookId: () => bookId));

  void search(String query) => emit(state.copyWith(query: query));
}
