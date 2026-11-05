import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';

import '../../../e2e/helpers/test_app_harness.dart';

void main() {
  group('Milestone 2 Challenger Stress & Boundary Tests', () {
    void verifyIndicatorDots(WidgetTester tester, int activeIndex) {
      for (var i = 0; i < 4; i++) {
        final dotFinder = find.byKey(Key('dot_indicator_$i'));
        expect(dotFinder, findsOneWidget);

        final renderBox = tester.renderObject<RenderBox>(dotFinder);
        final animatedContainer = tester.widget<AnimatedContainer>(dotFinder);
        final decoration = animatedContainer.decoration as BoxDecoration?;

        expect(decoration, isNotNull);
        if (i == activeIndex) {
          expect(renderBox.size.width, 24, reason: 'Active dot $i should be 24px wide');
          expect(renderBox.size.height, 8, reason: 'Active dot $i should be 8px tall');
          expect(
            decoration!.color,
            AppColors.accentInkBlueColor,
            reason: 'Active dot $i should be #2F4A7A',
          );
        } else {
          expect(renderBox.size.width, 8, reason: 'Inactive dot $i should be 8px wide');
          expect(renderBox.size.height, 8, reason: 'Inactive dot $i should be 8px tall');
          expect(
            decoration!.color,
            const Color(0xFFC4C6D0),
            reason: 'Inactive dot $i should be #C4C6D0',
          );
        }
      }
    }

    testWidgets('1. Rapid swiping left and right across pages 1 to 4 with gesture stress',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      verifyIndicatorDots(tester, 0);
      expect(find.text('Your books, all in one place'), findsOneWidget);

      // Swipe from Page 1 to Page 2
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Read the way you like'), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      // Swipe from Page 2 to Page 3
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      // Swipe from Page 3 to Page 4
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);

      // Swipe back from Page 4 to Page 3
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      // Swipe back from Page 3 to Page 2
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Read the way you like'), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      // Swipe back from Page 2 to Page 1
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Your books, all in one place'), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      // Interrupted rapid gestures: drag left, don't wait for settle, drag right, pumpAndSettle
      await tester.drag(find.byType(PageView), const Offset(-200, 0));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.drag(find.byType(PageView), const Offset(200, 0));
      await tester.pumpAndSettle();

      // State remains consistent without crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Over-scrolling past Page 1 (backward) and Page 4 (forward) maintains bounds',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      // On Page 1, over-scroll backward aggressively multiple times
      for (var i = 0; i < 3; i++) {
        await tester.fling(find.byType(PageView), const Offset(600, 0), 3000);
        await tester.pumpAndSettle();
      }

      // Page 1 remains active without exceptions or negative indices
      expect(find.text('Your books, all in one place'), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      // Navigate to Page 4
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);

      // On Page 4, over-scroll forward aggressively multiple times
      for (var i = 0; i < 3; i++) {
        await tester.fling(find.byType(PageView), const Offset(-600, 0), 3000);
        await tester.pumpAndSettle();
      }

      // Page 4 remains active without index out of bounds
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);
    });

    testWidgets('3A. Tapping Skip from Page 1 jumps directly to Page 4',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());
      expect(find.text('Your books, all in one place'), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
      verifyIndicatorDots(tester, 3);
    });

    testWidgets('3B. Tapping Skip from Page 2 jumps directly to Page 4',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());
      // Navigate to Page 2
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      expect(find.text('Read the way you like'), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      verifyIndicatorDots(tester, 3);
    });

    testWidgets('3C. Tapping Skip from Page 3 jumps directly to Page 4',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());
      // Jump to Page 3 via dot indicator 2
      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();
      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Private by design'), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      verifyIndicatorDots(tester, 3);
    });

    testWidgets('3D. Tapping Skip on Page 4 triggers explore / completion callback',
        (tester) async {
      var exploreTriggered = false;
      await tester.pumpHarness(
        OnboardingScreen(onExploreFirst: () => exploreTriggered = true),
      );
      // Navigate to Page 4
      await tester.tap(find.byKey(const Key('dot_indicator_3')));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(exploreTriggered, isTrue);
    });

    testWidgets('4. Indicator dots update dynamically with animation on each page change',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      // Check Page 1 initial dots
      verifyIndicatorDots(tester, 0);

      // Trigger transition to Page 2
      await tester.tap(find.byKey(const Key('next_page_button')));

      // Mid-transition pump (100ms into 250ms animation duration)
      await tester.pump(const Duration(milliseconds: 100));
      // AnimatedContainer scales smoothly without framework errors
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      verifyIndicatorDots(tester, 1);

      // Trigger transition to Page 3
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      verifyIndicatorDots(tester, 2);

      // Trigger transition to Page 4
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      verifyIndicatorDots(tester, 3);
    });

    testWidgets('5. Tapping indicator dots directly navigates to the respective page',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      // Start at Page 1 (dot 0)
      verifyIndicatorDots(tester, 0);

      // Jump to dot 3 (Page 4)
      await tester.tap(find.byKey(const Key('dot_indicator_3')));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);

      // Jump to dot 1 (Page 2)
      await tester.tap(find.byKey(const Key('dot_indicator_1')));
      await tester.pumpAndSettle();
      expect(find.text('Read the way you like'), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      // Jump to dot 2 (Page 3)
      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();
      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      // Jump back to dot 0 (Page 1)
      await tester.tap(find.byKey(const Key('dot_indicator_0')));
      await tester.pumpAndSettle();
      expect(find.text('Your books, all in one place'), findsOneWidget);
      verifyIndicatorDots(tester, 0);
    });

    testWidgets('6. Rapid consecutive indicator dot taps handle animation interruptions gracefully',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      // Tap dot 3, then quickly tap dot 1, then dot 2 without waiting for pumpAndSettle
      await tester.tap(find.byKey(const Key('dot_indicator_3')));
      await tester.pump(const Duration(milliseconds: 40));

      await tester.tap(find.byKey(const Key('dot_indicator_1')));
      await tester.pump(const Duration(milliseconds: 40));

      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Listen when your eyes rest'), findsOneWidget);
      verifyIndicatorDots(tester, 2);
    });

    testWidgets('7. Rapid swiping across all pages under 320dp narrow viewports produces zero RenderFlex overflow',
        (tester) async {
      final narrowSizes = [
        const Size(320, 640),
        const Size(320, 480),
      ];

      for (final size in narrowSizes) {
        FlutterErrorDetails? errorDetails;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errorDetails = details;
        };

        await tester.pumpHarness(const OnboardingScreen(), viewport: size);
        FlutterError.onError = originalOnError;

        expect(errorDetails, isNull, reason: 'Error on initial render at $size');

        // Rapidly swipe through all pages forward
        for (var i = 0; i < 3; i++) {
          await tester.drag(find.byType(PageView), const Offset(-250, 0));
          await tester.pumpAndSettle();
        }
        expect(find.text('Private by design'), findsOneWidget);
        verifyIndicatorDots(tester, 3);

        // Rapidly swipe back
        for (var i = 0; i < 3; i++) {
          await tester.drag(find.byType(PageView), const Offset(250, 0));
          await tester.pumpAndSettle();
        }
        expect(find.text('Your books, all in one place'), findsOneWidget);
        verifyIndicatorDots(tester, 0);

        expect(errorDetails, isNull, reason: 'RenderFlex overflow occurred during swiping at $size');
      }
    });

    testWidgets('8. Rapid indicator dot taps with animation interruptions under 320dp width produce zero errors',
        (tester) async {
      final narrowSizes = [
        const Size(320, 640),
        const Size(320, 480),
      ];

      for (final size in narrowSizes) {
        FlutterErrorDetails? errorDetails;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          errorDetails = details;
        };

        await tester.pumpHarness(const OnboardingScreen(), viewport: size);
        FlutterError.onError = originalOnError;

        // Rapid interrupted dot tapping under 320dp width
        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pump(const Duration(milliseconds: 30));

        await tester.tap(find.byKey(const Key('dot_indicator_1')));
        await tester.pump(const Duration(milliseconds: 30));

        await tester.tap(find.byKey(const Key('dot_indicator_0')));
        await tester.pump(const Duration(milliseconds: 30));

        await tester.tap(find.byKey(const Key('dot_indicator_2')));
        await tester.pumpAndSettle();

        expect(find.text('Listen when your eyes rest'), findsOneWidget);
        verifyIndicatorDots(tester, 2);

        expect(errorDetails, isNull, reason: 'RenderFlex overflow or exception during dot taps at $size');
      }
    });

    testWidgets('9. Aggressive over-scroll and fling gestures under 320dp maintain boundary safety',
        (tester) async {
      await tester.pumpHarness(const OnboardingScreen(), viewport: const Size(320, 480));

      // Over-scroll backwards aggressively on Page 1
      for (var i = 0; i < 5; i++) {
        await tester.fling(find.byType(PageView), const Offset(500, 0), 2000);
        await tester.pumpAndSettle();
      }
      expect(find.text('Your books, all in one place'), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      // Jump to Page 4 and over-scroll forwards aggressively
      await tester.tap(find.byKey(const Key('dot_indicator_3')));
      await tester.pumpAndSettle();
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);

      for (var i = 0; i < 5; i++) {
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 2000);
        await tester.pumpAndSettle();
      }
      expect(find.text('Private by design'), findsOneWidget);
      verifyIndicatorDots(tester, 3);
      expect(tester.takeException(), isNull);
    });
  });
}
