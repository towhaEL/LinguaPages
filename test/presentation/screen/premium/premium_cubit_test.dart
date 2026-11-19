import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/data/repository_impl/premium/local_premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _gated = AppFeatureFlags(
  premiumEnabled: true,
  mockServicesEnabled: false,
);

void main() {
  late _FakeBilling billing;
  late LocalPremiumEntitlementRepository entitlements;
  late PremiumCubit cubit;

  PremiumCubit build([AppFeatureFlags flags = _gated]) => PremiumCubit(
    billing,
    entitlements,
    flags,
    Logger(level: Level.off),
    clock: () => DateTime(2026, 11),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    billing = _FakeBilling();
    entitlements = LocalPremiumEntitlementRepository(
      await SharedPreferences.getInstance(),
    );
    cubit = build();
  });

  tearDown(() => cubit.close());

  Future<void> grantCached() => entitlements.save(
    const PremiumEntitlementEntity(
      isPremium: true,
      source: PremiumEntitlementSource.purchase,
    ),
  );

  test('development has every look unlocked without a store', () async {
    final dev = build(
      const AppFeatureFlags(premiumEnabled: false, mockServicesEnabled: true),
    );
    await dev.start();

    expect(dev.state.unlocked, isTrue);
    expect(billing.ownsCalls, 0);
    await dev.close();
  });

  test('starts locked and shows both plans with store prices', () async {
    await cubit.start();

    expect(cubit.state.unlocked, isFalse);
    expect(cubit.state.products[PremiumPlan.yearly]?.price, r'$4.99');
    expect(cubit.state.products[PremiumPlan.lifetime]?.price, r'$14.99');
  });

  test('offline launch keeps a cached purchase', () async {
    await grantCached();
    billing.owns = null;

    await cubit.start();

    expect(cubit.state.unlocked, isTrue);
    expect((await entitlements.getCurrent()).isActive, isTrue);
  });

  test('a refunded purchase locks again and clears the cache', () async {
    await grantCached();
    billing.owns = {};

    await cubit.start();

    expect(cubit.state.unlocked, isFalse);
    expect((await entitlements.getCurrent()).isActive, isFalse);
  });

  test('a completed purchase unlocks and is cached', () async {
    await cubit.start();
    await cubit.buy(PremiumPlan.yearly);
    expect(cubit.state.status, PremiumStatus.purchasing);
    expect(billing.boughtPlan, PremiumPlan.yearly);

    billing.emit(const BillingPurchased(PremiumPlan.yearly));
    await pumpEventQueue();

    expect(cubit.state.unlocked, isTrue);
    expect(cubit.state.status, PremiumStatus.purchased);
    final cached = await entitlements.getCurrent();
    expect(cached.source, PremiumEntitlementSource.purchase);
    expect(cached.lastVerifiedAt, DateTime(2026, 11));
    expect(
      cached.expiresAt,
      DateTime(2026, 11).add(PremiumCubit.subscriptionGrace),
    );
  });

  test('a lifetime purchase never expires', () async {
    await cubit.start();
    billing.emit(const BillingPurchased(PremiumPlan.lifetime));
    await pumpEventQueue();

    expect((await entitlements.getCurrent()).expiresAt, isNull);
  });

  test('offline, a subscription past its grace locks', () async {
    await entitlements.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.purchase,
        expiresAt: DateTime(2026, 10, 31),
      ),
    );
    billing.owns = null;

    await cubit.start();

    expect(cubit.state.unlocked, isFalse);
  });

  test('a store check renews the subscription grace', () async {
    await entitlements.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.purchase,
        expiresAt: DateTime(2026, 10, 31),
      ),
    );
    billing.owns = {PremiumPlan.yearly};

    await cubit.start();

    expect(cubit.state.unlocked, isTrue);
    expect(
      (await entitlements.getCurrent()).expiresAt,
      DateTime(2026, 11).add(PremiumCubit.subscriptionGrace),
    );
  });

  test('owning both plans caches the lifetime unlock', () async {
    billing.owns = {PremiumPlan.yearly, PremiumPlan.lifetime};
    await cubit.start();

    expect((await entitlements.getCurrent()).expiresAt, isNull);
  });

  test('refresh notices a subscription that lapsed while open', () async {
    billing.owns = {PremiumPlan.yearly};
    await cubit.start();
    expect(cubit.state.unlocked, isTrue);

    billing.owns = {};
    await cubit.refresh();

    expect(cubit.state.unlocked, isFalse);
  });

  test('refresh calls made together ask the store once', () async {
    await cubit.start();
    final calls = billing.ownsCalls;

    await Future.wait([cubit.refresh(), cubit.refresh()]);

    expect(billing.ownsCalls, calls + 1);
  });

  test('pending, canceled and failed purchases stay locked', () async {
    await cubit.start();
    for (final (event, status) in [
      (const BillingPending(), PremiumStatus.pending),
      (const BillingCanceled(), PremiumStatus.idle),
      (const BillingFailed('declined'), PremiumStatus.failed),
    ]) {
      billing.emit(event);
      await pumpEventQueue();
      expect(cubit.state.status, status);
      expect(cubit.state.unlocked, isFalse);
    }
  });

  test(
    'buying without a store product reports the store unavailable',
    () async {
      billing
        ..products = const {}
        ..buyError = StateError('no product');
      await cubit.start();

      await cubit.buy(PremiumPlan.lifetime);

      expect(cubit.state.status, PremiumStatus.storeUnavailable);
    },
  );

  group('opening the paywall', () {
    test('clears the last attempt\'s message', () async {
      await cubit.start();
      billing.emit(const BillingFailed('declined'));
      await pumpEventQueue();
      expect(cubit.state.status, PremiumStatus.failed);

      await cubit.paywallOpened();

      expect(cubit.state.status, PremiumStatus.idle);
    });

    test('keeps a pending payment and blocks buying it twice', () async {
      await cubit.start();
      billing.emit(const BillingPending());
      await pumpEventQueue();

      await cubit.paywallOpened();
      await cubit.buy(PremiumPlan.lifetime);

      expect(cubit.state.status, PremiumStatus.pending);
      expect(billing.boughtPlan, isNull);
    });

    test('asks for prices the store could not give at launch', () async {
      billing.products = const {};
      await cubit.start();
      expect(cubit.state.products, isEmpty);

      billing.products = const {
        PremiumPlan.lifetime: BillingProduct(
          id: BillingService.lifetimeProductId,
          plan: PremiumPlan.lifetime,
          price: r'$14.99',
        ),
      };
      await cubit.paywallOpened();

      expect(cubit.state.products, contains(PremiumPlan.lifetime));
    });
  });

  group('restore', () {
    setUp(() => cubit.start());

    test('unlocks an owned purchase', () async {
      billing.owns = {PremiumPlan.lifetime};
      await cubit.restore();

      expect(cubit.state.unlocked, isTrue);
      expect(cubit.state.status, PremiumStatus.restored);
      expect(
        (await entitlements.getCurrent()).source,
        PremiumEntitlementSource.restored,
      );
    });

    test('reports when there is nothing to restore', () async {
      billing.owns = {};
      await cubit.restore();

      expect(cubit.state.unlocked, isFalse);
      expect(cubit.state.status, PremiumStatus.nothingToRestore);
    });

    test('reports an unreachable store', () async {
      billing.owns = null;
      await cubit.restore();

      expect(cubit.state.status, PremiumStatus.storeUnavailable);
    });
  });
}

class _FakeBilling implements BillingService {
  final _events = StreamController<BillingEvent>.broadcast();
  Map<PremiumPlan, BillingProduct> products = const {
    PremiumPlan.yearly: BillingProduct(
      id: BillingService.yearlyProductId,
      plan: PremiumPlan.yearly,
      price: r'$4.99',
    ),
    PremiumPlan.lifetime: BillingProduct(
      id: BillingService.lifetimeProductId,
      plan: PremiumPlan.lifetime,
      price: r'$14.99',
    ),
  };
  PremiumPlan? boughtPlan;
  Set<PremiumPlan>? owns = {};
  Object? buyError;
  var ownsCalls = 0;

  void emit(BillingEvent event) => _events.add(event);

  @override
  Stream<BillingEvent> get events => _events.stream;

  @override
  Future<Map<PremiumPlan, BillingProduct>> loadProducts() async => products;

  @override
  Future<void> buy(PremiumPlan plan) async {
    if (buyError != null) throw buyError!;
    boughtPlan = plan;
  }

  @override
  Future<Set<PremiumPlan>?> ownedPlans() async {
    ownsCalls++;
    return owns;
  }
}
