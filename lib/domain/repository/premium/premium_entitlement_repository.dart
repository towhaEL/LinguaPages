import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';

/// Persists the last locally verified billing entitlement.
///
/// Billing providers remain behind this boundary so offline limits can be
/// enforced without making the rest of the app depend on Play Billing.
abstract interface class PremiumEntitlementRepository {
  Future<PremiumEntitlementEntity> getCurrent();

  Future<void> save(PremiumEntitlementEntity entitlement);

  Future<void> clear();
}
