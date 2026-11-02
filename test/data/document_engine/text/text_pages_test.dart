import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/document_engine/text/text_pages.dart';

void main() {
  test('moves each page edge to the next word start', () {
    // The grid at 8 falls inside "bbbbbbb"; the one at 16 is a word start.
    final pages = TextPages('aaaa bbbbbbb cc dd', size: 8);

    expect([for (var i = 0; i < pages.count; i++) pages.pageText(i)], [
      'aaaa bbbbbbb ',
      'cc ',
      'dd',
    ]);
  });

  test('every offset maps to the page that shows it', () {
    final text = List.generate(300, (i) => 'word$i').join(' ');
    final pages = TextPages(text, size: 50);

    expect(
      [
        for (var page = 0; page < pages.count; page++) pages.pageText(page),
      ].join(),
      text,
    );
    for (var offset = 0; offset < text.length; offset++) {
      final page = pages.pageOf(offset);
      expect(offset, greaterThanOrEqualTo(pages.start(page)));
      expect(offset, lessThan(pages.end(page)));
    }
    for (var page = 1; page < pages.count; page++) {
      expect(text[pages.start(page) - 1], ' ');
    }
  });

  test('cuts a long unbroken run on the grid', () {
    final pages = TextPages('x' * 200, size: 50);

    expect(pages.count, 4);
    expect(pages.start(1), 50);
  });

  test('handles empty text as one empty page', () {
    final pages = TextPages('');

    expect(pages.count, 1);
    expect(pages.pageText(0), '');
    expect(pages.pageOf(10), 0);
  });
}
