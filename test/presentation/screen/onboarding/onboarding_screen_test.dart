import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../e2e/helpers/test_app_harness.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _MockRootStackRouter extends Mock implements RootStackRouter {}

void main() {
  group('OnboardingScreen Widget Tests', () {
    Future<void> goToPage(WidgetTester tester, int page) async {
      await tester.tap(find.byKey(Key('dot_indicator_$page')));
      await tester.pumpAndSettle();
    }

    double dotWidth(WidgetTester tester, int index) => tester
        .renderObject<RenderBox>(find.byKey(Key('dot_indicator_$index')))
        .size
        .width;

    testWidgets('page 1 shows the brand, library copy, formats and features', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      expect(find.text('OpenPages'), findsOneWidget);
      expect(find.byIcon(Icons.local_library_outlined), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      expect(find.text('1 of 3  ·  YOUR LIBRARY'), findsOneWidget);
      expect(find.text('Every book you own, on one shelf'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_hero_image')), findsOneWidget);
      for (final format in ['EPUB', 'PDF', 'TXT', 'MD', 'HTML', 'FB2']) {
        expect(find.text(format), findsOneWidget);
      }
      expect(find.text('Import from your files'), findsOneWidget);
      expect(find.text('Picks up where you left off'), findsOneWidget);

      expect(dotWidth(tester, 0), 24);
      expect(dotWidth(tester, 1), 8);
      expect(dotWidth(tester, 2), 8);
      expect(find.byKey(const Key('dot_indicator_3')), findsNothing);

      expect(find.byKey(const Key('next_page_button')), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsNothing);
      expect(find.byKey(const Key('onboarding_agreement')), findsNothing);

      tester.expectNoBottomNavigationBar();
    });

    testWidgets('Next leads to page 2: reading styles and read aloud', (
      tester,
    ) async {
      await tester.pumpHarness(const OnboardingScreen());

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('2 of 3  ·  READING'), findsOneWidget);
      expect(find.text('Read your way, or listen instead'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page2_image')), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_page2_audio_image')),
        findsOneWidget,
      );
      expect(find.text('Themes, fonts and spacing'), findsOneWidget);
      expect(find.text('Highlights, notes and word lookups'), findsOneWidget);
      expect(find.text('Read aloud with a sleep timer'), findsOneWidget);
      expect(dotWidth(tester, 1), 24);
    });

    testWidgets('the last page shows privacy, the agreement and both actions', (
      tester,
    ) async {
      var importCalled = false;
      var exploreCalled = false;
      await tester.pumpHarness(
        OnboardingScreen(
          onImportFirstBook: () => importCalled = true,
          onExploreFirst: () => exploreCalled = true,
        ),
      );

      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_page_button')));
      await tester.pumpAndSettle();

      expect(find.text('3 of 3  ·  PRIVACY'), findsOneWidget);
      expect(find.text('Your reading stays yours'), findsOneWidget);
      expect(find.byKey(const Key('onboarding_page3_image')), findsOneWidget);
      expect(find.text('Stored only on this device'), findsOneWidget);
      expect(find.text('No ads, analytics or tracking'), findsOneWidget);
      expect(find.text('Only looked-up words go online'), findsOneWidget);
      expect(dotWidth(tester, 2), 24);

      expect(find.byKey(const Key('next_page_button')), findsNothing);
      expect(
        find.textContaining(
          'By continuing, you agree to the Terms of Use and acknowledge the '
          'Privacy Policy.',
          findRichText: true,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('import_first_book_button')));
      expect(importCalled, isTrue);

      await tester.tap(find.byKey(const Key('explore_first_button')));
      expect(exploreCalled, isTrue);
    });

    testWidgets('Skip from page 1 jumps to the last page', (tester) async {
      await tester.pumpHarness(const OnboardingScreen());

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Your reading stays yours'), findsOneWidget);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
    });

    group('agreement links', () {
      late _MockStackRouter router;
      late _MockRootStackRouter root;

      setUpAll(() => registerFallbackValue(const TermsRoute()));

      setUp(() {
        router = _MockStackRouter();
        root = _MockRootStackRouter();
        when(() => router.root).thenReturn(root);
        when(() => root.push<Object?>(any())).thenAnswer((_) async => null);
      });

      Future<void> pumpLastPage(WidgetTester tester) async {
        await tester.pumpHarness(
          StackRouterScope(
            controller: router,
            stateHash: 0,
            child: const OnboardingScreen(),
          ),
        );
        await goToPage(tester, 2);
      }

      testWidgets('Terms of Use opens the terms screen', (tester) async {
        await pumpLastPage(tester);

        await tester.tapOnText(find.textRange.ofSubstring('Terms of Use'));
        await tester.pump();

        verify(() => root.push<Object?>(const TermsRoute())).called(1);
      });

      testWidgets('Privacy Policy opens the privacy screen', (tester) async {
        await pumpLastPage(tester);

        await tester.tapOnText(find.textRange.ofSubstring('Privacy Policy'));
        await tester.pump();

        verify(() => root.push<Object?>(const PrivacyRoute())).called(1);
      });
    });
  });
}
