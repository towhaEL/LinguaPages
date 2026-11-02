import 'dart:convert';

import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// A document as it appears in the user's library.
///
/// The entity intentionally stores only metadata and reading state. Format
/// adapters own parsing and rendering details through [DocumentEngine].
class BookEntity {
  const BookEntity({
    required this.id,
    required this.title,
    required this.format,
    required this.sourceUri,
    required this.sourceFileName,
    required this.contentFingerprint,
    required this.addedAt,
    this.author,
    this.coverPath,
    this.languageCode,
    this.tableOfContents = const [],
    this.fileSizeBytes,
    this.progress = 0,
    this.readingLocatorJson,
    this.lastReadAt,
    this.shelf,
    this.isFavorite = false,
    this.series,
    this.seriesIndex,
    this.deletedAt,
  }) : assert(progress >= 0 && progress <= 1);

  final String id;
  final String title;
  final String? author;
  final DocumentFormat format;
  final String sourceUri;
  final String sourceFileName;
  final String contentFingerprint;
  final String? coverPath;
  final String? languageCode;
  final List<String> tableOfContents;
  final int? fileSizeBytes;
  final double progress;
  final String? readingLocatorJson;
  final DateTime addedAt;
  final DateTime? lastReadAt;

  /// The shelf the user picked; null follows [progress] (see [readingShelf]).
  final BookShelf? shelf;
  final bool isFavorite;
  final String? series;
  final double? seriesIndex;

  /// Set while the book is in Trash.
  final DateTime? deletedAt;

  bool get isStarted => progress > 0;

  bool get isInTrash => deletedAt != null;

  /// The shelf the book sits on: the user's choice, else Finished at 100 %,
  /// Reading once started, and none before that.
  BookShelf? get readingShelf =>
      shelf ??
      (progress >= 1
          ? BookShelf.finished
          : progress > 0
          ? BookShelf.reading
          : null);

  /// The author field split into names ("A, B & C" holds three).
  List<String> get authors => [
    for (final name in (author ?? '').split(RegExp(r'\s*(?:[,;&]| and )\s*')))
      if (name.trim().isNotEmpty) name.trim(),
  ];

  /// The chapter title of the saved reading position, when the reader's
  /// locator carries one (Readium EPUB/PDF locators do).
  String? get currentChapterTitle {
    final json = readingLocatorJson;
    if (json == null || json.isEmpty) return null;
    try {
      final title = (jsonDecode(json) as Map<String, dynamic>)['title'];
      return title is String && title.trim().isNotEmpty ? title.trim() : null;
    } on Object {
      return null;
    }
  }

  BookEntity copyWith({
    String? title,
    String? author,
    DocumentFormat? format,
    String? sourceUri,
    String? sourceFileName,
    String? contentFingerprint,
    String? coverPath,
    String? languageCode,
    List<String>? tableOfContents,
    int? fileSizeBytes,
    double? progress,
    String? readingLocatorJson,
    DateTime? addedAt,
    DateTime? lastReadAt,
  }) {
    return BookEntity(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      sourceUri: sourceUri ?? this.sourceUri,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      contentFingerprint: contentFingerprint ?? this.contentFingerprint,
      coverPath: coverPath ?? this.coverPath,
      languageCode: languageCode ?? this.languageCode,
      tableOfContents: tableOfContents ?? this.tableOfContents,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      progress: progress ?? this.progress,
      readingLocatorJson: readingLocatorJson ?? this.readingLocatorJson,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

enum LibrarySort { recent, title, author, progress }

enum BookShelf { toRead, reading, finished }

/// Metadata the user can edit; null clears a field.
class BookDetails {
  const BookDetails({
    required this.title,
    this.author,
    this.series,
    this.seriesIndex,
    this.languageCode,
  });

  final String title;
  final String? author;
  final String? series;
  final double? seriesIndex;
  final String? languageCode;
}
