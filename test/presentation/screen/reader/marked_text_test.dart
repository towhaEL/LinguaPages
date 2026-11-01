import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/marked_text.dart';

void main() {
  const page = 'Call me Ishmael. Some years ago, never mind how long.';

  List<(String, Color?)> runs(TextSpan span) => [
    for (final child in span.children ?? [span])
      ((child as TextSpan).text!, child.style?.backgroundColor),
  ];

  test('a page without highlights is one plain run', () {
    expect(runs(markedText(page, const [], darkPage: false)), [(page, null)]);
  });

  test('finds trimmed selections after their recorded start', () {
    // The selection began on the space before "Ishmael" and was trimmed.
    final span = markedText(page, const [
      PageMark(start: 7, text: 'Ishmael', color: HighlightColor.green),
    ], darkPage: false);

    final green = Color(HighlightColor.green.tintArgb(darkPage: false));
    expect(runs(span), [
      ('Call me ', null),
      ('Ishmael', green),
      ('. Some years ago, never mind how long.', null),
    ]);
  });

  test('uses deep tints on dark pages', () {
    final span = markedText(page, const [
      PageMark(start: 0, text: 'Call', color: HighlightColor.yellow),
    ], darkPage: true);

    expect(
      runs(span).first.$2,
      Color(HighlightColor.yellow.tintArgb(darkPage: true)),
    );
  });

  test('overlaps keep the earlier highlight and skip missing text', () {
    final span = markedText(page, const [
      PageMark(start: 8, text: 'Ishmael. Some', color: HighlightColor.blue),
      PageMark(start: 0, text: 'me Ishmael', color: HighlightColor.pink),
      PageMark(start: 0, text: 'not on this page', color: HighlightColor.blue),
    ], darkPage: false);

    expect(runs(span).map((run) => run.$1).join(), page);
    expect(runs(span)[1], (
      'me Ishmael',
      Color(HighlightColor.pink.tintArgb(darkPage: false)),
    ));
    expect(runs(span)[2].$1, '. Some');
  });
}
