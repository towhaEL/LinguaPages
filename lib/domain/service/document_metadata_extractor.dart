import 'dart:typed_data';

import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Extracts optional metadata without making document import dependent on it.
abstract interface class DocumentMetadataExtractor {
  Future<void> validate({
    required DocumentFormat format,
    required String fileName,
    String? path,
    Uint8List? bytes,
  });

  Future<DocumentMetadata> extract({
    required DocumentFormat format,
    required String fileName,
    String? path,
    Uint8List? bytes,
  });
}

class DocumentMetadata {
  const DocumentMetadata({
    this.title,
    this.author,
    this.languageCode,
    this.coverBytes,
    this.coverFileName,
    this.tableOfContents = const [],
  });

  final String? title;
  final String? author;
  final String? languageCode;
  final Uint8List? coverBytes;
  final String? coverFileName;
  final List<String> tableOfContents;
}
