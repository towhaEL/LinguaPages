import 'dart:convert';
import 'dart:typed_data';

import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';

/// Verifies that a selected file's content is compatible with its extension.
class DocumentSignatureValidator {
  const DocumentSignatureValidator();

  void validate({required DocumentFormat format, required Uint8List header}) {
    if (header.isEmpty) {
      throw const DocumentSignatureException(
        'The selected file is empty.',
        kind: DocumentImportFailureKind.emptyFile,
      );
    }

    final isValid = switch (format) {
      DocumentFormat.pdf => _startsWith(header, const [37, 80, 68, 70, 45]),
      DocumentFormat.epub => _startsWith(header, const [80, 75]),
      DocumentFormat.txt ||
      DocumentFormat.markdown ||
      DocumentFormat.html ||
      DocumentFormat.fb2 => _isText(header),
    };

    if (!isValid) {
      throw DocumentSignatureException(
        'The file content does not match the selected ${format.name} format.',
        kind: DocumentImportFailureKind.invalidSignature,
      );
    }
  }

  bool _startsWith(Uint8List bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }

  bool _isText(Uint8List bytes) {
    if (bytes.contains(0)) return false;
    try {
      utf8.decode(bytes, allowMalformed: true);
      return true;
    } on FormatException {
      return false;
    }
  }
}

class DocumentSignatureException extends DocumentImportException {
  const DocumentSignatureException(
    String message, {
    super.kind = DocumentImportFailureKind.invalidSignature,
  }) : super(message: message);
}
