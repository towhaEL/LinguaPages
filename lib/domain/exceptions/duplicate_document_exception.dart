class DuplicateDocumentException implements Exception {
  const DuplicateDocumentException(this.fileName);

  final String fileName;

  @override
  String toString() => '$fileName is already in the library.';
}
