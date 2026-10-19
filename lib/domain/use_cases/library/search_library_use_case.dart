import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';

@singleton
class SearchLibraryUseCase {
  SearchLibraryUseCase(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  Future<List<BookEntity>> execute(
    String query, {
    LibrarySort sort = LibrarySort.recent,
  }) => _libraryRepository.search(query, sort: sort);
}
