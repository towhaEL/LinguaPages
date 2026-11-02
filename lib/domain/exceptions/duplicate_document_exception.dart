class DuplicateDocumentException implements Exception {
  const DuplicateDocumentException(this.fileName, {this.existingBookId});

  final String fileName;

  /// The library book with the same content, to open instead.
  final String? existingBookId;

  @override
  String toString() => '$fileName is already in the library.';
}
