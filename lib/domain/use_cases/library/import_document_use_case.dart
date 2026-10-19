import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';

@singleton
class ImportDocumentUseCase {
  ImportDocumentUseCase(this._documentImportService, this._libraryRepository);

  final DocumentImportService _documentImportService;
  final LibraryRepository _libraryRepository;

  Future<BookEntity?> execute() async {
    final document = await _documentImportService.pickDocument();
    if (document == null) return null;
    return _libraryRepository.importDocument(document);
  }

  Future<BookEntity> executeIncoming(IncomingDocument incomingDocument) async {
    final document = await _documentImportService.importExternalFile(
      path: incomingDocument.path,
      fileName: incomingDocument.fileName,
    );
    return _libraryRepository.importDocument(document);
  }
}
