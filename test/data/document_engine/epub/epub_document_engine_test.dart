import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/document_engine/epub/epub_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

void main() {
  late Directory temporaryDirectory;
  late File epub;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'linguapages-epub-test-',
    );
    epub = File('${temporaryDirectory.path}/fixture.epub');
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
              '<dc:title xmlns:dc="http://purl.org/dc/elements/1.1/">A Short Book</dc:title>'
              '<dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">A Reader</dc:creator>'
              '<dc:language xmlns:dc="http://purl.org/dc/elements/1.1/">en</dc:language>'
              '</metadata><manifest>'
              '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>'
              '<item id="chapter" href="chapter.xhtml" media-type="application/xhtml+xml"/>'
              '</manifest><spine><itemref idref="chapter"/></spine></package>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'OEBPS/nav.xhtml',
          '<html><body><nav><ol><li><a href="chapter.xhtml">Opening</a>'
              '</li></ol></nav></body></html>',
        ),
      )
      ..addFile(
        ArchiveFile.string(
          'OEBPS/chapter.xhtml',
          '<html><body><h1>Opening</h1>'
              '<p>I read a book every week.</p></body></html>',
        ),
      );
    await epub.writeAsBytes(ZipEncoder().encode(archive));
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('opens EPUB metadata, spine, navigation and text selection', () async {
    final engine = EpubDocumentEngine(epub);

    final info = await engine.open();
    expect(info.title, 'A Short Book');
    expect(info.author, 'A Reader');
    expect(info.languageCode, 'en');
    expect(info.format, DocumentFormat.epub);
    expect(await engine.tableOfContents(), ['Opening']);
    final contents = await engine.tableOfContentsEntries();
    expect(contents.single.title, 'Opening');
    expect(contents.single.locator, isA<TextLocator>());
    expect(await engine.pageIndexForLocator(contents.single.locator!), 0);

    final results = await engine.search('book');
    expect(results.single.text, 'book');
    expect(results.single.chapterTitle, 'Opening');
    expect(results.single.locator, isA<TextLocator>());

    final selection = await engine.resolveSelection(
      start: results.single.locator is TextLocator
          ? (results.single.locator as TextLocator).offset
          : 0,
      end: (results.single.locator as TextLocator).offset + 4,
    );
    expect(selection.text, 'book');
    expect(selection.sentence, 'I read a book every week.');
    expect(await engine.renderPage(0), isNotNull);
  });
}
