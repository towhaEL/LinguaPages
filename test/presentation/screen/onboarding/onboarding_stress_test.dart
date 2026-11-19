import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';

import '../../../e2e/helpers/test_app_harness.dart';

const _page1 = 'Every book you own, on one shelf';
const _page2 = 'Read your way, or listen instead';
const _page3 = 'Your reading stays yours';

void main() {
  group('Onboarding stress & boundary tests', () {
    void verifyIndicatorDots(WidgetTester tester, int activeIndex) {
      for (var i = 0; i < 3; i++) {
        final dotFinder = find.byKey(Key('dot_indicator_$i'));
        expect(dotFinder, findsOneWidget);

        final renderBox = tester.renderObject<RenderBox>(dotFinder);
        final animatedContainer = tester.widget<AnimatedContainer>(dotFinder);
        final decoration = animatedContainer.decoration as BoxDecoration?;

        expect(decoration, isNotNull);
        expect(renderBox.size.height, 8, reason: 'Dot $i should be 8px tall');
        if (i == activeIndex) {
          expect(renderBox.size.width, 24, reason: 'Active dot $i is 24px');
          expect(decoration!.color, AppColors.accentInkBlueColor);
        } else {
          expect(renderBox.size.width, 8, reason: 'Inactive dot $i is 8px');
          expect(decoration!.color, AppColors.outlineVariantColor);
        }
      }
    }

    Future<void> swipe(WidgetTester tester, double dx) async {
      await tester.drag(find.byType(PageView), Offset(dx, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('1. Swiping forward and back across all three pages', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      verifyIndicatorDots(tester, 0);
      expect(find.text(_page1), findsOneWidget);

      await swipe(tester, -300);
      expect(find.text(_page2), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      await swipe(tester, -300);
      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      await swipe(tester, 300);
      expect(find.text(_page2), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      await swipe(tester, 300);
      expect(find.text(_page1), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      // Interrupted gestures: drag left, don't settle, drag right.
      await tester.drag(find.byType(PageView), const Offset(-200, 0));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.drag(find.byType(PageView), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Over-scrolling past the first and last page keeps bounds', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      for (var i = 0; i < 3; i++) {
        await tester.fling(find.byType(PageView), const Offset(600, 0), 3000);
        await tester.pumpAndSettle();
      }
      expect(find.text(_page1), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      for (var i = 0; i < 3; i++) {
        await tester.fling(find.byType(PageView), const Offset(-600, 0), 3000);
        await tester.pumpAndSettle();
      }
      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);
    });

    testWidgets('3A. Skip from page 1 jumps to the last page', (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text(_page3), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
      verifyIndicatorDots(tester, 2);
    });

    testWidgets('3B. Skip from page 2 jumps to the last page', (tester) async {
      await tester.pumpHarness(const OnboardingScreen());
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      expect(find.text(_page2), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);
    });

    testWidgets('3C. Skip is hidden and inert on the last page', (
      tester,
    ) async {
      var exploreTriggered = false;
      await tester.pumpHarness(
        OnboardingScreen(onExploreFirst: () => exploreTriggered = true),
      );
      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('onboarding_skip_button')).hitTestable(),
        findsNothing,
      );
      await tester.tap(find.text('Skip'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(exploreTriggered, isFalse);
      expect(find.text(_page3), findsOneWidget);
    });

    testWidgets('4. Dots animate on each page change', (tester) async {
      await tester.pumpHarness(const OnboardingScreen());
      verifyIndicatorDots(tester, 0);

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      verifyIndicatorDots(tester, 1);

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      verifyIndicatorDots(tester, 2);
    });

    testWidgets('5. Back returns to the previous page', (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      final back = find.byKey(const Key('previous_page_button'));
      expect(back.hitTestable(), findsNothing, reason: 'Hidden on page 1');

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(back);
      await tester.pumpAndSettle();

      expect(find.text(_page1), findsOneWidget);
      verifyIndicatorDots(tester, 0);
    });

    testWidgets('6. Tapping dots navigates to the respective page', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();
      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);

      await tester.tap(find.byKey(const Key('dot_indicator_1')));
      await tester.pumpAndSettle();
      expect(find.text(_page2), findsOneWidget);
      verifyIndicatorDots(tester, 1);

      await tester.tap(find.byKey(const Key('dot_indicator_0')));
      await tester.pumpAndSettle();
      expect(find.text(_page1), findsOneWidget);
      verifyIndicatorDots(tester, 0);
    });

    testWidgets('7. Rapid consecutive dot taps settle on the last one', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tap(find.byKey(const Key('dot_indicator_0')));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tap(find.byKey(const Key('dot_indicator_1')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(_page2), findsOneWidget);
      verifyIndicatorDots(tester, 1);
    });

    for (final size in const [Size(320, 640), Size(320, 480)]) {
      testWidgets('8. Swiping and dot taps at $size raise no errors', (
        tester,
      ) async {
        FlutterErrorDetails? errorDetails;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) => errorDetails = details;
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.pumpHarness(const OnboardingScreen(), viewport: size);

        for (var i = 0; i < 2; i++) {
          await swipe(tester, -250);
        }
        expect(find.text(_page3), findsOneWidget);
        verifyIndicatorDots(tester, 2);

        for (var i = 0; i < 2; i++) {
          await swipe(tester, 250);
        }
        expect(find.text(_page1), findsOneWidget);

        await tester.tap(find.byKey(const Key('dot_indicator_2')));
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(find.byKey(const Key('dot_indicator_0')));
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(find.byKey(const Key('dot_indicator_1')));
        await tester.pumpAndSettle();
        expect(find.text(_page2), findsOneWidget);

        FlutterError.onError = originalOnError;
        expect(errorDetails, isNull, reason: 'Layout error at $size');
      });
    }

    testWidgets('9. Aggressive flings at 320x480 stay within bounds', (
      tester,
    ) async {
      await tester.pumpHarness(
        const OnboardingScreen(),
        viewport: const Size(320, 480),
      );

      for (var i = 0; i < 5; i++) {
        await tester.fling(find.byType(PageView), const Offset(500, 0), 2000);
        await tester.pumpAndSettle();
      }
      expect(find.text(_page1), findsOneWidget);
      verifyIndicatorDots(tester, 0);

      await tester.tap(find.byKey(const Key('dot_indicator_2')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 5; i++) {
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 2000);
        await tester.pumpAndSettle();
      }
      expect(find.text(_page3), findsOneWidget);
      verifyIndicatorDots(tester, 2);
      expect(tester.takeException(), isNull);
    });
  });
}
