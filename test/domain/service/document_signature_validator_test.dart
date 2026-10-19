import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/service/document_signature_validator.dart';

void main() {
  const validator = DocumentSignatureValidator();

  test('accepts signatures for PDF, EPUB and text formats', () {
    expect(
      () => validator.validate(
        format: DocumentFormat.pdf,
        header: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
      returnsNormally,
    );
    expect(
      () => validator.validate(
        format: DocumentFormat.epub,
        header: Uint8List.fromList([80, 75, 3, 4]),
      ),
      returnsNormally,
    );
    expect(
      () => validator.validate(
        format: DocumentFormat.markdown,
        header: Uint8List.fromList('# A chapter'.codeUnits),
      ),
      returnsNormally,
    );
  });

  test('rejects mismatched and empty files', () {
    expect(
      () => validator.validate(
        format: DocumentFormat.pdf,
        header: Uint8List.fromList('plain text'.codeUnits),
      ),
      throwsA(isA<DocumentSignatureException>()),
    );
    expect(
      () =>
          validator.validate(format: DocumentFormat.txt, header: Uint8List(0)),
      throwsA(
        isA<DocumentSignatureException>().having(
          (error) => error.kind,
          'kind',
          DocumentImportFailureKind.emptyFile,
        ),
      ),
    );
  });
}
