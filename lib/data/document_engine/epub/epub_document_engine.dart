import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';
import 'package:xml/xml.dart';

/// EPUB 2/3 reflowable reader backed by the EPUB ZIP container.
class EpubDocumentEngine implements DocumentEngine {
  EpubDocumentEngine(this.file);

  static const pageCharacterCount = 2400;

  final File file;
  Map<String, ArchiveFile> _files = const {};
  List<_EpubChapter> _chapters = const [];
  String? _text;
  String? _title;
  String? _author;
  String? _languageCode;

  String get text {
    final value = _text;
    if (value == null) throw StateError('The EPUB is not open.');
    return value;
  }

  @override
  Future<DocumentInfo> open() async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    _files = {
      for (final entry in archive.files)
        if (entry.isFile) _normalizePath(entry.name): entry,
    };

    final container = _xmlFile('META-INF/container.xml');
    final rootFile = _firstElement(container, 'rootfile');
    final opfPath = _attribute(rootFile, 'full-path');
    if (opfPath == null || opfPath.isEmpty) {
      throw const EpubDocumentException('The EPUB has no package document.');
    }

    final opf = _xmlFile(opfPath);
    _title = _firstText(opf, 'title') ?? _fileTitle;
    _author = _firstText(opf, 'creator');
    _languageCode = _firstText(opf, 'language');

    final manifest = <String, _ManifestItem>{};
    for (final item in _elements(opf, 'item')) {
      final id = _attribute(item, 'id');
      final href = _attribute(item, 'href');
      if (id == null || href == null) continue;
      manifest[id] = _ManifestItem(
        id: id,
        path: _resolvePath(opfPath, href),
        mediaType: _attribute(item, 'media-type') ?? '',
        properties: _attribute(item, 'properties') ?? '',
      );
    }

    final navigationTitles = _readNavigation(manifest);
    final spine = _firstOrNull(_elements(opf, 'spine'));
    final chapters = <_EpubChapter>[];
    if (spine != null) {
      for (final itemRef in _elements(spine, 'itemref')) {
        final idRef = _attribute(itemRef, 'idref');
        final item = idRef == null ? null : manifest[idRef];
        if (item == null) continue;
        final chapter = _readChapter(item.path, navigationTitles[item.path]);
        if (chapter != null) chapters.add(chapter);
      }
    }
    if (chapters.isEmpty) {
      for (final item in manifest.values) {
        if (_isMarkup(item.mediaType)) {
          final chapter = _readChapter(item.path, navigationTitles[item.path]);
          if (chapter != null) chapters.add(chapter);
        }
      }
    }
    if (chapters.isEmpty) {
      throw const EpubDocumentException(
        'The EPUB contains no readable chapters.',
      );
    }

    var offset = 0;
    final positionedChapters = <_EpubChapter>[];
    for (final chapter in chapters) {
      positionedChapters.add(chapter.withOffset(offset));
      offset += chapter.text.length + 2;
    }
    _chapters = positionedChapters;
    _text = _chapters.map((chapter) => chapter.text).join('\n\n');

