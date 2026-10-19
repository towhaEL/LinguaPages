import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/service/annotation_markdown_exporter.dart';

void main() {
  test('exports highlights, notes and bookmarks as portable Markdown', () {
    final markdown = const AnnotationMarkdownExporter().export(
      bookTitle: 'My book',
      highlights: [
        HighlightEntity(
          id: 'highlight-1',
          bookId: 'book-1',
          selectedText: 'A quoted line',
          locator: TextLocator(offset: 12),
          color: HighlightColor.yellow,
          note: 'Remember this',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      bookmarks: [
        BookmarkEntity(
          id: 'bookmark-1',
          bookId: 'book-1',
          title: 'Chapter one',
          locator: PdfLocator(page: 3),
          createdAt: DateTime(2026, 1, 2),
        ),
      ],
    );

    expect(markdown, contains('# My book'));
    expect(markdown, contains('## Highlights'));
    expect(markdown, contains('- "A quoted line" _(yellow)_'));
    expect(markdown, contains('- Note: Remember this'));
    expect(markdown, contains('"type":"text"'));
    expect(markdown, contains('## Bookmarks'));
    expect(markdown, contains('- Chapter one'));
    expect(markdown, contains('"page":3'));
  });
}
