import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/exceptions/duplicate_document_exception.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/use_cases/library/import_document_use_case.dart';

class FolderImportResult {
  const FolderImportResult({
    required this.imported,
    required this.duplicates,
    required this.failed,
  });

  final int imported;
  final int duplicates;
  final int failed;
}

/// Imports every supported document in a picked folder, one at a time, so
/// only one temporary copy exists at once.
@singleton
class ImportFolderUseCase {
  ImportFolderUseCase(this._folderImportService, this._importDocument);

  final FolderImportService _folderImportService;
  final ImportDocumentUseCase _importDocument;

  bool get isAvailable => _folderImportService.isAvailable;

  /// Null when the person dismissed the folder picker.
  Future<FolderImportResult?> execute() async {
    final documents = await _folderImportService.pickFolder();
    if (documents == null) return null;
    var imported = 0;
    var duplicates = 0;
    var failed = 0;
    for (final document in documents) {
      IncomingDocument? copy;
      try {
        copy = await _folderImportService.copy(document);
        if (copy == null) {
          failed++;
          continue;
        }
        await _importDocument.executeIncoming(copy);
        imported++;
      } on DuplicateDocumentException {
        duplicates++;
      } on Object {
        // One unreadable or corrupt file must not stop the rest.
        failed++;
      } finally {
        if (copy != null) await _folderImportService.discard(copy);
      }
    }
    return FolderImportResult(
      imported: imported,
      duplicates: duplicates,
      failed: failed,
    );
  }
}