    return DocumentInfo(
      title: _title ?? _fileTitle,
      author: _author,
      languageCode: _languageCode,
      format: DocumentFormat.epub,
      layout: DocumentLayout.reflowable,
      pageCount: _pageCount,
    );
  }

  @override
  Future<void> close() async {
    _files = const {};
    _chapters = const [];
    _text = null;
    _title = null;
    _author = null;
    _languageCode = null;
  }

  @override
  Future<List<String>> tableOfContents() async {
    _ensureOpen();
    return List.unmodifiable(_chapters.map((chapter) => chapter.title));
  }

  @override
  Future<List<DocumentTocEntry>> tableOfContentsEntries() async {
    _ensureOpen();
    return _chapters
        .map(
          (chapter) => DocumentTocEntry(
            title: chapter.title,
            locator: TextLocator(offset: chapter.offset),
          ),
        )
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
  Future<List<DocumentSearchResult>> search(String query) async {
    _ensureOpen();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const [];

    final lowerText = text.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();
    final results = <DocumentSearchResult>[];
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

  Map<String, String> _readNavigation(Map<String, _ManifestItem> manifest) {
    final result = <String, String>{};
    _ManifestItem? nav;
    for (final item in manifest.values) {
      if (item.properties.split(' ').contains('nav')) {
        nav = item;
        break;
      }
    }
    if (nav != null) {
      final document = _xmlFile(nav.path);
      for (final anchor in _elements(document, 'a')) {
        final href = _attribute(anchor, 'href');
        final title = anchor.innerText.trim();
        if (href == null || title.isEmpty) continue;
        result[_resolvePath(nav.path, href)] = title;
      }
      if (result.isNotEmpty) return result;
    }

    final ncx = manifest.values.firstWhere(
      (item) => item.mediaType == 'application/x-dtbncx+xml',
      orElse: () => const _ManifestItem.empty(),
    );
    if (ncx.path.isNotEmpty) {
      final document = _xmlFile(ncx.path);
      for (final point in _elements(document, 'navPoint')) {
        final source = _firstOrNull(_elements(point, 'content'));
        final href = source == null ? null : _attribute(source, 'src');
        final label = _firstOrNull(_elements(point, 'navLabel'));
        final title = label == null ? '' : label.innerText.trim();
        if (href == null || title.isEmpty) continue;
        result[_resolvePath(ncx.path, href)] = title;
      }
    }
    return result;
  }

  _EpubChapter? _readChapter(String path, String? navigationTitle) {
    final entry = _files[_normalizePath(path)];
    if (entry == null) return null;
    final source = utf8.decode(entry.content, allowMalformed: true);
    try {
      final document = XmlDocument.parse(source);
      final text = _htmlToReadableText(source);
      if (text.isEmpty) return null;
      final headingElement = _firstOrNull(_elements(document, 'h1'));
      final heading = headingElement?.innerText.trim();
      return _EpubChapter(
        title:
            navigationTitle ??
            (heading == null || heading.isEmpty ? _basename(path) : heading),
        text: text,
      );
    } on XmlParserException {
      final text = _htmlToReadableText(source);
      if (text.isEmpty) return null;
      return _EpubChapter(
        title: navigationTitle ?? _basename(path),
        text: text,
      );
    }
  }

  XmlDocument _xmlFile(String path) {
    final entry = _files[_normalizePath(path)];
    if (entry == null) {
      throw EpubDocumentException('Missing EPUB file: $path');
    }
    try {
      return XmlDocument.parse(
        utf8.decode(entry.content, allowMalformed: true),
      );
    } on XmlParserException catch (error) {
      throw EpubDocumentException('Invalid EPUB XML in $path: $error');
    }
  }

  List<XmlElement> _elements(XmlNode node, String localName) => node.descendants
      .whereType<XmlElement>()
      .where((element) => element.localName == localName)
      .toList(growable: false);

  XmlElement _firstElement(XmlNode node, String localName) {
    final element = _firstOrNull(_elements(node, localName));
    if (element == null) {
      throw EpubDocumentException('Missing EPUB element: $localName');
    }
    return element;
  }

  String? _firstText(XmlNode node, String localName) {
    for (final element in _elements(node, localName)) {
      final text = element.innerText.trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  T? _firstOrNull<T>(Iterable<T> values) {
    for (final value in values) {
      return value;
    }
    return null;
  }

  String? _attribute(XmlElement element, String localName) {
    for (final attribute in element.attributes) {
      if (attribute.localName == localName) return attribute.value;
    }
    return null;
  }

  String _resolvePath(String baseFile, String relative) {
    final path = Uri.decodeComponent(Uri.parse(relative).path);
    final base = baseFile.split('/')..removeLast();
    final parts = [...base, ...path.split('/')];
    final result = <String>[];
    for (final part in parts) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..' && result.isNotEmpty) {
        result.removeLast();
      } else if (part != '..') {
        result.add(part);
      }
    }
    return _normalizePath(result.join('/'));
  }

  String _normalizePath(String path) => path.replaceFirst(RegExp(r'^/+'), '');

  String _chapterAt(int offset) {
    for (var index = _chapters.length - 1; index >= 0; index--) {
      if (offset >= _chapters[index].offset) return _chapters[index].title;
    }
    return _title ?? _fileTitle;
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

  bool _isMarkup(String mediaType) =>
      mediaType == 'application/xhtml+xml' || mediaType == 'text/html';

  String get _fileTitle {
    final name = file.uri.pathSegments.isEmpty
        ? 'Untitled EPUB'
        : file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String _basename(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String _htmlToReadableText(String source) {
    return source
        .replaceAll(
          RegExp(r'<nav\b[^>]*>.*?</nav>', caseSensitive: false, dotAll: true),
          '',
        )
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</(p|div|li|h[1-6]|section|article)>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .trim();
  }

  int get _pageCount => text.isEmpty
      ? 1
      : (text.length + pageCharacterCount - 1) ~/ pageCharacterCount;

  void _ensureOpen() {
    if (_text == null) throw StateError('The EPUB is not open.');
  }
}

class _ManifestItem {
  const _ManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });

  const _ManifestItem.empty()
    : id = '',
      path = '',
      mediaType = '',
      properties = '';

  final String id;
  final String path;
  final String mediaType;
  final String properties;
}

class _EpubChapter {
  const _EpubChapter({
    required this.title,
    required this.text,
    this.offset = 0,
  });

  final String title;
  final String text;
  final int offset;

  _EpubChapter withOffset(int value) =>
      _EpubChapter(title: title, text: text, offset: value);
}

class EpubDocumentException implements Exception {
  const EpubDocumentException(this.message);

  final String message;

  @override
  String toString() => message;
}
