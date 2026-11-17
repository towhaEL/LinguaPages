import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_search.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('ReaderSearchSheet Widget Tests', () {
    testWidgets('executes search callback and renders hits', (tester) async {
      var selected = false;
      final hits = [
        ReaderSearchHit(
          title: 'Chapter 1: The Arrival',
          snippet: 'The harbour was quiet at dawn.',
          onSelected: () async => selected = true,
          chapter: 'Chapter 1',
        ),
      ];

      await tester.pumpHarness(
        ReaderSearchSheet(search: (query) async => hits),
      );

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'harbour');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('1 result'), findsOneWidget);
      expect(find.text('Chapter 1: The Arrival'), findsOneWidget);

      await tester.tap(find.text('Chapter 1: The Arrival'));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
    });

    testWidgets('marks every match in the snippet', (tester) async {
      await tester.pumpHarness(
        ReaderSearchSheet(
          query: 'harbour',
          search: (query) async => [
            ReaderSearchHit(
              title: 'Chapter 2',
              snippet: 'Harbour lights over the harbour wall.',
              onSelected: () async {},
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final rich = tester.widget<RichText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('lights over'),
        ),
      );
      final marked = <String>[];
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.style?.backgroundColor != null) {
          marked.add(span.text!);
        }
        return true;
      });
      expect(marked, ['Harbour', 'harbour']);
    });

    testWidgets('reopening with the last query shows its results and the '
        'chosen hit', (tester) async {
      String? reportedQuery;
      int? reportedIndex;
      await tester.pumpHarness(
        ReaderSearchSheet(
          query: 'tide',
          selectedIndex: 1,
          onSelected: (query, index) {
            reportedQuery = query;
            reportedIndex = index;
          },
          search: (query) async => [
            for (final n in [1, 2, 3])
              ReaderSearchHit(
                title: 'Chapter $n',
                snippet: 'The tide turned in chapter $n.',
                onSelected: () async {},
              ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 results'), findsOneWidget);
      await tester.tap(find.text('Chapter 3'));
      await tester.pumpAndSettle();
      expect(reportedQuery, 'tide');
      expect(reportedIndex, 2);
    });

    testWidgets('the way back is only offered after a jump', (tester) async {
      await tester.pumpHarness(const ReaderSearchSheet());
      expect(find.byKey(const Key('search_return_to_position')), findsNothing);

      var returned = false;
      await tester.pumpHarness(
        ReaderSearchSheet(
          returnLabel: 'page 12',
          onReturnToPosition: () => returned = true,
        ),
      );
      expect(find.text('Back to page 12'), findsOneWidget);
      await tester.tap(find.byKey(const Key('search_return_to_position')));
      await tester.pumpAndSettle();
      expect(returned, isTrue);
    });
  });
}
