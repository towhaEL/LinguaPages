import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';

/// Reflowable engine for plain text and text-backed markup formats.
///
/// It deliberately keeps pagination format-neutral. Richer format adapters
/// can replace this implementation without changing the domain contract.
class PlainTextDocumentEngine implements DocumentEngine {
  PlainTextDocumentEngine({required this.file, required this.format})
    : assert(
        format == DocumentFormat.txt ||
            format == DocumentFormat.markdown ||
            format == DocumentFormat.html ||
            format == DocumentFormat.fb2,
      );

  static const pageCharacterCount = 2400;

  final File file;
  final DocumentFormat format;
  String? _text;
  List<String> _headings = const [];

  String get text {
    final value = _text;
    if (value == null) throw StateError('The document is not open.');
    return value;
  }

  @override
  Future<DocumentInfo> open() async {
    final bytes = await file.readAsBytes();
    final source = utf8.decode(bytes, allowMalformed: true);
    _text = _toReadableText(source);
    _headings = _extractHeadings(source);
    return DocumentInfo(
      title: _title,
      format: format,
      layout: DocumentLayout.reflowable,
      pageCount: _pageCount,
    );
  }

  @override
  Future<void> close() async {
    _text = null;
    _headings = const [];
  }

  @override
  Future<List<String>> tableOfContents() async {
    _ensureOpen();
    return List.unmodifiable(_headings);
  }

  @override
  Future<List<DocumentTocEntry>> tableOfContentsEntries() async {
    _ensureOpen();
    var searchStart = 0;
    return _headings
        .map((heading) {
          final offset = text.toLowerCase().indexOf(
            heading.toLowerCase(),
            searchStart,
          );
          final resolvedOffset = offset < 0 ? searchStart : offset;
          searchStart = resolvedOffset + heading.length;
          return DocumentTocEntry(
            title: heading,
            locator: TextLocator(offset: resolvedOffset),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<int?> pageIndexForLocator(DocumentLocator locator) async {
    _ensureOpen();
    return switch (locator) {
      TextLocator(:final offset) => offset ~/ pageCharacterCount,
      _ => null,
    };
  }

  @override
  Future<Uint8List?> renderPage(int pageIndex) async {
    _ensureOpen();
    if (pageIndex < 0 || pageIndex >= _pageCount) {
      throw RangeError.index(pageIndex, 'pageIndex');
    }
    final start = pageIndex * pageCharacterCount;
    final end = (start + pageCharacterCount).clamp(0, text.length);
    return Uint8List.fromList(utf8.encode(text.substring(start, end)));
  }

  @override
  Future<Uint8List?> renderPageThumbnail(int pageIndex) =>
      renderPage(pageIndex);

  @override
  Future<String?> pageText(int pageIndex) async {
    _ensureOpen();
    if (pageIndex < 0 || pageIndex >= _pageCount) {
      throw RangeError.index(pageIndex, 'pageIndex');
    }
    final start = pageIndex * pageCharacterCount;
    final end = (start + pageCharacterCount).clamp(0, text.length);
    return text.substring(start, end);
  }

  @override
  Future<List<DocumentSearchResult>> search(String query) async {
    _ensureOpen();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final results = <DocumentSearchResult>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();
    var offset = 0;
    while (true) {
      final match = lowerText.indexOf(lowerQuery, offset);
      if (match < 0) break;
      results.add(
        DocumentSearchResult(
          text: text.substring(match, match + normalizedQuery.length),
          locator: TextLocator(offset: match),
          chapterTitle: _chapterAt(match),
        ),
      );
      offset = match + normalizedQuery.length;
    }
    return results;
  }

  @override
  Future<DocumentTextSelection> resolveSelection({
    required int start,
    required int end,
  }) async {
    _ensureOpen();
    if (start < 0 || end < start || end > text.length) {
      throw RangeError('Invalid selection range: $start..$end');
    }
    return DocumentTextSelection(
      text: text.substring(start, end),
      locator: TextLocator(offset: start),
      sentence: _sentenceAround(start, end),
    );
  }

  int get _pageCount => text.isEmpty
      ? 1
      : (text.length + pageCharacterCount - 1) ~/ pageCharacterCount;

  String get _title {
    final name = file.uri.pathSegments.isEmpty
        ? 'Untitled document'
        : file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return (dot > 0 ? name.substring(0, dot) : name).replaceAll(
      RegExp(r'[_-]+'),
      ' ',
    );
  }

  String _toReadableText(String source) {
    if (format == DocumentFormat.txt || format == DocumentFormat.markdown) {
      return source.replaceAll('\r\n', '\n');
    }
    return source
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|div|li|h[1-6])>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('\r\n', '\n')
        .trim();
  }

  List<String> _extractHeadings(String source) {
    if (format == DocumentFormat.markdown) {
      return source
          .split('\n')
          .map(
            (line) => RegExp(
              r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$',
            ).firstMatch(line)?.group(1),
          )
          .whereType<String>()
          .toList(growable: false);
    }
    if (format == DocumentFormat.html || format == DocumentFormat.fb2) {
      final headingPattern = RegExp(
        r'<h[1-6][^>]*>(.*?)</h[1-6]>',
        caseSensitive: false,
        dotAll: true,
      );
      return headingPattern
          .allMatches(source)
          .map((match) => match.group(1) ?? '')
          .map((heading) => heading.replaceAll(RegExp(r'<[^>]+>'), '').trim())
          .where((heading) => heading.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  String _chapterAt(int offset) {
    if (_headings.isEmpty) return _title;
    final pageIndex = offset ~/ pageCharacterCount;
    return _headings[pageIndex.clamp(0, _headings.length - 1)];
  }

  String _sentenceAround(int start, int end) {
    var sentenceStart = start;
    while (sentenceStart > 0 && !'.!?\n'.contains(text[sentenceStart - 1])) {
      sentenceStart--;
    }
    while (sentenceStart < text.length && text[sentenceStart] == ' ') {
      sentenceStart++;
    }

    var sentenceEnd = end;
    while (sentenceEnd < text.length && !'.!?\n'.contains(text[sentenceEnd])) {
      sentenceEnd++;
    }
    if (sentenceEnd < text.length) sentenceEnd++;
    return text.substring(sentenceStart, sentenceEnd).trim();
  }

  void _ensureOpen() {
    if (_text == null) throw StateError('The document is not open.');
  }
}
