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
    this.product,
  });

  /// Whether premium appearance items can be applied. Always true when
  /// gating is off (the development flavor).
  final bool unlocked;
  final PremiumStatus status;

  /// The store product with its price; null until loaded or if unavailable.
  final BillingProduct? product;

  bool get isBusy =>
      status == PremiumStatus.purchasing || status == PremiumStatus.restoring;

  PremiumState copyWith({
    bool? unlocked,
    PremiumStatus? status,
    BillingProduct? product,
  }) => PremiumState(
    unlocked: unlocked ?? this.unlocked,
    status: status ?? this.status,
    product: product ?? this.product,
  );
}
