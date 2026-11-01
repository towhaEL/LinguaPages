import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:logger/logger.dart';

/// Google Play Billing through the official `in_app_purchase` plugin.
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
  ProductDetails? _product;

  @override
  late final Stream<BillingEvent> events = _store.purchaseStream
      .asyncExpand(
        (purchases) => Stream.fromFutures(
          purchases
              .where((p) => p.productID == BillingService.premiumProductId)
              .map(_handle),
        ),
      )
      .asBroadcastStream();

  Future<BillingEvent> _handle(PurchaseDetails purchase) async {
    // Play refunds purchases that are not acknowledged within three days.
    if (purchase.pendingCompletePurchase) {
      await _complete(purchase);
    }
    return switch (purchase.status) {
      PurchaseStatus.purchased => const BillingPurchased(),
      PurchaseStatus.restored => const BillingPurchased(restored: true),
      PurchaseStatus.pending => const BillingPending(),
      PurchaseStatus.canceled => const BillingCanceled(),
      PurchaseStatus.error => BillingFailed(
        purchase.error?.message ?? 'Purchase failed',
      ),
    };
  }

  @override
  Future<BillingProduct?> loadProduct() async {
    try {
      if (!await _store.isAvailable()) return null;
      final response = await _store.queryProductDetails({
        BillingService.premiumProductId,
      });
      if (response.error != null) {
        _logger.w('Product query failed: ${response.error!.message}');
      }
      final product = response.productDetails.firstOrNull;
      _product = product;
      return product == null
          ? null
          : BillingProduct(id: product.id, price: product.price);
    } on PlatformException catch (error) {
      _logger.w('Store unavailable', error: error);
      return null;
    }
  }

  @override
  Future<void> buy() async {
    if (_product == null) await loadProduct();
    final product = _product;
    if (product == null) {
      throw StateError('The premium product is not available in the store.');
    }
    await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<bool?> ownsPremium() async {
    try {
      final android = _store
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await android.queryPastPurchases();
      if (response.error != null) return null;
      var owned = false;
      for (final purchase in response.pastPurchases) {
        if (purchase.productID != BillingService.premiumProductId) continue;
        if (purchase.pendingCompletePurchase) await _complete(purchase);
        owned |=
            purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored;
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
