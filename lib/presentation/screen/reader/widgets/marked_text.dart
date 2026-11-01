import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';

/// A highlight on one fallback text page.
class PageMark {
  const PageMark({
    required this.start,
    required this.text,
    required this.color,
  });

  /// Where the selection began on the page. The saved text was trimmed, so
  /// it is searched for from here.
  final int start;
  final String text;
  final HighlightColor color;
}

/// [text] with each mark drawn behind its words. Marks whose text is no
/// longer on the page (for example after a re-pagination) are skipped.
TextSpan markedText(
  String text,
  List<PageMark> marks, {
  required bool darkPage,
}) {
  final ranges = <(int, int, HighlightColor)>[];
  for (final mark in marks) {
    if (mark.text.isEmpty || mark.start > text.length) continue;
    final start = text.indexOf(mark.text, math.max(0, mark.start));
    if (start < 0) continue;
    ranges.add((start, start + mark.text.length, mark.color));
  }
  if (ranges.isEmpty) return TextSpan(text: text);
  ranges.sort((a, b) => a.$1.compareTo(b.$1));

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final (start, end, color) in ranges) {
    // Overlapping highlights: the earlier one wins the shared characters.
    if (end <= cursor) continue;
    final from = math.max(start, cursor);
    if (from > cursor) spans.add(TextSpan(text: text.substring(cursor, from)));
    spans.add(
      TextSpan(
        text: text.substring(from, end),
        style: TextStyle(
          backgroundColor: Color(color.tintArgb(darkPage: darkPage)),
        ),
      ),
    );
    cursor = end;
  }
  if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
  return TextSpan(children: spans);
}
