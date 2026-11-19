/// Locally cached premium entitlement state.
class PremiumEntitlementEntity {
  const PremiumEntitlementEntity({
    required this.isPremium,
    required this.source,
    this.expiresAt,
    this.lastVerifiedAt,
  });

  final bool isPremium;
  final PremiumEntitlementSource source;

  /// Null for a lifetime unlock; for a subscription, the end of its offline
  /// grace past [lastVerifiedAt].
  final DateTime? expiresAt;
  final DateTime? lastVerifiedAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isActive => isActiveAt(DateTime.now());

  bool isActiveAt(DateTime now) =>
      isPremium && (expiresAt == null || !expiresAt!.isBefore(now));
}

enum PremiumEntitlementSource { none, purchase, restored, cache }
