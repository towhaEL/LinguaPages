import 'dart:typed_data';

/// Copies an imported document into app-private storage.
abstract interface class DocumentStorageService {
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    Uint8List? bytes,
  });

  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required Uint8List bytes,
  });

  Future<void> delete({required String sourceUri, String? coverPath});
}
