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

  bool get isStarted => progress > 0;

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
