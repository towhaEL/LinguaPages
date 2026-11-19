import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:logger/logger.dart';

/// Google Play Billing through the official `in_app_purchase` plugin, for
/// the yearly subscription and the lifetime unlock.
///
/// shortcut: purchases are trusted from the Play client without server-side
/// token verification; add a verification backend if piracy becomes material.
@LazySingleton(
  as: BillingService,
  env: [AppEnvironment.staging, AppEnvironment.production],
)
class PlayBillingService implements BillingService {
  PlayBillingService(this._logger, {@ignoreParam InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  final Logger _logger;
  final Map<PremiumPlan, ProductDetails> _products = {};

  static final _productIds = {
    for (final plan in PremiumPlan.values) BillingService.productId(plan),
  };

  @override
  late final Stream<BillingEvent> events = _store.purchaseStream
      .asyncExpand(
        (purchases) => Stream.fromFutures(
          purchases
              .where((p) => _productIds.contains(p.productID))
              .map(_handle),
        ),
      )
      .asBroadcastStream();

  Future<BillingEvent> _handle(PurchaseDetails purchase) async {
    // Play refunds purchases that are not acknowledged within three days.
    if (purchase.pendingCompletePurchase) {
      await _complete(purchase);
    }
    // Only known product IDs reach here, so the plan is always found.
    final plan = BillingService.planFor(purchase.productID)!;
    return switch (purchase.status) {
      PurchaseStatus.purchased => BillingPurchased(plan),
      PurchaseStatus.restored => BillingPurchased(plan, restored: true),
      PurchaseStatus.pending => const BillingPending(),
      PurchaseStatus.canceled => const BillingCanceled(),
      PurchaseStatus.error => BillingFailed(
        purchase.error?.message ?? 'Purchase failed',
      ),
    };
  }

  @override
  Future<Map<PremiumPlan, BillingProduct>> loadProducts() async {
    try {
      if (!await _store.isAvailable()) return const {};
      final response = await _store.queryProductDetails(_productIds);
      if (response.error != null) {
        _logger.w('Product query failed: ${response.error!.message}');
      }
      final products = <PremiumPlan, BillingProduct>{};
      for (final details in response.productDetails) {
        final plan = BillingService.planFor(details.id);
        if (plan == null) continue;
        final product = _toProduct(plan, details);
        // A subscription comes once per base plan and offer; prefer the one
        // with a free trial, which Play only offers to eligible users.
        final current = products[plan];
        if (current != null &&
            (current.freeTrialDays != null || product.freeTrialDays == null)) {
          continue;
        }
        products[plan] = product;
        _products[plan] = details;
      }
      return products;
    } on PlatformException catch (error) {
      _logger.w('Store unavailable', error: error);
      return const {};
    }
  }

  static BillingProduct _toProduct(PremiumPlan plan, ProductDetails details) {
    final offers = details is GooglePlayProductDetails
        ? details.productDetails.subscriptionOfferDetails
        : null;
    final phases = offers == null || details is! GooglePlayProductDetails
        ? null
        : offers[details.subscriptionIndex ?? 0].pricingPhases;
    if (phases == null || phases.isEmpty) {
      return BillingProduct(
        id: details.id,
        plan: plan,
        price: details.price,
        rawPrice: details.rawPrice,
        currencyCode: details.currencyCode,
      );
    }
    // The last phase is the recurring price; a free first phase is a trial.
    final recurring = phases.last;
    final trial = phases.first.priceAmountMicros == 0 && phases.length > 1
        ? _periodDays(phases.first.billingPeriod)
        : null;
    return BillingProduct(
      id: details.id,
      plan: plan,
      price: recurring.formattedPrice,
      rawPrice: recurring.priceAmountMicros / 1000000,
      currencyCode: recurring.priceCurrencyCode,
      freeTrialDays: trial,
    );
  }

  /// Days in an ISO 8601 period such as P7D, P1W or P1M.
  static int? _periodDays(String period) {
    final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(period);
    if (match == null) return null;
    final count = int.parse(match.group(1)!);
    return switch (match.group(2)) {
      'D' => count,
      'W' => count * 7,
      'M' => count * 30,
      _ => count * 365,
    };
  }

  @override
  Future<void> buy(PremiumPlan plan) async {
    if (!_products.containsKey(plan)) await loadProducts();
    final product = _products[plan];
    if (product == null) {
      throw StateError('The $plan plan is not available in the store.');
    }
    // Subscriptions are bought as non-consumables too; the plugin picks the
    // offer from the product's offer token.
    await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<Set<PremiumPlan>?> ownedPlans() async {
    // Play only lists subscriptions that are still active, so an expired or
    // canceled-and-lapsed yearly plan reads as not owned.
    try {
      final android = _store
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await android.queryPastPurchases();
      if (response.error != null) return null;
      final owned = <PremiumPlan>{};
      for (final purchase in response.pastPurchases) {
        final plan = BillingService.planFor(purchase.productID);
        if (plan == null) continue;
        if (purchase.pendingCompletePurchase) await _complete(purchase);
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          owned.add(plan);
        }
      }
      return owned;
    } on PlatformException catch (error) {
      _logger.w('Purchase query failed', error: error);
      return null;
    }
  }

  Future<void> _complete(PurchaseDetails purchase) async {
    try {
      await _store.completePurchase(purchase);
    } on PlatformException catch (error) {
      // Play re-delivers unacknowledged purchases, so this is retried later.
      _logger.w('Could not acknowledge purchase', error: error);
    }
  }
}
