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
