import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../e2e/helpers/test_app_harness.dart';

class MockOnboardingPreferences extends Mock implements OnboardingPreferences {}

class MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(() {
    registerFallbackValue(<PageRouteInfo>[]);
  });

  late MockOnboardingPreferences mockPreferences;
  late MockStackRouter mockRouter;

  setUp(() {
    mockPreferences = MockOnboardingPreferences();
    mockRouter = MockStackRouter();

    when(() => mockRouter.replaceAll(any())).thenAnswer((_) async {});

    if (injector.isRegistered<OnboardingPreferences>()) {
      injector.unregister<OnboardingPreferences>();
    }
    injector.registerSingleton<OnboardingPreferences>(mockPreferences);
  });

  tearDown(() {
    if (injector.isRegistered<OnboardingPreferences>()) {
      injector.unregister<OnboardingPreferences>();
    }
  });

  Widget buildScaffoldHarness({
    Widget? child,
    Size viewport = WarmEditorialTokens.standardViewport,
  }) {
    return buildTestHarness(
      child: StackRouterScope(
        controller: mockRouter,
        stateHash: 0,
        child: child ?? const OnboardingScreen(),
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    Widget? child,
    Size viewport = const Size(412, 915),
  }) async {
    tester.view.physicalSize = viewport * tester.view.devicePixelRatio;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildScaffoldHarness(child: child, viewport: viewport));
    await tester.pumpAndSettle();
  }

  group('Adversarial Stress Test: State & Error Resilience', () {
    testWidgets(
      'Scenario 1.1: OnboardingPreferences.complete() exception on Import displays error, resets _busy, avoids unhandled crash',
      (tester) async {
        when(() => mockPreferences.complete())
            .thenThrow(Exception('Simulated storage write error'));

        await pumpScreen(tester);

        // Jump to Page 4 via Dot 3
        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        expect(find.text('Private by design'), findsOneWidget);
        expect(find.text('Something went wrong. Try again.'), findsNothing);

        // Tap Import First Book
        await tester.tap(find.byKey(const Key('import_first_book_button')));
        // Frame pump to observe state transition
        await tester.pump();
        await tester.pumpAndSettle();

        // 1. Unhandled exception should not crash the test
        expect(tester.takeException(), isNull);

        // 2. Error message displayed
        expect(find.text('Something went wrong. Try again.'), findsOneWidget);

        // 3. Busy state is reset: CircularProgressIndicator gone, button re-enabled
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byIcon(Icons.folder_open), findsOneWidget);

        // 4. Router replaceAll was not called on error
        verifyNever(() => mockRouter.replaceAll(any()));

        // 5. Subsequent retry can recover if storage heals
        when(() => mockPreferences.complete()).thenAnswer((_) async {});
        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockRouter.replaceAll(any())).called(1);
      },
    );

    testWidgets(
      'Scenario 1.2: OnboardingPreferences.complete() exception on Explore First displays error, resets _busy',
      (tester) async {
        when(() => mockPreferences.complete())
            .thenThrow(Exception('Simulated database lock failure'));

        await pumpScreen(tester);

        // Jump to Page 4 via Dot 3
        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // Tap Explore first
        await tester.tap(find.byKey(const Key('explore_first_button')));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Something went wrong. Try again.'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        verifyNever(() => mockRouter.replaceAll(any()));
      },
    );

    testWidgets(
      'Scenario 1.3: Double-tapping "Import your first book" while _busy is true triggers single execution',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // First tap initiates async completion
        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump(); // Start execution, _busy = true

        // Verify busy indicator is showing
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Attempt secondary tap while operation is in flight
        // Button is disabled (onPressed == null), tap should not invoke handler
        await tester.tap(find.byKey(const Key('import_first_book_button')), warnIfMissed: false);
        await tester.pump();

        // Also attempt tapping Explore first while busy
        await tester.tap(find.byKey(const Key('explore_first_button')), warnIfMissed: false);
        await tester.pump();

        // Now resolve the asynchronous complete call
        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify exactly one invocation occurred
        verify(() => mockPreferences.complete()).called(1);
        verify(() => mockRouter.replaceAll(any())).called(1);
      },
    );

    testWidgets(
      'Scenario 1.4: Double-tapping "Explore first" while _busy is true triggers single execution',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // Tap Explore first
        await tester.tap(find.byKey(const Key('explore_first_button')));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Attempt to tap again while in flight
        await tester.tap(find.byKey(const Key('explore_first_button')), warnIfMissed: false);
        await tester.tap(find.byKey(const Key('import_first_book_button')), warnIfMissed: false);
        await tester.pump();

        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockPreferences.complete()).called(1);
        verify(() => mockRouter.replaceAll(any())).called(1);
      },
    );

    testWidgets(
      'Scenario 1.5: Tapping Skip on Page 4 while _busy is true does not trigger duplicate completion',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump();

        // On Page 4, Skip delegates to _handleExploreFirst() -> _completeOnboarding()
        // But _busy is true, so it must return immediately without duplicate execution
        await tester.tap(find.text('Skip'));
        await tester.pump();

        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockPreferences.complete()).called(1);
      },
    );

    testWidgets(
      'Scenario 1.6: Successful navigation on Import cleanly resets _busy if widget remains mounted',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // Initiate import
        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump();

        // While in-flight, _busy is true: spinner shown, import button disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final importButtonWhileBusy = tester.widget<FilledButton>(find.byKey(const Key('import_first_book_button')));
        expect(importButtonWhileBusy.onPressed, isNull);

        // Resolve preferences and let router.replaceAll finish
        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Router replaceAll was called
        verify(() => mockRouter.replaceAll(any())).called(1);

        // Crucial empirical assertion: _busy is cleanly reset to false
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byIcon(Icons.folder_open), findsOneWidget);
        final importButtonAfter = tester.widget<FilledButton>(find.byKey(const Key('import_first_book_button')));
        expect(importButtonAfter.onPressed, isNotNull);
      },
    );

    testWidgets(
      'Scenario 1.7: Successful navigation on Explore First cleanly resets _busy if widget remains mounted',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // Initiate explore first
        await tester.tap(find.byKey(const Key('explore_first_button')));
        await tester.pump();

        // In flight: spinner shown, explore button disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final exploreButtonWhileBusy = tester.widget<TextButton>(find.byKey(const Key('explore_first_button')));
        expect(exploreButtonWhileBusy.onPressed, isNull);

        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockRouter.replaceAll(any())).called(1);

        // Empirically verify _busy reset to false
        expect(find.byType(CircularProgressIndicator), findsNothing);
        final exploreButtonAfter = tester.widget<TextButton>(find.byKey(const Key('explore_first_button')));
        expect(exploreButtonAfter.onPressed, isNotNull);
      },
    );

    testWidgets(
      'Scenario 1.8: Rapid alternating taps between Import and Explore execute exactly once without race condition',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        // Rapid dual taps back-to-back before frame pump
        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.tap(find.byKey(const Key('explore_first_button')), warnIfMissed: false);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        verify(() => mockPreferences.complete()).called(1);
        verify(() => mockRouter.replaceAll(any())).called(1);
      },
    );

    testWidgets(
      'Scenario 1.9: Strict architectural rule: zero NavigationBar or BottomNavigationBar across all onboarding states',
      (tester) async {
        await pumpScreen(tester);

        // Page 1
        tester.expectNoBottomNavigationBar();

        // Page 2
        await tester.tap(find.byKey(const Key('dot_indicator_1')));
        await tester.pumpAndSettle();
        tester.expectNoBottomNavigationBar();

        // Page 3
        await tester.tap(find.byKey(const Key('dot_indicator_2')));
        await tester.pumpAndSettle();
        tester.expectNoBottomNavigationBar();

        // Page 4
        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();
        tester.expectNoBottomNavigationBar();
      },
    );
  });

  group('Adversarial Stress Test: Lifecycle & Unmount Safety', () {
    testWidgets(
      'Scenario 2.1: Unmount mid-animation yields zero FlutterError and clean disposal',
      (tester) async {
        await pumpScreen(tester);

        // Start page transition animation
        await tester.tap(find.byKey(const Key('next_page_button')));
        // Pump 50ms into a 300ms animation
        await tester.pump(const Duration(milliseconds: 50));

        // Mid-animation unmount
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Scenario 2.2: Unmount mid-drag gesture yields zero FlutterError',
      (tester) async {
        await pumpScreen(tester);

        final gesture = await tester.startGesture(const Offset(300, 400));
        await gesture.moveBy(const Offset(-150, 0));
        await tester.pump();

        // Unmount while gesture is active
        await tester.pumpWidget(const SizedBox());
        await gesture.up();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Scenario 2.3: Unmount while async completion is pending does not throw on resolution',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump();

        // Unmount before completion resolves
        await tester.pumpWidget(const SizedBox());

        // Resolve after unmount
        completer.complete();
        await tester.pumpAndSettle();

        // !mounted guard must have prevented setState or context.router invocation
        expect(tester.takeException(), isNull);
        verifyNever(() => mockRouter.replaceAll(any()));
      },
    );

    testWidgets(
      'Scenario 2.4: Unmount while async completion errors does not call setState on unmounted State',
      (tester) async {
        final completer = Completer<void>();
        when(() => mockPreferences.complete()).thenAnswer((_) => completer.future);

        await pumpScreen(tester);

        await tester.tap(find.byKey(const Key('dot_indicator_3')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('import_first_book_button')));
        await tester.pump();

        // Unmount before completion throws
        await tester.pumpWidget(const SizedBox());

        // Throw error after unmount
        completer.completeError(Exception('Asynchronous post-unmount failure'));
        await tester.pumpAndSettle();

        // !mounted guard in catch block must prevent setState call
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Adversarial Stress Test: Viewport Constraints & Zero RenderFlex Overflow', () {
    final viewports = <String, Size>{
      'Target mobile (412x915 dp)': const Size(412, 915),
      'Narrow phone (320x640 dp)': const Size(320, 640),
      'Large display (600x1000 dp)': const Size(600, 1000),
      'Ultra-compact height (320x480 dp)': const Size(320, 480),
    };

    for (final entry in viewports.entries) {
      final label = entry.key;
      final size = entry.value;

      testWidgets(
        'Scenario 3: Zero RenderFlex overflow on all 4 pages under $label',
        (tester) async {
          FlutterErrorDetails? errorDetails;
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            errorDetails = details;
          };

          await pumpScreen(tester, viewport: size);
          FlutterError.onError = originalOnError;

          if (errorDetails != null) {
            // ignore: avoid_print
            print('DEBUG ERROR DETAILS:\n${errorDetails.toString()}');
          }

          // Verify Page 1
          expect(find.text('Your books, all in one place'), findsOneWidget);

          // Verify Page 2
          await tester.tap(find.byKey(const Key('dot_indicator_1')));
          await tester.pumpAndSettle();
          expect(find.text('Read the way you like'), findsOneWidget);

          // Verify Page 3
          await tester.tap(find.byKey(const Key('dot_indicator_2')));
          await tester.pumpAndSettle();
          expect(find.text('Listen when your eyes rest'), findsOneWidget);

          // Verify Page 4
          await tester.tap(find.byKey(const Key('dot_indicator_3')));
          await tester.pumpAndSettle();
          expect(find.text('Private by design'), findsOneWidget);
          expect(find.byKey(const Key('import_first_book_button')), findsOneWidget);
          expect(find.byKey(const Key('explore_first_button')), findsOneWidget);

          // Assert zero rendering exceptions across the entire screen
          expect(
            errorDetails,
            isNull,
            reason: 'RenderFlex overflow detected under $label: ${errorDetails?.summary}',
          );
        },
      );
    }
  });
}
