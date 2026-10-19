import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';

@singleton
class SaveReadingProgressUseCase {
  SaveReadingProgressUseCase(this._libraryRepository);

  final LibraryRepository _libraryRepository;

  Future<void> execute({
    required String bookId,
    required double progress,
    String? readingLocatorJson,
  }) async {
    await _libraryRepository.updateProgress(
      bookId: bookId,
      progress: progress,
      lastReadAt: DateTime.now(),
      readingLocatorJson: readingLocatorJson,
    );
  }
}
