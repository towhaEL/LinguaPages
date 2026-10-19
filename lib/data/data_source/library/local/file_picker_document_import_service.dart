import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';
import 'package:lingua_pages/domain/service/document_metadata_extractor.dart';
import 'package:lingua_pages/domain/service/document_signature_validator.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

@LazySingleton(as: DocumentImportService)
class FilePickerDocumentImportService implements DocumentImportService {
  FilePickerDocumentImportService(
    this._storageService,
    this._metadataExtractor,
  );

  final DocumentStorageService _storageService;
  final DocumentMetadataExtractor _metadataExtractor;

  static const _signatureValidator = DocumentSignatureValidator();

  static const _extensions = [
    'epub',
    'pdf',
    'txt',
    'md',
    'markdown',
    'html',
    'htm',
    'xhtml',
    'fb2',
  ];

  @override
  Future<BookImportRequest?> pickDocument() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _extensions,
    );
    if (file == null) return null;

    final path = file.path;
    final bytes = path == null ? await file.readAsBytes() : null;
    final fileSizeBytes = file.lengthSync() ?? await file.length() ?? 0;
    return _createImportRequest(
      fileName: file.name,
      fileSizeBytes: fileSizeBytes,
      path: path,
      bytes: bytes,
    );
  }

  @override
  Future<BookImportRequest> importExternalFile({
    required String path,
    required String fileName,
  }) async {
    final source = File(path);
    if (!await source.exists()) {
      throw const DocumentUnavailableException(
        'The opened document is no longer available.',
      );
    }

    return _createImportRequest(
      fileName: fileName,
      fileSizeBytes: await source.length(),
      path: path,
      bytes: null,
    );
  }

  Future<BookImportRequest> _createImportRequest({
    required String fileName,
    required int fileSizeBytes,
    required String? path,
    required Uint8List? bytes,
  }) async {
    final format = _formatFromFileName(fileName);
    final header = await _readHeader(path: path, bytes: bytes);
    _signatureValidator.validate(format: format, header: header);
    await _metadataExtractor.validate(
      format: format,
      fileName: fileName,
      path: path,
      bytes: bytes,
    );
    final fingerprint = await _contentFingerprint(path: path, bytes: bytes);
    final sourceUri = await _storageService.store(
      sourceFileName: fileName,
      contentFingerprint: fingerprint,
      sourcePath: path,
      bytes: bytes,
    );

    var metadata = const DocumentMetadata();
    try {
      metadata = await _metadataExtractor.extract(
        format: format,
        fileName: fileName,
        path: path,
        bytes: bytes,
      );
    } on Object {
      // Metadata is an enhancement. Keep import successful when a package has
      // malformed or unsupported optional metadata.
    }

    String? coverPath;
    final coverBytes = metadata.coverBytes;
    if (coverBytes != null && coverBytes.isNotEmpty) {
      try {
        coverPath = await _storageService.storeCover(
          contentFingerprint: fingerprint,
          sourceFileName: metadata.coverFileName ?? 'cover.bin',
          bytes: coverBytes,
        );
      } on Object {
        // A missing cover must not prevent the book itself from importing.
      }
    }

    return BookImportRequest(
      title: metadata.title ?? _titleFromFileName(fileName),
      author: metadata.author,
      format: format,
      sourceUri: sourceUri,
      sourceFileName: fileName,
      contentFingerprint: fingerprint,
      coverPath: coverPath,
      languageCode: metadata.languageCode,
      tableOfContents: metadata.tableOfContents,
      fileSizeBytes: fileSizeBytes,
    );
  }

  Future<String> _contentFingerprint({
    required String? path,
    required Uint8List? bytes,
  }) async {
    var hash = 0xcbf29ce484222325;
    if (path != null && path.isNotEmpty) {
      await for (final chunk in File(path).openRead()) {
        for (final byte in chunk) {
          hash ^= byte;
          hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
        }
      }
    } else if (bytes != null) {
      for (final byte in bytes) {
        hash ^= byte;
        hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
      }
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<Uint8List> _readHeader({
    required String? path,
    required Uint8List? bytes,
  }) async {
    if (path == null || path.isEmpty) {
      if (bytes == null) {
        throw const DocumentUnavailableException(
          'The selected file cannot be opened.',
        );
      }
      return Uint8List.fromList(bytes.take(32).toList());
    }

    final header = await File(path)
        .openRead(0, 32)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    return Uint8List.fromList(header);
  }

  DocumentFormat _formatFromFileName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'epub' => DocumentFormat.epub,
      'pdf' => DocumentFormat.pdf,
      'txt' => DocumentFormat.txt,
      'md' || 'markdown' => DocumentFormat.markdown,
      'html' || 'htm' || 'xhtml' => DocumentFormat.html,
      'fb2' => DocumentFormat.fb2,
      _ => throw const UnsupportedDocumentException(
        'This document type is not supported.',
      ),
    };
  }

  String _titleFromFileName(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    final withoutExtension = lastDot > 0
        ? fileName.substring(0, lastDot)
        : fileName;
    return withoutExtension.replaceAll(RegExp('[_-]+'), ' ').trim();
  }
}
