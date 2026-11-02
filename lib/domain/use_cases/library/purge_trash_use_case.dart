import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/use_cases/library/delete_library_book_use_case.dart';

/// Removes the files of books left in Trash. Their annotations are archived,
/// so importing the same file again restores them.
@singleton
class PurgeTrashUseCase {
  PurgeTrashUseCase(this._libraryRepository, this._deleteBook);

  static const retention = Duration(days: 30);

  final LibraryRepository _libraryRepository;
  final DeleteLibraryBookUseCase _deleteBook;

  /// Purges books trashed more than [retention] ago, or all of Trash when
  /// [everything]. Returns how many were purged.
  Future<int> execute({bool everything = false, DateTime? now}) async {
    final cutoff = everything
        ? DateTime(9999)
        : (now ?? DateTime.now()).subtract(retention);
    final books = await _libraryRepository.trashedBefore(cutoff);
    for (final book in books) {
      await _deleteBook.execute(book: book, data: DeleteBookData.keep);
    }
    return books.length;
  }
}
