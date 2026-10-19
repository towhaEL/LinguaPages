import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/document_engine/pdf/pdf_document_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  late Directory temporaryDirectory;
  late File pdf;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('lingua-pdf-');
    pdf = File('${temporaryDirectory.path}/sample-reader.pdf')
      ..writeAsBytesSync(_samplePdfBytes());
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'opens, searches, selects and renders text-based PDFs',
    () async {
      final engine = PdfDocumentEngine(pdf);

      final info = await engine.open();
      expect(info.title, 'sample-reader');
      expect(info.format.name, 'pdf');
      expect(info.layout.name, 'fixed');
      expect(info.pageCount, 1);

      final results = await engine.search('PDF world');
      expect(results, hasLength(1));
      expect(results.single.text, 'PDF world');
      expect(results.single.locator, isA<PdfLocator>());
      final locator = results.single.locator as PdfLocator;
      expect(locator.page, 1);
      expect(locator.textOffset, isNotNull);

      final selection = await engine.resolveSelection(start: 6, end: 15);
      expect(selection.text, 'PDF world');
      expect(selection.locator, isA<PdfLocator>());

      final rendered = await engine.renderPage(0);
      expect(rendered, isNotNull);
      expect(rendered!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);

      await engine.close();
      expect(engine.search('PDF'), throwsStateError);
    },
    skip:
        'Requires PDFium native assets unavailable to the Flutter VM test runner.',
  );

  test(
    'rejects page indexes outside the PDF',
    () async {
      final engine = PdfDocumentEngine(pdf);
      await engine.open();

      expect(engine.renderPage(-1), throwsRangeError);
      expect(engine.renderPage(1), throwsRangeError);

      await engine.close();
    },
    skip:
        'Requires PDFium native assets unavailable to the Flutter VM test runner.',
  );
}

List<int> _samplePdfBytes() {
  const content = 'BT\n/F1 18 Tf\n72 220 Td\n(Hello PDF world.) Tj\nET\n';
  final objects = [
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 300 300] '
        '/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>',
    '<< /Length ${utf8.encode(content).length} >>\nstream\n$content\nendstream',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  ];

  final output = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[0];
  for (var index = 0; index < objects.length; index++) {
    offsets.add(output.length);
    output
      ..write('${index + 1} 0 obj\n')
      ..write(objects[index])
      ..write('\nendobj\n');
  }

  final crossReferenceOffset = output.length;
  output
    ..write('xref\n0 ${objects.length + 1}\n')
    ..write('0000000000 65535 f \n');
  for (final offset in offsets.skip(1)) {
    output.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  output
    ..write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
    ..write('startxref\n$crossReferenceOffset\n%%EOF\n');
  return utf8.encode(output.toString());
}
