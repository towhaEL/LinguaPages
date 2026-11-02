import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_metadata_extractor.dart';

/// Re-reads title, author, series and language from the book's own file,
/// undoing manual edits.
@singleton
class ResetBookDetailsUseCase {
  ResetBookDetailsUseCase(this._libraryRepository, this._metadataExtractor);

  final LibraryRepository _libraryRepository;
  final DocumentMetadataExtractor _metadataExtractor;

  Future<BookDetails> execute(BookEntity book) async {
    final metadata = await _metadataExtractor.extract(
      format: book.format,
      fileName: book.sourceFileName,
      path: book.sourceUri,
    );
    final details = BookDetails(
      title: metadata.title ?? _titleFromFileName(book.sourceFileName),
      author: metadata.author,
      series: metadata.series,
      seriesIndex: metadata.seriesIndex,
      languageCode: metadata.languageCode,
    );
    await _libraryRepository.updateDetails(bookId: book.id, details: details);
    return details;
  }

  String _titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final title = (dot > 0 ? fileName.substring(0, dot) : fileName)
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    return title.isEmpty ? fileName : title;
  }
}
