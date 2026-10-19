import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:pdfrx/pdfrx.dart';

/// Fixed-layout PDF reader backed by PDFium through `pdfrx`.
///
/// The engine keeps a linear text projection for search and selection while
/// preserving PDF page and in-page offsets in [PdfLocator] values.
class PdfDocumentEngine implements DocumentEngine {
  PdfDocumentEngine(this.file);

  static const _renderWidth = 1600.0;
  static const _thumbnailWidth = 320.0;
  static Future<void>? _initialization;

  final File file;
  PdfDocument? _document;
  List<_PdfPageText> _pages = const [];
  List<_PdfOutlineEntry> _outline = const [];
  String? _text;

  String get text {
    final value = _text;
    if (value == null) throw StateError('The PDF is not open.');
    return value;
  }

  @override
  Future<DocumentInfo> open() async {
    await _ensureInitialized();
    await close();

    final document = await PdfDocument.openFile(file.path);
    _document = document;

    final pages = <_PdfPageText>[];
    var offset = 0;
    for (final page in document.pages) {
      final loadedPage = await page.ensureLoaded();
      final rawText = await loadedPage.loadText();
      final pageText = rawText?.fullText ?? '';
      pages.add(
        _PdfPageText(
          pageNumber: loadedPage.pageNumber,
          text: pageText,
          globalOffset: offset,
        ),
      );
      offset += pageText.length + 2;
    }
    _pages = pages;
    _text = pages.map((page) => page.text).join('\n\n');
    _outline = _flattenOutline(await document.loadOutline());

    return DocumentInfo(
      title: _fileTitle,
      format: DocumentFormat.pdf,
      layout: DocumentLayout.fixed,
      pageCount: document.pages.length,
    );
  }

  @override
  Future<void> close() async {
    final document = _document;
    _document = null;
    _pages = const [];
    _outline = const [];
    _text = null;
    if (document != null) await document.dispose();
  }

  @override
  Future<List<String>> tableOfContents() async {
    _ensureOpen();
    return List.unmodifiable(_outline.map((entry) => entry.title));
  }

  @override
  Future<List<DocumentTocEntry>> tableOfContentsEntries() async {
    _ensureOpen();
    return _outline
        .map(
          (entry) => DocumentTocEntry(
            title: entry.title,
            locator: entry.pageNumber == null
                ? null
                : PdfLocator(page: entry.pageNumber!),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<int?> pageIndexForLocator(DocumentLocator locator) async {
    _ensureOpen();
    return switch (locator) {
      PdfLocator(:final page) => page - 1,
      _ => null,
    };
  }

  @override
  Future<Uint8List?> renderPage(int pageIndex) async {
    return _renderPageAtWidth(pageIndex, _renderWidth);
  }

  @override
  Future<Uint8List?> renderPageThumbnail(int pageIndex) async {
    return _renderPageAtWidth(pageIndex, _thumbnailWidth);
  }

  @override
  Future<String?> pageText(int pageIndex) async {
    _ensureOpen();
    if (pageIndex < 0 || pageIndex >= _pages.length) {
      throw RangeError.index(pageIndex, 'pageIndex');
    }
    return _pages[pageIndex].text;
  }

  Future<Uint8List?> _renderPageAtWidth(int pageIndex, double width) async {
    final document = _ensureOpen();
    if (pageIndex < 0 || pageIndex >= document.pages.length) {
      throw RangeError.index(pageIndex, 'pageIndex');
    }

    final page = await document.pages[pageIndex].ensureLoaded();
    final height = (page.height * width / page.width).roundToDouble();
    final rendered = await page.render(fullWidth: width, fullHeight: height);
    if (rendered == null) return null;

    try {
      final image = await rendered.createImage();
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) return null;
        return Uint8List.fromList(bytes.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    } finally {
      rendered.dispose();
    }
  }

  @override
  Future<List<DocumentSearchResult>> search(String query) async {
    _ensureOpen();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final lowerQuery = normalizedQuery.toLowerCase();
    final results = <DocumentSearchResult>[];
    for (final page in _pages) {
      final lowerPageText = page.text.toLowerCase();
      var offset = 0;
      while (true) {
        final match = lowerPageText.indexOf(lowerQuery, offset);
        if (match < 0) break;
        results.add(
          DocumentSearchResult(
            text: page.text.substring(match, match + normalizedQuery.length),
            locator: PdfLocator(page: page.pageNumber, textOffset: match),
            chapterTitle: _chapterTitleForPage(page.pageNumber),
          ),
        );
        offset = match + normalizedQuery.length;
      }
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

    final page = _pageAtOffset(start);
    final localOffset = (start - page.globalOffset).clamp(0, page.text.length);
    return DocumentTextSelection(
      text: text.substring(start, end),
      locator: PdfLocator(page: page.pageNumber, textOffset: localOffset),
      sentence: _sentenceAround(start, end),
    );
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= pdfrxFlutterInitialize();
  }

  PdfDocument _ensureOpen() {
    final document = _document;
    if (document == null) throw StateError('The PDF is not open.');
    return document;
  }

  List<_PdfOutlineEntry> _flattenOutline(List<PdfOutlineNode> nodes) {
    final entries = <_PdfOutlineEntry>[];

    void visit(Iterable<PdfOutlineNode> children) {
      for (final node in children) {
        final title = node.title.trim();
        if (title.isNotEmpty) {
          entries.add(
            _PdfOutlineEntry(title: title, pageNumber: node.dest?.pageNumber),
          );
        }
        visit(node.children);
      }
    }

    visit(nodes);
    return entries;
  }

  _PdfPageText _pageAtOffset(int offset) {
    for (var index = _pages.length - 1; index >= 0; index--) {
      final page = _pages[index];
      if (offset >= page.globalOffset) return page;
    }
    return _pages.first;
  }

  String _chapterTitleForPage(int pageNumber) {
    var title = _fileTitle;
    for (final entry in _outline) {
      final entryPage = entry.pageNumber;
      if (entryPage != null && entryPage <= pageNumber) title = entry.title;
    }
    return title;
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

  String get _fileTitle {
    final name = file.uri.pathSegments.isEmpty
        ? 'Untitled PDF'
        : file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return (dot > 0 ? name.substring(0, dot) : name).replaceAll(
      RegExp(r'[_-]+'),
      ' ',
    );
  }
}

final class _PdfPageText {
  const _PdfPageText({
    required this.pageNumber,
    required this.text,
    required this.globalOffset,
  });

  final int pageNumber;
  final String text;
  final int globalOffset;
}

final class _PdfOutlineEntry {
  const _PdfOutlineEntry({required this.title, required this.pageNumber});

  final String title;
  final int? pageNumber;
}
