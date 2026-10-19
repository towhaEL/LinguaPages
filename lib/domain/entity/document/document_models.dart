import 'package:lingua_pages/core/document/document_locator.dart';

enum DocumentFormat { epub, pdf, txt, markdown, html, fb2 }

enum DocumentLayout { reflowable, fixed }

class DocumentInfo {
  const DocumentInfo({
    required this.title,
    required this.format,
    required this.layout,
    this.author,
    this.languageCode,
    this.coverPath,
    this.pageCount,
  });

  final String title;
  final DocumentFormat format;
  final DocumentLayout layout;
  final String? author;
  final String? languageCode;
  final String? coverPath;
  final int? pageCount;
}

class DocumentTocEntry {
  const DocumentTocEntry({required this.title, this.locator});

  final String title;
  final DocumentLocator? locator;
}

class DocumentTextSelection {
  const DocumentTextSelection({
    required this.text,
    required this.locator,
    this.sentence,
  });

  final String text;
  final DocumentLocator locator;
  final String? sentence;
}

class DocumentSearchResult {
  const DocumentSearchResult({
    required this.text,
    required this.locator,
    required this.chapterTitle,
  });

  final String text;
  final DocumentLocator locator;
  final String chapterTitle;
}
