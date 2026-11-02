import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/document_engine/text/fb2_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/html_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/markdown_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/reflowable_text_document_engine.dart';
import 'package:lingua_pages/data/document_engine/text/txt_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'linguapages-reader-test-',
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  File write(String name, Object content) {
    final file = File('${temporaryDirectory.path}/$name');
    content is String
        ? file.writeAsStringSync(content)
        : file.writeAsBytesSync(content as List<int>);
    return file;
  }

  /// Every heading locator must point at the heading's own text.
  Future<void> expectExactHeadings(ReflowableTextDocumentEngine engine) async {
    for (final entry in await engine.tableOfContentsEntries()) {
      final offset = (entry.locator! as TextLocator).offset;
      expect(engine.text.substring(offset), startsWith(entry.title));
    }
  }

  test(
    'Markdown opens, paginates, finds chapters and resolves search',
    () async {
      final engine = MarkdownDocumentEngine(
        write(
          'chapter-notes.md',
          '# First chapter\n\nI read a **book** every week.\n\n'
              '## Second chapter\n\nSee [the site](https://x.y) and `code`.\n'
              '```\n# not a heading\n```\n',
        ),
      );

      final info = await engine.open();
      expect(info.title, 'chapter notes');
      expect(info.layout, DocumentLayout.reflowable);
      expect(await engine.tableOfContents(), [
        'First chapter',
        'Second chapter',
      ]);
      await expectExactHeadings(engine);
      expect(engine.text, contains('I read a book every week.'));
      expect(engine.text, contains('See the site and code.'));
      expect(engine.text, contains('# not a heading'));

      final results = await engine.search('site');
      expect(results.single.chapterTitle, 'Second chapter');
      expect(
        (await engine.search('book')).single.chapterTitle,
        'First chapter',
      );

      final bookStart = engine.text.indexOf('book');
      final selection = await engine.resolveSelection(
        start: bookStart,
        end: bookStart + 'book'.length,
      );
      expect(selection.text, 'book');
      expect(selection.sentence, 'I read a book every week.');
      expect(await engine.renderPage(0), isNotNull);
    },
  );

  test('HTML drops hidden content and decodes entities', () async {
    final engine = HtmlDocumentEngine(
      write(
        'page.html',
        '<html><head><title>Head title</title><style>p{}</style></head>'
            '<body><script>alert(1)</script><!-- note -->\n'
            '<h1>Opening</h1><p>It&#8217;s   a\n  test&nbsp;&amp;&amp;lt; '
            'done.</p><h2 class="x">Next <em>part</em></h2><p>More.</p>'
            '</body></html>',
      ),
    );

    await engine.open();
    expect(await engine.tableOfContents(), ['Opening', 'Next part']);
    await expectExactHeadings(engine);
    expect(engine.text, contains('It’s a test &&lt; done.'));
    expect(engine.text, isNot(contains('Head title')));
    expect(engine.text, isNot(contains('alert')));
    expect(engine.text, isNot(contains('note')));
  });

  test('FB2 uses section titles and skips description and binaries', () async {
    final engine = Fb2DocumentEngine(
      write(
        'book.fb2',
        '<?xml version="1.0" encoding="utf-8"?>'
            '<FictionBook><description><title-info><book-title>Meta'
            '</book-title></title-info></description><body>'
            '<section><title><p>Chapter 1</p></title><p>First line.</p>'
            '<empty-line/><p>Second line.</p></section>'
            '<section><title><p>Chapter 2</p></title><p>End.</p></section>'
            '</body><binary id="c.jpg">QUJDREVGRw==</binary></FictionBook>',
      ),
    );

    await engine.open();
    expect(await engine.tableOfContents(), ['Chapter 1', 'Chapter 2']);
    await expectExactHeadings(engine);
    expect(engine.text, contains('First line.'));
    expect(engine.text, isNot(contains('Meta')));
    expect(engine.text, isNot(contains('QUJD')));
    expect((await engine.search('End')).single.chapterTitle, 'Chapter 2');
  });

  test('TXT strips a BOM and falls back to Latin-1', () async {
    final engine = TxtDocumentEngine(
      write('legacy.txt', Uint8List.fromList([0x43, 0x61, 0x66, 0xE9])),
    );
    await engine.open();
    expect(engine.text, 'Café');

    final bom = TxtDocumentEngine(
      write('bom.txt', [0xEF, 0xBB, 0xBF, ...'Hi\r\nthere'.codeUnits]),
    );
    await bom.open();
    expect(bom.text, 'Hi\nthere');
    expect(await bom.tableOfContents(), isEmpty);
  });

  test('rejects use before open and invalid page indexes', () async {
    final engine = TxtDocumentEngine(write('a.txt', 'text'));

    expect(engine.search('text'), throwsStateError);
    await engine.open();
    expect(engine.renderPage(-1), throwsRangeError);
    await engine.close();
    expect(engine.tableOfContents(), throwsStateError);
  });
}
