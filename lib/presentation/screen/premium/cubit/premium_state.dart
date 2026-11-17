import 'package:lingua_pages/domain/service/billing_service.dart';

enum PremiumStatus {
  idle,
  purchasing,

  /// Payment started but the store has not confirmed it yet.
  pending,
  restoring,
  purchased,
  restored,
  nothingToRestore,

  /// The store could not be reached.
  storeUnavailable,
  failed,
}

class PremiumState {
  const PremiumState({
    required this.unlocked,
    this.status = PremiumStatus.idle,
    this.products = const {},
  });

  /// Whether premium appearance items can be applied. Always true when
  /// gating is off (the development flavor).
  final bool unlocked;
  final PremiumStatus status;

  /// The store's plans with their prices; empty until loaded or when the
  /// store is unavailable.
  final Map<PremiumPlan, BillingProduct> products;

  bool get isBusy =>
      status == PremiumStatus.purchasing || status == PremiumStatus.restoring;

  PremiumState copyWith({
    bool? unlocked,
    PremiumStatus? status,
    Map<PremiumPlan, BillingProduct>? products,
  }) => PremiumState(
    unlocked: unlocked ?? this.unlocked,
    status: status ?? this.status,
    products: products ?? this.products,
  );
}
