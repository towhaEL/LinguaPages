import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_search.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('ReaderSearchSheet Widget Tests', () {
    testWidgets('renders search query, match badge, and stepper buttons', (tester) async {
      var nextTapped = false;
      var prevTapped = false;

      await tester.pumpHarness(
        ReaderSearchSheet(
          query: 'harbour',
          matchCount: 15,
          currentMatchIndex: 3,
          onNextMatch: () => nextTapped = true,
          onPrevMatch: () => prevTapped = true,
        ),
      );

      expect(find.byKey(const Key('search_match_counter_badge')), findsOneWidget);
      expect(find.text('15 results'), findsOneWidget);
      expect(find.text('Match 3 of 15 in current chapter'), findsOneWidget);

      await tester.tap(find.byKey(const Key('search_next_match')));
      await tester.pumpAndSettle();
      expect(nextTapped, isTrue);

      await tester.tap(find.byKey(const Key('search_prev_match')));
      await tester.pumpAndSettle();
      expect(prevTapped, isTrue);
    });

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
        ReaderSearchSheet(
          search: (query) async => hits,
        ),
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
  });
}
