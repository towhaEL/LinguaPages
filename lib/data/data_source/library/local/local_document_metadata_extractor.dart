import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/exceptions/document_import_exception.dart';
import 'package:lingua_pages/domain/service/document_metadata_extractor.dart';
import 'package:xml/xml.dart';

@LazySingleton(as: DocumentMetadataExtractor)
class LocalDocumentMetadataExtractor implements DocumentMetadataExtractor {
  @override
  Future<void> validate({
    required DocumentFormat format,
    required String fileName,
    String? path,
    Uint8List? bytes,
  }) async {
    final source = await _readBytes(path: path, bytes: bytes);
    if (source == null || source.isEmpty) {
      throw const DocumentImportException(
        kind: DocumentImportFailureKind.emptyFile,
        message: 'The selected file is empty.',
      );
    }

    switch (format) {
      case DocumentFormat.epub:
        _validateEpub(source);
      case DocumentFormat.pdf:
        _validatePdf(source);
      case DocumentFormat.fb2:
        _validateFb2(source);
      case DocumentFormat.txt:
      case DocumentFormat.markdown:
      case DocumentFormat.html:
        break;
    }
  }

  @override
  Future<DocumentMetadata> extract({
    required DocumentFormat format,
    required String fileName,
    String? path,
    Uint8List? bytes,
  }) async {
    final source = await _readBytes(path: path, bytes: bytes);
    if (source == null || source.isEmpty) return const DocumentMetadata();

    return switch (format) {
      DocumentFormat.epub => _extractEpub(source),
      DocumentFormat.pdf => _extractPdf(source),
      DocumentFormat.html || DocumentFormat.fb2 => _extractMarkup(source),
      DocumentFormat.markdown => _extractMarkdown(source),
      DocumentFormat.txt => const DocumentMetadata(),
    };
  }

  Future<Uint8List?> _readBytes({
    required String? path,
    required Uint8List? bytes,
  }) async {
    if (bytes != null) return bytes;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  DocumentMetadata _extractEpub(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final files = <String, ArchiveFile>{
        for (final entry in archive.files)
          if (entry.isFile) _normalizePath(entry.name): entry,
      };
      final container = _xmlFile(files, 'META-INF/container.xml');
      final rootFile = _firstElement(container, 'rootfile');
      final opfPath = _attribute(rootFile, 'full-path');
      if (opfPath == null || opfPath.isEmpty) {
        return const DocumentMetadata();
      }

      final opf = _xmlFile(files, opfPath);
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

      final cover = _findCover(opf, manifest, files);
      return DocumentMetadata(
        title: _firstText(opf, 'title'),
        author: _firstText(opf, 'creator'),
        languageCode: _firstText(opf, 'language'),
        coverBytes: cover?.bytes,
        coverFileName: cover?.fileName,
        tableOfContents: _extractEpubTableOfContents(
          opfPath: opfPath,
          manifest: manifest,
          files: files,
        ),
      );
    } on Object {
      // Metadata is optional. A malformed package must still be importable so
      // the document reader can report the actual format error later.
      return const DocumentMetadata();
    }
  }

