/// The ways to buy premium.
enum PremiumPlan { yearly, lifetime }

/// Store billing for premium: a yearly subscription or a one-time lifetime
/// unlock. Either one grants the same entitlement.
///
/// Implementations: Google Play for staging and production, a mock for
/// development. The rest of the app never touches the billing plugin.
abstract interface class BillingService {
  /// Play Console product ID of the non-consumable lifetime unlock. It keeps
  /// the original single product's ID, so earlier buyers stay unlocked.
  static const lifetimeProductId = 'premium_appearance';

  /// Play Console product ID of the yearly subscription.
  static const yearlyProductId = 'premium_yearly';

  static String productId(PremiumPlan plan) => switch (plan) {
    PremiumPlan.yearly => yearlyProductId,
    PremiumPlan.lifetime => lifetimeProductId,
  };

  static PremiumPlan? planFor(String productId) => switch (productId) {
    yearlyProductId => PremiumPlan.yearly,
    lifetimeProductId => PremiumPlan.lifetime,
    _ => null,
  };

  /// Purchase updates as the store reports them, including purchases that
  /// finish after the app restarts.
  Stream<BillingEvent> get events;

  /// The plans the store offers, with localized prices. Plans the store
  /// does not have (or all of them, when it is unreachable) are missing.
  Future<Map<PremiumPlan, BillingProduct>> loadProducts();

  /// Starts the store purchase flow for [plan]. The outcome arrives on
  /// [events].
  Future<void> buy(PremiumPlan plan);

  /// Whether the store reports the lifetime unlock or an active yearly
  /// subscription as owned. Null when the store cannot be reached, so
  /// callers keep their cached state.
  Future<bool?> ownsPremium();
}

class BillingProduct {
  const BillingProduct({
    required this.id,
    required this.plan,
    required this.price,
    this.rawPrice,
    this.currencyCode,
    this.freeTrialDays,
  });

  final String id;
  final PremiumPlan plan;

  /// Localized price string from the store, for example "$2.99". For the
  /// subscription it is the recurring price, after any trial.
  final String price;

  /// [price] as a number, for per-month comparisons.
  final double? rawPrice;

  /// ISO 4217 code of [rawPrice].
  final String? currencyCode;

  /// Length of a free trial the subscription starts with, if it has one.
  final int? freeTrialDays;
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
