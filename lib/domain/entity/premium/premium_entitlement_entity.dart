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
  final DateTime? expiresAt;
  final DateTime? lastVerifiedAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isActive => isPremium && !isExpired;
}

enum PremiumEntitlementSource { none, purchase, restored, cache }