  void _validateEpub(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final files = <String, ArchiveFile>{
        for (final entry in archive.files)
          if (entry.isFile) _normalizePath(entry.name): entry,
      };
      final container = _xmlFile(files, 'META-INF/container.xml');
      final rootFile = _firstElement(container, 'rootfile');
      final opfPath = _attribute(rootFile, 'full-path');
      if (opfPath == null || opfPath.isEmpty) {
        throw const FormatException('Missing EPUB package path.');
      }
      _xmlFile(files, opfPath);
    } on DocumentImportException {
      rethrow;
    } on Object catch (error) {
      throw CorruptDocumentException('This EPUB file is corrupt: $error');
    }
  }

  void _validatePdf(Uint8List bytes) {
    final source = latin1.decode(bytes, allowInvalid: true);
    if (!source.startsWith('%PDF-') || !source.contains('%%EOF')) {
      throw const CorruptDocumentException(
        'This PDF file appears to be incomplete or corrupt.',
      );
    }
  }

  void _validateFb2(Uint8List bytes) {
    try {
      final document = XmlDocument.parse(
        utf8.decode(bytes, allowMalformed: false),
      );
      if (!_elements(document, 'FictionBook').isNotEmpty &&
          !_elements(document, 'FictionBook'.toLowerCase()).isNotEmpty) {
        throw const FormatException('Missing FictionBook root element.');
      }
    } on DocumentImportException {
      rethrow;
    } on Object catch (error) {
      throw CorruptDocumentException('This FB2 file is corrupt: $error');
    }
  }

  _CoverData? _findCover(
    XmlDocument opf,
    Map<String, _ManifestItem> manifest,
    Map<String, ArchiveFile> files,
  ) {
    String? coverId;
    for (final meta in _elements(opf, 'meta')) {
      final name = _attribute(meta, 'name')?.toLowerCase();
      if (name == 'cover') {
        coverId = _attribute(meta, 'content');
        break;
      }
    }

    _ManifestItem? cover;
    if (coverId != null) cover = manifest[coverId];
    cover ??= manifest.values.firstWhereOrNull(
      (item) => item.properties.split(RegExp(r'\s+')).contains('cover-image'),
    );
    cover ??= manifest.values.firstWhereOrNull(
      (item) =>
          _isImage(item.mediaType) && item.path.toLowerCase().contains('cover'),
    );
    if (cover == null) return null;

    final entry = files[_normalizePath(cover.path)];
    if (entry == null) return null;
    return _CoverData(
      bytes: Uint8List.fromList(entry.content),
      fileName: _coverFileName(cover.path, cover.mediaType),
    );
  }

  DocumentMetadata _extractMarkup(Uint8List bytes) {
    final source = utf8.decode(bytes, allowMalformed: true);
    try {
      final document = XmlDocument.parse(source);
      return DocumentMetadata(
        title: _firstText(document, 'title'),
        author: _firstMarkupAuthor(document),
        languageCode: _firstLanguage(document),
        tableOfContents: _extractMarkupTableOfContents(document),
      );
    } on XmlParserException {
      final title = _firstRegexValue(
        source,
        RegExp(
          r'<title[^>]*>(.*?)</title>',
          caseSensitive: false,
          dotAll: true,
        ),
      );
      return DocumentMetadata(
        title: title,
        tableOfContents: _extractRegexHeadings(source),
      );
    }
  }

  DocumentMetadata _extractMarkdown(Uint8List bytes) {
    final source = utf8.decode(bytes, allowMalformed: true);
    final tableOfContents = source
        .split('\n')
        .map(
          (line) => RegExp(
            r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$',
          ).firstMatch(line)?.group(1),
        )
        .map(_cleanText)
        .whereType<String>()
        .toList(growable: false);
    return DocumentMetadata(
      title: tableOfContents.isEmpty ? null : tableOfContents.first,
      tableOfContents: tableOfContents,
    );
  }

  List<String> _extractEpubTableOfContents({
    required String opfPath,
    required Map<String, _ManifestItem> manifest,
    required Map<String, ArchiveFile> files,
  }) {
    final titles = <String>[];

    void addTitle(String value) {
      final title = _cleanText(value);
      if (title != null && !titles.contains(title)) titles.add(title);
    }

    final nav = manifest.values.firstWhereOrNull(
      (item) => item.properties.split(RegExp(r'\s+')).contains('nav'),
    );
    if (nav != null) {
      final document = _xmlFile(files, nav.path);
      final tocNavs = _elements(document, 'nav').where((element) {
        final type = _attribute(element, 'type') ?? '';
        return type
            .split(RegExp(r'\s+'))
            .map((value) => value.toLowerCase())
            .contains('toc');
      });
      final anchors = tocNavs.isEmpty
          ? _elements(document, 'a')
          : tocNavs.expand((element) => _elements(element, 'a'));
      for (final anchor in anchors) {
        addTitle(anchor.innerText);
      }
      if (titles.isNotEmpty) return titles;
    }

    final ncx = manifest.values.firstWhereOrNull(
      (item) => item.mediaType == 'application/x-dtbncx+xml',
    );
    if (ncx != null) {
      final document = _xmlFile(files, ncx.path);
      for (final point in _elements(document, 'navPoint')) {
        final label = _firstOrNull(_elements(point, 'navLabel'));
        if (label != null) addTitle(label.innerText);
      }
      if (titles.isNotEmpty) return titles;
    }

    final spine = _firstOrNull(_elements(_xmlFile(files, opfPath), 'spine'));
    if (spine != null) {
      for (final itemRef in _elements(spine, 'itemref')) {
        final idRef = _attribute(itemRef, 'idref');
        final item = idRef == null ? null : manifest[idRef];
        if (item == null || !_isMarkup(item.mediaType)) continue;
        final chapter = files[_normalizePath(item.path)];
        if (chapter == null) continue;
        final source = utf8.decode(chapter.content, allowMalformed: true);
        try {
          final document = XmlDocument.parse(source);
          for (final heading in _elements(document, 'h1')) {
            addTitle(heading.innerText);
          }
          if (titles.isEmpty) {
            for (final heading in _elements(document, 'h2')) {
              addTitle(heading.innerText);
            }
          }
        } on XmlParserException {
          for (final title in _extractRegexHeadings(source)) {
            addTitle(title);
          }
        }
      }
    }
    return titles;
  }

  List<String> _extractMarkupTableOfContents(XmlDocument document) {
    final titles = <String>[];
    for (final element in document.descendants.whereType<XmlElement>()) {
      final localName = element.localName.toLowerCase();
      final isHeading = RegExp(r'^h[1-6]$').hasMatch(localName);
      final isFb2SectionTitle =
          localName == 'title' &&
          element.ancestors.whereType<XmlElement>().any(
            (ancestor) => ancestor.localName.toLowerCase() == 'section',
          );
      if (!isHeading && !isFb2SectionTitle) continue;
      final title = _cleanText(element.innerText);
      if (title != null && !titles.contains(title)) titles.add(title);
    }
    return titles;
  }

  List<String> _extractRegexHeadings(String source) {
    final titles = <String>[];
    final pattern = RegExp(
      r'<h[1-6][^>]*>(.*?)</h[1-6]>',
      caseSensitive: false,
      dotAll: true,
    );
    for (final match in pattern.allMatches(source)) {
      final title = _cleanText(
        match.group(1)?.replaceAll(RegExp(r'<[^>]+>'), ''),
      );
      if (title != null && !titles.contains(title)) titles.add(title);
    }
    return titles;
  }

  DocumentMetadata _extractPdf(Uint8List bytes) {
    final source = latin1.decode(bytes, allowInvalid: true);
    return DocumentMetadata(
      title: _pdfInfoValue(source, 'Title') ?? _xmpValue(source, 'title'),
      author: _pdfInfoValue(source, 'Author') ?? _xmpValue(source, 'creator'),
      languageCode:
          _pdfInfoValue(source, 'Lang') ?? _xmpValue(source, 'language'),
    );
  }

  String? _pdfInfoValue(String source, String key) {
    final match = RegExp(
      '/$key\\s*\\((.*?)\\)',
      dotAll: true,
    ).firstMatch(source);
    if (match == null) return null;
    return _cleanPdfString(match.group(1));
  }

  String? _xmpValue(String source, String localName) {
    final match = RegExp(
      '<(?:[A-Za-z_][\\w.-]*:)?$localName[^>]*>(.*?)</(?:[A-Za-z_][\\w.-]*:)?$localName>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(source);
    return match == null ? null : _cleanText(match.group(1));
  }

  String? _cleanPdfString(String? value) {
    if (value == null) return null;
    return _cleanText(
      value
          .replaceAll(r'\(', '(')
          .replaceAll(r'\)', ')')
          .replaceAll(r'\\', '\\')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\r', '\r'),
    );
  }

  String? _firstMarkupAuthor(XmlDocument document) {
    for (final meta in _elements(document, 'meta')) {
      final name = _attribute(meta, 'name')?.toLowerCase();
      if (name == 'author' || name == 'creator') {
        return _cleanText(_attribute(meta, 'content')) ??
            _cleanText(meta.innerText);
      }
    }
    return _firstText(document, 'author') ?? _firstText(document, 'creator');
  }

  String? _firstLanguage(XmlDocument document) {
    for (final element in document.descendants.whereType<XmlElement>()) {
      final language = _attribute(element, 'lang');
      if (language != null && language.trim().isNotEmpty) {
        return language.trim();
      }
    }
    return null;
  }

  String? _firstRegexValue(String source, RegExp pattern) {
    final match = pattern.firstMatch(source);
    return match == null ? null : _cleanText(match.group(1));
  }

  XmlDocument _xmlFile(Map<String, ArchiveFile> files, String path) {
    final entry = files[_normalizePath(path)];
    if (entry == null) throw StateError('Missing package file: $path');
    return XmlDocument.parse(utf8.decode(entry.content, allowMalformed: true));
  }

  List<XmlElement> _elements(XmlNode node, String localName) => node.descendants
      .whereType<XmlElement>()
      .where((element) => element.localName == localName)
      .toList(growable: false);

  XmlElement _firstElement(XmlNode node, String localName) {
    for (final element in _elements(node, localName)) {
      return element;
    }
    throw StateError('Missing element: $localName');
  }

  T? _firstOrNull<T>(Iterable<T> values) {
    final iterator = values.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }

  String? _firstText(XmlNode node, String localName) {
    for (final element in _elements(node, localName)) {
      final value = _cleanText(element.innerText);
      if (value != null) return value;
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
    return result.join('/');
  }

  String _normalizePath(String path) =>
      path.replaceAll('\\', '/').replaceFirst(RegExp(r'^\./'), '');

  bool _isImage(String mediaType) =>
      mediaType.toLowerCase().startsWith('image/');

  bool _isMarkup(String mediaType) {
    final normalized = mediaType.toLowerCase();
    return normalized.contains('html') || normalized.contains('xml');
  }

  String _coverFileName(String path, String mediaType) {
    final extension = path.contains('.')
        ? path.split('.').last.toLowerCase()
        : '';
    if (extension.isNotEmpty && extension.length <= 5) {
      return 'cover.$extension';
    }
    final fallback = switch (mediaType.toLowerCase()) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/gif' => 'gif',
      _ => 'bin',
    };
    return 'cover.$fallback';
  }

  String? _cleanText(String? value) {
    final cleaned = value?.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }
}

class _ManifestItem {
  const _ManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });

  final String id;
  final String path;
  final String mediaType;
  final String properties;
}

class _CoverData {
  const _CoverData({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

extension on Iterable<_ManifestItem> {
  _ManifestItem? firstWhereOrNull(bool Function(_ManifestItem item) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}
