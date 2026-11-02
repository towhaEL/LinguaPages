import 'package:lingua_pages/data/document_engine/text/reflowable_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// HTML read as prose: `h1`–`h6` become chapters; head, script, style and
/// comments are dropped; block ends become line breaks.
class HtmlDocumentEngine extends ReflowableTextDocumentEngine {
  HtmlDocumentEngine(super.file);

  @override
  DocumentFormat get format => DocumentFormat.html;

  @override
  ReflowableText parse(String source) {
    final marked = source
        .replaceAll(_hidden, '')
        // Source whitespace is insignificant; line breaks come from markup.
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'<h[1-6]\b[^>]*>', caseSensitive: false),
          '\n${ReflowableText.headingStart}',
        )
        .replaceAll(
          RegExp(r'</h[1-6]\s*>', caseSensitive: false),
          '${ReflowableText.headingEnd}\n',
        )
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(_blockEnd, '\n\n');
    return ReflowableText.fromMarked(
      tidyLines(decodeEntities(marked.replaceAll(RegExp('<[^>]*>'), ''))),
    );
  }

  static final _hidden = RegExp(
    r'<!--.*?-->|<(head|script|style|template)\b[^>]*>.*?</\1\s*>',
    caseSensitive: false,
    dotAll: true,
  );

  static final _blockEnd = RegExp(
    r'</(p|div|li|tr|blockquote|section|article|ul|ol|table|pre)\s*>',
    caseSensitive: false,
  );
}
