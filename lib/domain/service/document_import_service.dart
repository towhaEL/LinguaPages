import 'package:lingua_pages/domain/repository/library/library_repository.dart';

/// Platform-agnostic entry point for choosing one supported document.
///
/// A null response means that the person dismissed the system picker.
abstract class DocumentImportService {
  Future<BookImportRequest?> pickDocument();

  Future<BookImportRequest> importExternalFile({
    required String path,
    required String fileName,
  });
}

/// Receives documents opened from another Android application.
///
/// Implementations must expose the launch intent once through
/// [takeInitialDocument] and subsequent intents through [documents].
abstract interface class IncomingDocumentService {
  Future<IncomingDocument?> takeInitialDocument();

  Stream<IncomingDocument> get documents;
}

class IncomingDocument {
  const IncomingDocument({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

/// A supported document found in a folder the person picked.
class FolderDocument {
  const FolderDocument({required this.uri, required this.fileName});

  final String uri;
  final String fileName;
}

/// Imports a whole folder through the system folder picker (Android).
abstract interface class FolderImportService {
  /// Whether this platform can pick folders.
  bool get isAvailable;

  /// Supported documents in the picked folder and its subfolders; null when
  /// the picker was dismissed.
  Future<List<FolderDocument>?> pickFolder();

  /// Copies [document] to a temporary file that the importer can read.
  Future<IncomingDocument?> copy(FolderDocument document);

  /// Deletes a temporary copy once it has been imported.
  Future<void> discard(IncomingDocument copy);
}
