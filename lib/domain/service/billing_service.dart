/// Store billing for the one-time premium appearance unlock.
///
/// Implementations: Google Play for staging and production, a mock for
/// development. The rest of the app never touches the billing plugin.
abstract interface class BillingService {
  /// Play Console product ID of the non-consumable unlock.
  static const premiumProductId = 'premium_appearance';

  /// Purchase updates as the store reports them, including purchases that
  /// finish after the app restarts.
  Stream<BillingEvent> get events;

  /// The unlock product with its localized price, or null when the store is
  /// unavailable or the product is not set up.
  Future<BillingProduct?> loadProduct();

  /// Starts the store purchase flow. The outcome arrives on [events].
  Future<void> buy();

  /// Whether the store reports the unlock as owned. Null when the store
  /// cannot be reached, so callers keep their cached state.
  Future<bool?> ownsPremium();
}

class BillingProduct {
  const BillingProduct({required this.id, required this.price});

  final String id;

  /// Localized price string from the store, for example "$2.99".
  final String price;
}

sealed class BillingEvent {
  const BillingEvent();
}

class BillingPurchased extends BillingEvent {
  const BillingPurchased({this.restored = false});

  final bool restored;
}

/// Payment started but is not complete yet, for example a cash payment.
class BillingPending extends BillingEvent {
  const BillingPending();
}

class BillingCanceled extends BillingEvent {
  const BillingCanceled();
}

class BillingFailed extends BillingEvent {
  const BillingFailed(this.message);

  final String message;
}
