import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('Page 1 displays brand AppBar, headline, hero image, format pills, and indicators',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
      );

      // Verify AppBar
      expect(find.text('OpenPages'), findsOneWidget);
      expect(find.byIcon(Icons.local_library_outlined), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Verify Page 1 Content
      expect(find.text('Your books, all in one place'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_hero_image')), findsOneWidget);
      expect(
        find.text(
          'EPUB, PDF, TXT, Markdown, HTML and FB2. DRM-free and stored only on your phone.',
        ),
        findsOneWidget,
      );

      // Verify Format Pills
      expect(find.text('EPUB'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('TXT'), findsOneWidget);
      expect(find.text('MD'), findsOneWidget);
      expect(find.text('FB2'), findsOneWidget);

      // Verify Page Indicators (Dot 0 active 24x8, others 8x8)
      final dot0 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_0')));
      final dot1 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_1')));
      final dot2 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_2')));
      final dot3 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_3')));

      expect(dot0.size.width, 24);
      expect(dot0.size.height, 8);
      expect(dot1.size.width, 8);
      expect(dot1.size.height, 8);
      expect(dot2.size.width, 8);
      expect(dot3.size.width, 8);

      // Verify Next Button and Reassurance Note
      expect(find.byKey(const Key('next_page_button')), findsOneWidget);
      expect(find.text('Offline-first & zero telemetry'), findsOneWidget);

      // Verify strict architectural rule: NO bottom navigation bar
      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Tapping Next navigates from Page 1 to Page 2 with styles and feature pills',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
      );

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('Read the way you like'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page2_image')), findsOneWidget);
      expect(
        find.text(
          'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.',
        ),
        findsOneWidget,
      );

      // Verify Feature Pills
      expect(find.text('Custom Fonts'), findsOneWidget);
      expect(find.text('Margins & Spacing'), findsOneWidget);
      expect(find.text('Highlights & Notes'), findsOneWidget);

      // Dot 1 is active (24x8)
      final dot1 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_1')));
      expect(dot1.size.width, 24);
      expect(dot1.size.height, 8);

      // Reassurance Note
      expect(
        find.text('100% Offline • Zero telemetry & personal storage'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Next navigates to Page 3 with read-aloud features',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
      );

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page3_image')), findsOneWidget);
      expect(
        find.text(
          'Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked.',
        ),
        findsOneWidget,
      );

      // Feature pills
      expect(find.text('Natural Voices'), findsOneWidget);
      expect(find.text('Sentence Tracking'), findsOneWidget);
      expect(find.text('Sleep Timer'), findsOneWidget);

      // Dot 2 is active
      final dot2 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_2')));
      expect(dot2.size.width, 24);

      // Reassurance note
      expect(
        find.text('Offline-first & zero telemetry · Background audio session'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Next navigates to Page 4 with dual actions and privacy assurance',
        (tester) async {
      var importCalled = false;
      var exploreCalled = false;

      await tester.pumpHarness(
        OnboardingScreen(
          onImportFirstBook: () => importCalled = true,
          onExploreFirst: () => exploreCalled = true,
        ),
      );

      // Navigate to page 4
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page4_image')), findsOneWidget);
      expect(
        find.text(
          'No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup.',
        ),
        findsOneWidget,
      );

      // Feature pills
      expect(find.text('100% Offline Vault'), findsOneWidget);
      expect(find.text('Zero Telemetry'), findsOneWidget);
      expect(find.text('Offline Dictionary'), findsOneWidget);

      // Dual CTAs
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
      expect(find.text('Archived locally • Zero cloud sync required'), findsOneWidget);

      // Dot 3 is active
      final dot3 = tester.renderObject<RenderBox>(find.byKey(const Key('dot_indicator_3')));
      expect(dot3.size.width, 24);

      // Tap actions
      await tester.tap(find.byKey(const Key('import_first_book_button')));
      expect(importCalled, isTrue);

      await tester.tap(find.byKey(const Key('explore_first_button')));
      expect(exploreCalled, isTrue);
    });

    testWidgets('Tapping Skip from Page 1 navigates directly to Page 4',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
      );

      expect(find.text('Your books, all in one place'), findsOneWidget);

      // Tap Skip
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
    });

    testWidgets('Tapping indicator dot 2 jumps directly to Page 3',
        (tester) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
      );

      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();

      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page3_image')), findsOneWidget);
    });
  });
}
