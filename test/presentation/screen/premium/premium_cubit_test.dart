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

  test('starts locked and shows the store price', () async {
    await cubit.start();

    expect(cubit.state.unlocked, isFalse);
    expect(cubit.state.product?.price, r'$2.99');
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
    billing.owns = false;

    await cubit.start();

    expect(cubit.state.unlocked, isFalse);
    expect((await entitlements.getCurrent()).isActive, isFalse);
  });

  test('a completed purchase unlocks and is cached', () async {
    await cubit.start();
    await cubit.buy();
    expect(cubit.state.status, PremiumStatus.purchasing);

    billing.emit(const BillingPurchased());
    await pumpEventQueue();

    expect(cubit.state.unlocked, isTrue);
    expect(cubit.state.status, PremiumStatus.purchased);
    final cached = await entitlements.getCurrent();
    expect(cached.source, PremiumEntitlementSource.purchase);
    expect(cached.lastVerifiedAt, DateTime(2026, 11));
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
        ..product = null
        ..buyError = StateError('no product');
      await cubit.start();

      await cubit.buy();

      expect(cubit.state.status, PremiumStatus.storeUnavailable);
    },
  );

  group('restore', () {
    setUp(() => cubit.start());

    test('unlocks an owned purchase', () async {
      billing.owns = true;
      await cubit.restore();

      expect(cubit.state.unlocked, isTrue);
      expect(cubit.state.status, PremiumStatus.restored);
      expect(
        (await entitlements.getCurrent()).source,
        PremiumEntitlementSource.restored,
      );
    });

    test('reports when there is nothing to restore', () async {
      billing.owns = false;
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
  BillingProduct? product = const BillingProduct(
    id: BillingService.premiumProductId,
    price: r'$2.99',
  );
  bool? owns = false;
  Object? buyError;
  var ownsCalls = 0;

  void emit(BillingEvent event) => _events.add(event);

  @override
  Stream<BillingEvent> get events => _events.stream;

  @override
  Future<BillingProduct?> loadProduct() async => product;

  @override
  Future<void> buy() async {
    if (buyError != null) throw buyError!;
  }

  @override
  Future<bool?> ownsPremium() async {
    ownsCalls++;
    return owns;
  }
}
