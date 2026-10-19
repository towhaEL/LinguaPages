import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/document_engine/text/plain_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/core/document/document_locator.dart';

void main() {
  late Directory temporaryDirectory;
  late File document;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'linguapages-reader-test-',
    );
    document = File('${temporaryDirectory.path}/chapter-notes.md');
    await document.writeAsString(
      '# First chapter\n\nI read a book every week.\n\n'
      '## Second chapter\n\nReading helps me learn.\n',
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('opens, paginates, extracts headings and resolves search', () async {
    final engine = PlainTextDocumentEngine(
      file: document,
      format: DocumentFormat.markdown,
    );

    final info = await engine.open();
    expect(info.title, 'chapter notes');
    expect(info.layout, DocumentLayout.reflowable);
    expect(await engine.tableOfContents(), ['First chapter', 'Second chapter']);
    final contents = await engine.tableOfContentsEntries();
    expect(contents, hasLength(2));
    expect(contents.first.title, 'First chapter');
    expect(contents.first.locator, isA<TextLocator>());
    expect(await engine.pageIndexForLocator(contents.last.locator!), 0);

    final results = await engine.search('book');
    expect(results.single.text, 'book');
    expect(results.single.locator, isA<TextLocator>());
    expect(results.single.chapterTitle, 'First chapter');

    final content = await document.readAsString();
    final bookStart = content.indexOf('book');
    final selection = await engine.resolveSelection(
      start: bookStart,
      end: bookStart + 'book'.length,
    );
    expect(selection.text, 'book');
    expect(selection.sentence, 'I read a book every week.');

    final page = await engine.renderPage(0);
    expect(page, isNotNull);
  });

  test('rejects use before open and invalid page indexes', () async {
    final engine = PlainTextDocumentEngine(
      file: document,
      format: DocumentFormat.markdown,
    );

    expect(engine.search('book'), throwsStateError);
    await engine.open();
    expect(engine.renderPage(-1), throwsRangeError);
    await engine.close();
    expect(engine.tableOfContents(), throwsStateError);
  });
}
