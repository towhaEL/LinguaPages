import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/service/annotation_markdown_exporter.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';

enum AnnotationsStatus { loading, success, failure }

/// Notes are highlights that carry a written note.
enum AnnotationType { all, highlights, notes, bookmarks }

/// One highlight or bookmark with the book it belongs to.
class AnnotationItem {
  const AnnotationItem({required this.note, required this.book});

  final ReaderNote note;
  final BookEntity book;
}

class AnnotationsState {
  const AnnotationsState({
    this.status = AnnotationsStatus.loading,
    this.items = const [],
    this.type = AnnotationType.all,
    this.color,
    this.bookId,
    this.query = '',
  });

  final AnnotationsStatus status;

  /// Every annotation in the library, newest first.
  final List<AnnotationItem> items;
  final AnnotationType type;

  /// Only highlights in this colour; bookmarks have none and drop out.
  final HighlightColor? color;
  final String? bookId;
  final String query;

  /// The books that have annotations, by title.
  List<BookEntity> get books {
    final byId = {for (final item in items) item.book.id: item.book};
    return byId.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  List<AnnotationItem> get visible {
    final needle = query.trim().toLowerCase();
    return [
      for (final item in items)
        if (_matchesType(item) &&
            (color == null || item.note.highlight?.color == color) &&
            (bookId == null || item.book.id == bookId) &&
            (needle.isEmpty || _text(item).toLowerCase().contains(needle)))
          item,
    ];
  }

  /// [visible] as Markdown, one section per book in title order.
  String toMarkdown() {
    const exporter = AnnotationMarkdownExporter();
    final shown = visible;
    return [
      for (final book in books)
        if (shown.any((item) => item.book.id == book.id))
          exporter.export(
            bookTitle: book.title,
            highlights: [
              for (final item in shown)
                if (item.book.id == book.id) ?item.note.highlight,
            ],
            bookmarks: [
              for (final item in shown)
                if (item.book.id == book.id) ?item.note.bookmark,
            ],
          ),
    ].join('\n\n');
  }

  bool _matchesType(AnnotationItem item) {
    final highlight = item.note.highlight;
    return switch (type) {
      AnnotationType.all => true,
      AnnotationType.highlights => highlight != null,
      AnnotationType.notes => highlight?.note?.trim().isNotEmpty ?? false,
      AnnotationType.bookmarks => item.note.bookmark != null,
    };
  }

  /// What search looks through: quote, note, bookmark title and book.
  static String _text(AnnotationItem item) => [
    item.note.highlight?.selectedText,
    item.note.highlight?.note,
    item.note.bookmark?.title,
    item.book.title,
    item.book.author,
  ].whereType<String>().join('\n');

  AnnotationsState copyWith({
    AnnotationsStatus? status,
    List<AnnotationItem>? items,
    AnnotationType? type,
    HighlightColor? Function()? color,
    String? Function()? bookId,
    String? query,
  }) {
    return AnnotationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      type: type ?? this.type,
      color: color == null ? this.color : color(),
      bookId: bookId == null ? this.bookId : bookId(),
      query: query ?? this.query,
    );
  }
}
