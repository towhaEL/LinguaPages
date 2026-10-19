import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/document_engine.dart';

/// Creates the format-specific engine for a library book.
///
/// The presentation layer only knows this contract; plugin and file-format
/// choices stay in the data layer.
abstract interface class DocumentEngineFactory {
  DocumentEngine create(BookEntity book);
}
