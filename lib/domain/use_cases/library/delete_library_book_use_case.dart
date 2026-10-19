import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

@singleton
class DeleteLibraryBookUseCase {
  DeleteLibraryBookUseCase(this._libraryRepository, this._storageService);

  final LibraryRepository _libraryRepository;
  final DocumentStorageService _storageService;

  Future<void> execute({
    required BookEntity book,
    required DeleteBookData data,
  }) async {
    await _libraryRepository.deleteBook(bookId: book.id, data: data);
    await _storageService.delete(
      sourceUri: book.sourceUri,
      coverPath: book.coverPath,
    );
  }
}
