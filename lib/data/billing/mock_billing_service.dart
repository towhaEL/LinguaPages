import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';

/// Offline store for the development flavor. Purchases succeed at once.
@LazySingleton(as: BillingService, env: [AppEnvironment.development])
class MockBillingService implements BillingService {
  final _events = StreamController<BillingEvent>.broadcast();
  var _owned = false;

  @override
  Stream<BillingEvent> get events => _events.stream;

  @override
  Future<Map<PremiumPlan, BillingProduct>> loadProducts() async => const {
    PremiumPlan.yearly: BillingProduct(
      id: BillingService.yearlyProductId,
      plan: PremiumPlan.yearly,
      price: r'$4.99',
      rawPrice: 4.99,
      currencyCode: 'USD',
      freeTrialDays: 7,
    ),
    PremiumPlan.lifetime: BillingProduct(
      id: BillingService.lifetimeProductId,
      plan: PremiumPlan.lifetime,
      price: r'$14.99',
      rawPrice: 14.99,
      currencyCode: 'USD',
    ),
  };

  @override
  Future<void> buy(PremiumPlan plan) async {
    _owned = true;
    _events.add(const BillingPurchased());
  }

  @override
  Future<bool?> ownsPremium() async => _owned;
}
