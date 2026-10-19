import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/data_source/library/local/file_picker_document_import_service.dart';
import 'package:lingua_pages/data/data_source/library/local/local_document_metadata_extractor.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/service/document_storage_service.dart';

void main() {
  late Uint8List epubBytes;

  setUp(() {
    epubBytes = _epubBytes();
  });

  test('extracts EPUB metadata and the declared cover image', () async {
    final extractor = LocalDocumentMetadataExtractor();

    final metadata = await extractor.extract(
      format: DocumentFormat.epub,
      fileName: 'fixture.epub',
      bytes: epubBytes,
    );

    expect(metadata.title, 'A Metadata Book');
    expect(metadata.author, 'A Reader');
    expect(metadata.languageCode, 'en');
    expect(metadata.coverFileName, 'cover.png');
    expect(metadata.coverBytes, [1, 2, 3, 4]);
    expect(metadata.tableOfContents, ['Opening', 'Second chapter']);
  });

  test('extracts basic PDF Info metadata without requiring PDFium', () async {
    final extractor = LocalDocumentMetadataExtractor();

    final metadata = await extractor.extract(
      format: DocumentFormat.pdf,
      fileName: 'fixture.pdf',
      bytes: Uint8List.fromList(
        '%PDF-1.7 /Title (PDF Title) /Author (PDF Author) /Lang (fr)'.codeUnits,
      ),
    );

    expect(metadata.title, 'PDF Title');
    expect(metadata.author, 'PDF Author');
    expect(metadata.languageCode, 'fr');
  });

  test('rejects an EPUB with an invalid ZIP/package structure', () async {
    final extractor = LocalDocumentMetadataExtractor();

    expect(
      extractor.validate(
        format: DocumentFormat.epub,
        fileName: 'broken.epub',
        bytes: Uint8List.fromList([80, 75, 3, 4, 1, 2, 3]),
      ),
      throwsA(isA<CorruptDocumentException>()),
    );
  });

  test('uses extracted metadata when importing an external EPUB', () async {
    final directory = await Directory.systemTemp.createTemp(
      'linguapages-metadata-import-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/filename-title.epub');
    await source.writeAsBytes(epubBytes);

    final storage = _RecordingStorageService();
    final importService = FilePickerDocumentImportService(
      storage,
      LocalDocumentMetadataExtractor(),
    );

    final request = await importService.importExternalFile(
      path: source.path,
      fileName: source.uri.pathSegments.last,
    );

    expect(request.title, 'A Metadata Book');
    expect(request.author, 'A Reader');
    expect(request.languageCode, 'en');
    expect(request.coverPath, '/covers/cover.png');
    expect(request.tableOfContents, ['Opening', 'Second chapter']);
    expect(storage.coverBytes, [1, 2, 3, 4]);
  });

  test(
    'reports unsupported external extensions before storing a file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'linguapages-unsupported-import-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final source = File('${directory.path}/book.mobi');
      await source.writeAsBytes([1, 2, 3]);

      final importService = FilePickerDocumentImportService(
        _RecordingStorageService(),
        LocalDocumentMetadataExtractor(),
      );

      expect(
        importService.importExternalFile(
          path: source.path,
          fileName: source.uri.pathSegments.last,
        ),
        throwsA(isA<UnsupportedDocumentException>()),
      );
    },
  );

  test('reports corrupt external EPUBs before storing a file', () async {
    final directory = await Directory.systemTemp.createTemp(
      'linguapages-corrupt-import-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/broken.epub');
    await source.writeAsBytes([80, 75, 3, 4, 1, 2, 3]);

    final importService = FilePickerDocumentImportService(
      _RecordingStorageService(),
      LocalDocumentMetadataExtractor(),
    );

    expect(
      importService.importExternalFile(
        path: source.path,
        fileName: source.uri.pathSegments.last,
      ),
      throwsA(isA<CorruptDocumentException>()),
    );
  });
}

Uint8List _epubBytes() {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string(
        'META-INF/container.xml',
        '<?xml version="1.0"?>'
            '<container><rootfiles><rootfile full-path="OEBPS/content.opf"/>'
            '</rootfiles></container>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/content.opf',
        '<?xml version="1.0"?>'
            '<package><metadata>'
            '<dc:title xmlns:dc="http://purl.org/dc/elements/1.1/">'
            'A Metadata Book</dc:title>'
            '<dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">'
            'A Reader</dc:creator>'
            '<dc:language xmlns:dc="http://purl.org/dc/elements/1.1/">en</dc:language>'
            '<meta name="cover" content="cover-image"/>'
            '</metadata><manifest>'
            '<item id="cover-image" href="images/cover.png" '
            'media-type="image/png"/>'
            '<item id="nav" href="nav.xhtml" '
            'media-type="application/xhtml+xml" properties="nav"/>'
            '<item id="chapter" href="chapter.xhtml" '
            'media-type="application/xhtml+xml"/>'
            '</manifest><spine><itemref idref="chapter"/></spine></package>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/chapter.xhtml',
        '<html><body><h1>Chapter</h1><p>Text.</p></body></html>',
      ),
    )
    ..addFile(
      ArchiveFile.string(
        'OEBPS/nav.xhtml',
        '<html xmlns:epub="http://www.idpf.org/2007/ops"><body>'
            '<nav epub:type="toc"><ol>'
            '<li><a href="chapter.xhtml">Opening</a></li>'
            '<li><a href="chapter.xhtml#second">Second chapter</a></li>'
            '</ol></nav></body></html>',
      ),
    )
    ..addFile(ArchiveFile.bytes('OEBPS/images/cover.png', [1, 2, 3, 4]));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

class _RecordingStorageService implements DocumentStorageService {
  Uint8List? coverBytes;

  @override
  Future<String> store({
    required String sourceFileName,
    required String contentFingerprint,
    String? sourcePath,
    Uint8List? bytes,
  }) async {
    return '/documents/$sourceFileName';
  }

  @override
  Future<String> storeCover({
    required String contentFingerprint,
    required String sourceFileName,
    required Uint8List bytes,
  }) async {
    coverBytes = bytes;
    return '/covers/$sourceFileName';
  }

  @override
  Future<void> delete({required String sourceUri, String? coverPath}) async {}
}
