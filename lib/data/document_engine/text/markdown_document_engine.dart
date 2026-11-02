import 'package:lingua_pages/data/document_engine/text/reflowable_text_document_engine.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Markdown read as prose: ATX headings become chapters and inline syntax
/// (emphasis, links, images, code marks) is removed. Code blocks stay as
/// written.
class MarkdownDocumentEngine extends ReflowableTextDocumentEngine {
  MarkdownDocumentEngine(super.file);

  static final _heading = RegExp(r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$');
  static final _fence = RegExp(r'^\s{0,3}(```|~~~)');
  static final _rule = RegExp(r'^\s{0,3}([-*_])(\s*\1){2,}\s*$');
  static final _quote = RegExp(r'^\s{0,3}>\s?');
  static final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
  static final _link = RegExp(r'\[([^\]]+)\]\([^)]*\)');
  static final _strong = RegExp(r'(\*\*|__)(?=\S)(.+?)(?<=\S)\1');
  static final _emphasis = RegExp(r'\*(?=\S)([^*]+?)(?<=\S)\*');
  static final _code = RegExp('`([^`]+)`');

  @override
  DocumentFormat get format => DocumentFormat.markdown;

  @override
  ReflowableText parse(String source) {
    final lines = <String>[];
    var inCode = false;
    for (final line in source.replaceAll('\r\n', '\n').split('\n')) {
      if (_fence.hasMatch(line)) {
        inCode = !inCode;
        continue;
      }
      if (inCode) {
        lines.add(line);
        continue;
      }
      final heading = _heading.firstMatch(line)?.group(1);
      if (heading != null) {
        lines.add(
          '${ReflowableText.headingStart}${_inline(heading)}'
          '${ReflowableText.headingEnd}',
        );
      } else if (_rule.hasMatch(line)) {
        lines.add('');
      } else {
        lines.add(_inline(line.replaceFirst(_quote, '')));
      }
    }
    return ReflowableText.fromMarked(tidyLines(lines.join('\n')));
  }

  String _inline(String line) => line
      .replaceAllMapped(_image, (m) => m.group(1)!)
      .replaceAllMapped(_link, (m) => m.group(1)!)
      .replaceAllMapped(_strong, (m) => m.group(2)!)
      .replaceAllMapped(_emphasis, (m) => m.group(1)!)
      .replaceAllMapped(_code, (m) => m.group(1)!);
}
