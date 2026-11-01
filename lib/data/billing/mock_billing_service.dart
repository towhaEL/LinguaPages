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
  Future<BillingProduct?> loadProduct() async => const BillingProduct(
    id: BillingService.premiumProductId,
    price: r'$2.99',
  );

  @override
  Future<void> buy() async {
    _owned = true;
    _events.add(const BillingPurchased());
  }

  @override
  Future<bool?> ownsPremium() async => _owned;
}
