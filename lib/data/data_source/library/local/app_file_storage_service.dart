import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

@LazySingleton(as: DocumentStorageService)
class AppFileStorageService implements DocumentStorageService {
  @override
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    Uint8List? bytes,
  }) async {
    final appDirectory = await getApplicationSupportDirectory();
    final documentsDirectory = Directory('${appDirectory.path}/documents');
    await documentsDirectory.create(recursive: true);

    final safeName = _safeFileName(sourceFileName);
    final destination = File(
      '${documentsDirectory.path}/$contentFingerprint-$safeName',
    );
    if (await destination.exists()) return destination.path;

    if (sourcePath != null && sourcePath.isNotEmpty) {
      final source = File(sourcePath);
      if (await source.exists()) {
        if (source.absolute.path == destination.absolute.path) {
          return destination.path;
        }
        await source.copy(destination.path);
        return destination.path;
      }
    }

    if (bytes != null) {
      await destination.writeAsBytes(bytes, flush: true);
      return destination.path;
    }

    throw const DocumentStorageException(
      'The selected document could not be copied into app storage.',
    );
  }

  @override
  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required Uint8List bytes,
  }) async {
    final appDirectory = await getApplicationSupportDirectory();
    final coversDirectory = Directory('${appDirectory.path}/covers');
    await coversDirectory.create(recursive: true);

    final safeName = _safeFileName(sourceFileName);
    final destination = File(
      '${coversDirectory.path}/$contentFingerprint-$safeName',
    );
    if (!await destination.exists()) {
      await destination.writeAsBytes(bytes, flush: true);
    }
    return destination.path;
  }

  @override
  Future<void> delete({required String sourceUri, String? coverPath}) async {
    final appDirectory = await getApplicationSupportDirectory();
    final root = Directory(appDirectory.path).absolute.path;
    for (final path in [sourceUri, coverPath]) {
      if (path == null || path.isEmpty) continue;
      final file = File(path).absolute;
      if (!_isInside(file.path, root)) {
        throw const DocumentStorageException(
          'The document is outside app-private storage.',
        );
      }
      if (await file.exists()) await file.delete();
    }
  }

  bool _isInside(String path, String root) {
    final separator = Platform.pathSeparator;
    return path == root || path.startsWith('$root$separator');
  }

  String _safeFileName(String fileName) {
    final normalized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return normalized.isEmpty ? 'document' : normalized;
  }
}

class DocumentStorageException extends DocumentImportException {
  const DocumentStorageException(String message)
    : super(kind: DocumentImportFailureKind.storage, message: message);
}
