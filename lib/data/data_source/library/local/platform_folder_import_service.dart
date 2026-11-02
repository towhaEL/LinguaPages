import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';

@LazySingleton(as: FolderImportService)
class PlatformFolderImportService implements FolderImportService {
  static const _channel = MethodChannel('lingua_pages/folder_import');

  @override
  bool get isAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<List<FolderDocument>?> pickFolder() async {
    final documents = await _channel.invokeListMethod<Object?>('pickFolder');
    if (documents == null) return null;
    return [
      for (final document in documents)
        if (document case {
          'uri': final String uri,
          'fileName': final String name,
        })
          FolderDocument(uri: uri, fileName: name),
    ];
  }

  @override
  Future<IncomingDocument?> copy(FolderDocument document) async {
    final copied = await _channel.invokeMapMethod<String, Object?>(
      'copyDocument',
      document.uri,
    );
    final path = copied?['path'];
    final fileName = copied?['fileName'];
    if (path is! String || fileName is! String) return null;
    return IncomingDocument(path: path, fileName: fileName);
  }

  @override
  Future<void> discard(IncomingDocument copy) async {
    try {
      await File(copy.path).delete();
    } on FileSystemException {
      // The copy lives in the cache, which the system clears anyway.
    }
  }
}
