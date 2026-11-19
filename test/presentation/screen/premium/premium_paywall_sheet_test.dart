import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/screen/premium/widgets/premium_paywall_sheet.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';

class _MockPremiumCubit extends Mock implements PremiumCubit {}

const _yearly = BillingProduct(
  id: 'yearly',
  plan: PremiumPlan.yearly,
  price: r'$9.99',
  rawPrice: 9.99,
  currencyCode: 'USD',
  freeTrialDays: 7,
);

const _lifetime = BillingProduct(
  id: 'lifetime',
  plan: PremiumPlan.lifetime,
  price: r'$24.99',
  rawPrice: 24.99,
  currencyCode: 'USD',
);

/// A long localized price, to check the plan cards side by side.
const _longYearly = BillingProduct(
  id: 'yearly',
  plan: PremiumPlan.yearly,
  price: 'IDR 1.249.000,00',
  rawPrice: 1249000,
  currencyCode: 'IDR',
  freeTrialDays: 14,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(PremiumPlan.yearly);
  });

  Future<_MockPremiumCubit> open(
    WidgetTester tester,
    Size size,
    PremiumState state,
  ) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = _MockPremiumCubit();
    when(() => cubit.state).thenReturn(state);
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    when(() => cubit.buy(any())).thenAnswer((_) async {});
    when(() => cubit.paywallOpened()).thenAnswer((_) async {});
    await tester.pumpWidget(
      BlocProvider<PremiumCubit>.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showPremiumPaywall(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return cubit;
  }

  const offered = PremiumState(
    unlocked: false,
    products: {PremiumPlan.yearly: _yearly, PremiumPlan.lifetime: _lifetime},
  );

  final sizes = [
    ('narrow phone', const Size(320, 640)),
    ('phone portrait', const Size(402, 874)),
    ('phone landscape', const Size(874, 402)),
    ('tablet portrait', const Size(800, 1280)),
    ('tablet landscape', const Size(1280, 800)),
  ];

  for (final (name, size) in sizes) {
    testWidgets('$name fits the whole offer without overflow', (tester) async {
      await open(tester, size, offered);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('paywall_3theme_preview')), findsOneWidget);
      expect(find.byKey(const Key('paywall_unlock_button')), findsOneWidget);
      expect(find.byKey(const Key('paywall_restore_button')), findsOneWidget);
    });
  }

  testWidgets('phone portrait shows the decision without scrolling', (
    tester,
  ) async {
    await open(tester, const Size(402, 874), offered);

    final screen = tester.view.physicalSize.height;
    for (final key in [
      'paywall_yearly_plan_card',
      'paywall_lifetime_plan_card',
      'paywall_unlock_button',
    ]) {
      expect(
        tester.getRect(find.byKey(Key(key))).bottom,
        lessThanOrEqualTo(screen),
        reason: key,
      );
    }
  });

  testWidgets('close is dimmed and inactive for the first two seconds', (
    tester,
  ) async {
    await open(tester, const Size(402, 874), offered);

    final close = find.byKey(const Key('paywall_close_button'));
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(of: close, matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
    expect(tester.widget<IconButton>(close).onPressed, isNull);
    expect(opacity(), 0.5);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(opacity(), 1);

    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.byType(PremiumPaywallSheet), findsNothing);
  });

  testWidgets('the sheet fills the screen and shows the legal links', (
    tester,
  ) async {
    await open(tester, const Size(402, 874), offered);

    expect(find.byKey(const Key('paywall_privacy_button')), findsOneWidget);
    expect(find.byKey(const Key('paywall_terms_button')), findsOneWidget);
    expect(
      tester.getSize(find.byType(PremiumPaywallSheet)).height,
      greaterThan(800),
    );
  });

  testWidgets('a long price and a trial fit in the plan row', (tester) async {
    await open(
      tester,
      const Size(360, 740),
      const PremiumState(
        unlocked: false,
        products: {
          PremiumPlan.yearly: _longYearly,
          PremiumPlan.lifetime: _lifetime,
        },
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Start 14-day free trial'), findsOneWidget);
  });

  testWidgets('the selected plan is the one bought', (tester) async {
    final cubit = await open(tester, const Size(402, 874), offered);

    await tester.tap(find.byKey(const Key('paywall_lifetime_plan_card')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('paywall_unlock_button')));

    verify(() => cubit.buy(PremiumPlan.lifetime)).called(1);
  });

  testWidgets('a plan the store does not offer cannot be picked', (
    tester,
  ) async {
    await open(
      tester,
      const Size(402, 874),
      const PremiumState(
        unlocked: false,
        products: {PremiumPlan.lifetime: _lifetime},
      ),
    );

    expect(find.text('Not available'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('paywall_unlock_button')),
    );
    // Lifetime is picked by default when yearly is missing.
    expect(button.onPressed, isNotNull);
    expect(find.text('Unlock for \$24.99'), findsOneWidget);

    await tester.tap(find.byKey(const Key('paywall_yearly_plan_card')));
    await tester.pump();
    expect(find.text('Unlock for \$24.99'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unlocked shows thanks and Done, without plans', (tester) async {
    await open(
      tester,
      const Size(402, 874),
      const PremiumState(unlocked: true),
    );

    expect(find.text('Thank you for reading with us'), findsOneWidget);
    expect(find.byKey(const Key('paywall_unlock_button')), findsNothing);
    expect(find.byKey(const Key('paywall_yearly_plan_card')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
