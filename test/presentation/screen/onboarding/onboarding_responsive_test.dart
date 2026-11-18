import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../e2e/helpers/test_app_harness.dart';

class _MockOnboardingPreferences extends Mock
    implements OnboardingPreferences {}

void main() {
  const viewports = {
    'phone portrait': Size(402, 874),
    'phone landscape': Size(874, 402),
    'wide phone landscape': Size(915, 412),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
  };

  for (final MapEntry(key: name, value: viewport) in viewports.entries) {
    testWidgets('every page fits without overflow in $name', (tester) async {
      await tester.pumpHarness(const OnboardingScreen(), viewport: viewport);

      for (var page = 0; page < 3; page++) {
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('next_page_button')));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
      expect(find.byKey(const Key('explore_first_button')), findsOneWidget);
    });
  }

  testWidgets('landscape puts the visual beside the copy', (tester) async {
    await tester.pumpHarness(
      const OnboardingScreen(),
      viewport: const Size(915, 412),
    );

    final image = tester.getRect(find.byKey(const Key('onboarding_hero_image')));
    final title = tester.getRect(find.text('Your books, all in one place'));
    expect(image.right, lessThanOrEqualTo(title.left));
  });

  testWidgets('tablet portrait keeps the stacked layout', (tester) async {
    await tester.pumpHarness(
      const OnboardingScreen(),
      viewport: const Size(800, 1280),
    );

    final image = tester.getRect(find.byKey(const Key('onboarding_hero_image')));
    final title = tester.getRect(find.text('Your books, all in one place'));
    expect(image.bottom, lessThanOrEqualTo(title.top));
  });

  testWidgets('landscape fits an error above the action bar', (tester) async {
    final preferences = _MockOnboardingPreferences();
    when(preferences.complete).thenThrow(Exception('storage write failed'));
    if (injector.isRegistered<OnboardingPreferences>()) {
      injector.unregister<OnboardingPreferences>();
    }
    injector.registerSingleton<OnboardingPreferences>(preferences);
    addTearDown(() => injector.unregister<OnboardingPreferences>());

    await tester.pumpHarness(
      const OnboardingScreen(),
      viewport: const Size(874, 402),
    );
    await tester.tap(find.byKey(const Key('dot_indicator_3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('import_first_book_button')));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Try again.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
