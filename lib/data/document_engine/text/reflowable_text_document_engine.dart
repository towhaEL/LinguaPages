import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/data/document_engine/text/text_pages.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';

/// Readable text produced by a format parser, with each heading's offset.
class ReflowableText {
  const ReflowableText(this.text, this.headings);

  /// Builds the text from [marked], where each heading is wrapped in
  /// [headingStart] and [headingEnd]. Run it after all other normalization
  /// so the recorded offsets stay exact.
  factory ReflowableText.fromMarked(String marked) {
    final buffer = StringBuffer();
    final headings = <DocumentTocEntry>[];
    var index = 0;
    while (index < marked.length) {
      final start = marked.indexOf(headingStart, index);
      if (start < 0) {
        buffer.write(marked.substring(index));
        break;
      }
      buffer.write(marked.substring(index, start));
      var end = marked.indexOf(headingEnd, start);
      if (end < 0) end = marked.length;
      final raw = marked.substring(start + 1, end);
      final title = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (title.isNotEmpty) {
        headings.add(
          DocumentTocEntry(
            title: title,
            locator: TextLocator(offset: buffer.length),
          ),
        );
      }
      buffer.write(raw);
      index = end + 1;
    }
    return ReflowableText(buffer.toString(), headings);
  }

  static const headingStart = '\u0001';
  static const headingEnd = '\u0002';

  final String text;
  final List<DocumentTocEntry> headings;
}

/// Shared pagination, search and selection for the reflowable text formats.
/// Each format subclass only turns its source into [ReflowableText].
abstract class ReflowableTextDocumentEngine implements DocumentEngine {
  ReflowableTextDocumentEngine(this.file);

  final File file;
  String? _text;
  TextPages? _textPages;
  List<DocumentTocEntry> _headings = const [];

  DocumentFormat get format;

  ReflowableText parse(String source);

  @override
  String get text {
    final value = _text;
    if (value == null) throw StateError('The document is not open.');
    return value;
  }

  @override
  Future<DocumentInfo> open() async {
    final parsed = parse(decodeText(await file.readAsBytes()));
    _text = parsed.text;
    _textPages = null;
    _headings = parsed.headings;
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
    _textPages = null;
    _headings = const [];
  }

  @override
  Future<List<String>> tableOfContents() async {
    _ensureOpen();
    return List.unmodifiable(_headings.map((entry) => entry.title));
  }

  @override
  Future<List<DocumentTocEntry>> tableOfContentsEntries() async {
    _ensureOpen();
    return List.unmodifiable(_headings);
  }

  @override
  Future<int?> pageIndexForLocator(DocumentLocator locator) async {
    _ensureOpen();
    return switch (locator) {
      TextLocator(:final offset) => _pages.pageOf(offset),
      _ => null,
    };
  }

  @override
  Future<Uint8List?> renderPage(int pageIndex) async {
    _ensureOpen();
    if (pageIndex < 0 || pageIndex >= _pageCount) {
      throw RangeError.index(pageIndex, 'pageIndex');
    }
    return Uint8List.fromList(utf8.encode(_pages.pageText(pageIndex)));
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
    return _pages.pageText(pageIndex);
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

  int get _pageCount => _pages.count;

  TextPages get _pages => _textPages ??= TextPages(text);

  @override
  int pageStartOffset(int pageIndex) => _pages.start(pageIndex);

  @override
  int pageIndexForOffset(int offset) => _pages.pageOf(offset);

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

  String _chapterAt(int offset) {
    var chapter = _title;
    for (final heading in _headings) {
      if ((heading.locator! as TextLocator).offset > offset) break;
      chapter = heading.title;
    }
    return chapter;
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

/// Decodes UTF-8 (dropping a BOM), falling back to Latin-1 for legacy files.
String decodeText(Uint8List bytes) {
  final start =
      bytes.length >= 3 &&
          bytes[0] == 0xEF &&
          bytes[1] == 0xBB &&
          bytes[2] == 0xBF
      ? 3
      : 0;
  final content = Uint8List.sublistView(bytes, start);
  try {
    return utf8.decode(content);
  } on FormatException {
    return latin1.decode(content);
  }
}

/// Collapses blank-line runs and trims, keeping heading markers intact.
String tidyLines(String text) => text
    .replaceAll(RegExp(r'[ \t]*\n[ \t]*'), '\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

/// Decodes HTML/XML character references in one pass, so `&amp;lt;` stays
/// `&lt;`.
String decodeEntities(String text) => text.replaceAllMapped(
  RegExp(r'&(#[xX][0-9a-fA-F]+|#\d+|[a-zA-Z]+);'),
  (match) {
    final name = match.group(1)!;
    if (name.startsWith('#')) {
      final hex = name.length > 1 && (name[1] == 'x' || name[1] == 'X');
      final code = int.tryParse(
        hex ? name.substring(2) : name.substring(1),
        radix: hex ? 16 : 10,
      );
      return code == null || code > 0x10FFFF
          ? match.group(0)!
          : String.fromCharCode(code);
    }
    return _namedEntities[name] ?? match.group(0)!;
  },
);

const _namedEntities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'mdash': '\u2014',
  'ndash': '\u2013',
  'hellip': '\u2026',
  'lsquo': '\u2018',
  'rsquo': '\u2019',
  'ldquo': '\u201C',
  'rdquo': '\u201D',
  'laquo': '\u00AB',
  'raquo': '\u00BB',
  'copy': '\u00A9',
  'shy': '',
};
