import 'package:lingua_pages/core/document/document_locator.dart';

/// A user-selected piece of text in a book.
class HighlightEntity {
  const HighlightEntity({
    required this.id,
    required this.bookId,
    required this.selectedText,
    required this.locator,
    required this.color,
    required this.createdAt,
    this.note,
    this.updatedAt,
  });

  final String id;
  final String bookId;
  final String selectedText;
  final DocumentLocator locator;
  final HighlightColor color;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HighlightEntity copyWith({
    String? selectedText,
    DocumentLocator? locator,
    HighlightColor? color,
    String? note,
    DateTime? updatedAt,
  }) {
    return HighlightEntity(
      id: id,
      bookId: bookId,
      selectedText: selectedText ?? this.selectedText,
      locator: locator ?? this.locator,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum HighlightColor { yellow, green, blue, pink }
