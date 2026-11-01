import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';

/// Persists the last locally verified billing entitlement.
///
/// The cache lets a premium appearance purchase keep working offline; the
/// store itself stays behind `BillingService`.
abstract interface class PremiumEntitlementRepository {
  Future<PremiumEntitlementEntity> getCurrent();

  Future<void> save(PremiumEntitlementEntity entitlement);

  Future<void> clear();
}
