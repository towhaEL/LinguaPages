import 'package:lingua_pages/data/document_engine/text/reflowable_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Plain text, shown as written.
class TxtDocumentEngine extends ReflowableTextDocumentEngine {
  TxtDocumentEngine(super.file);

  @override
  DocumentFormat get format => DocumentFormat.txt;

  @override
  ReflowableText parse(String source) =>
      ReflowableText(source.replaceAll('\r\n', '\n'), const []);
}
