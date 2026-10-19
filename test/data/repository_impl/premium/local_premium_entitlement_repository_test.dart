import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/repository_impl/premium/local_premium_entitlement_repository.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalPremiumEntitlementRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalPremiumEntitlementRepository(
      await SharedPreferences.getInstance(),
    );
  });

  test('stores and restores a purchase entitlement', () async {
    final verifiedAt = DateTime(2026, 10, 20);
    final expiresAt = DateTime(2027, 10, 20);
    await repository.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.purchase,
        expiresAt: expiresAt,
        lastVerifiedAt: verifiedAt,
      ),
    );

    final current = await repository.getCurrent();
    expect(current.isActive, isTrue);
    expect(current.source, PremiumEntitlementSource.purchase);
    expect(current.expiresAt, expiresAt);
    expect(current.lastVerifiedAt, verifiedAt);
  });

  test('clearing the cache returns a free entitlement', () async {
    await repository.save(
      const PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.restored,
      ),
    );
    await repository.clear();

    final current = await repository.getCurrent();
    expect(current.isActive, isFalse);
    expect(current.source, PremiumEntitlementSource.none);
  });

  test('expired entitlements are not active', () async {
    await repository.save(
      PremiumEntitlementEntity(
        isPremium: true,
        source: PremiumEntitlementSource.cache,
        expiresAt: DateTime(2020),
      ),
    );

    expect((await repository.getCurrent()).isActive, isFalse);
  });
}
