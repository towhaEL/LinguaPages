enum DocumentImportFailureKind {
  unsupportedFormat,
  unavailable,
  emptyFile,
  invalidSignature,
  corruptDocument,
  storage,
  unknown,
}

class DocumentImportException implements Exception {
  const DocumentImportException({required this.kind, required this.message});

  final DocumentImportFailureKind kind;
  final String message;

  @override
  String toString() => message;
}

class UnsupportedDocumentException extends DocumentImportException {
  const UnsupportedDocumentException(String message)
    : super(
        kind: DocumentImportFailureKind.unsupportedFormat,
        message: message,
      );
}

class DocumentUnavailableException extends DocumentImportException {
  const DocumentUnavailableException(String message)
    : super(kind: DocumentImportFailureKind.unavailable, message: message);
}

class CorruptDocumentException extends DocumentImportException {
  const CorruptDocumentException(String message)
    : super(kind: DocumentImportFailureKind.corruptDocument, message: message);
}
