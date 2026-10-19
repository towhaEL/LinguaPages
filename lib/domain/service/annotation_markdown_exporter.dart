import 'dart:convert';

import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';

/// Converts local annotations into a portable Markdown document.
///
/// The exporter deliberately has no file-system or sharing dependency. The
/// presentation layer can copy or save the returned Markdown, and a future
/// premium/export implementation can reuse the same stable contract.
class AnnotationMarkdownExporter {
  const AnnotationMarkdownExporter();

  String export({
    required String bookTitle,
    Iterable<HighlightEntity> highlights = const [],
    Iterable<BookmarkEntity> bookmarks = const [],
  }) {
    final buffer = StringBuffer()
      ..writeln('# ${_line(bookTitle)}')
      ..writeln();

    final highlightItems = highlights.toList(growable: false);
    if (highlightItems.isNotEmpty) {
      buffer
        ..writeln('## Highlights')
        ..writeln();
      for (final highlight in highlightItems) {
        buffer.writeln(
          '- ${_quote(highlight.selectedText)} _(${highlight.color.name})_',
        );
        if (highlight.note?.trim().isNotEmpty == true) {
          buffer.writeln('  - Note: ${_line(highlight.note!)}');
        }
        buffer.writeln(
          '  - Locator: `${jsonEncode(highlight.locator.toJson())}`',
        );
      }
      buffer.writeln();
    }

    final bookmarkItems = bookmarks.toList(growable: false);
    if (bookmarkItems.isNotEmpty) {
      buffer
        ..writeln('## Bookmarks')
        ..writeln();
      for (final bookmark in bookmarkItems) {
        buffer
          ..writeln('- ${_line(bookmark.title)}')
          ..writeln('  - Locator: `${jsonEncode(bookmark.locator.toJson())}`');
      }
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  String _quote(String value) => '"${value.replaceAll('"', '\\"')}"';

  String _line(String value) => value.replaceAll('\n', ' ').trim();
}
