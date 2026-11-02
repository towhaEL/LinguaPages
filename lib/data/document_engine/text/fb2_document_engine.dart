import 'package:lingua_pages/data/document_engine/text/reflowable_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// FictionBook 2: section titles become chapters; the description block and
/// embedded base64 images are dropped.
class Fb2DocumentEngine extends ReflowableTextDocumentEngine {
  Fb2DocumentEngine(super.file);

  @override
  DocumentFormat get format => DocumentFormat.fb2;

  @override
  ReflowableText parse(String source) {
    final marked = source
        .replaceAll(_hidden, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'<title\b[^>]*>', caseSensitive: false),
          '\n${ReflowableText.headingStart}',
        )
        .replaceAll(
          RegExp(r'</title\s*>', caseSensitive: false),
          '${ReflowableText.headingEnd}\n',
        )
        .replaceAll(RegExp(r'<empty-line\s*/>', caseSensitive: false), '\n')
        .replaceAll(_blockEnd, '\n\n');
    return ReflowableText.fromMarked(
      tidyLines(decodeEntities(marked.replaceAll(RegExp('<[^>]*>'), ''))),
    );
  }

  static final _hidden = RegExp(
    r'<\?.*?\?>|<!--.*?-->|<(description|binary)\b[^>]*>.*?</\1\s*>',
    caseSensitive: false,
    dotAll: true,
  );

  static final _blockEnd = RegExp(
    r'</(p|v|subtitle|text-author|epigraph|cite|stanza|section)\s*>',
    caseSensitive: false,
  );
}
