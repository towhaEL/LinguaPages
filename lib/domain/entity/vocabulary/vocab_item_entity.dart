import 'package:lingua_pages/core/document/document_locator.dart';

/// A saved dictionary result and its surrounding reading context.
class VocabItemEntity {
  const VocabItemEntity({
    required this.id,
    required this.word,
    required this.lemma,
    required this.translation,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.sourceSentence = '',
    this.bookId,
    this.locator,
    this.notes,
  });

  final String id;
  final String word;
  final String lemma;
  final String sourceSentence;
  final String translation;
  final String? bookId;
  final DocumentLocator? locator;
  final String sourceLanguage;
  final String targetLanguage;
  final String? notes;
  final DateTime createdAt;
}
