import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/premium/premium_entitlement_entity.dart';
import 'package:lingua_pages/domain/repository/premium/premium_entitlement_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: PremiumEntitlementRepository)
class LocalPremiumEntitlementRepository
    implements PremiumEntitlementRepository {
  LocalPremiumEntitlementRepository(this._preferences);

  static const _premiumKey = 'premium.entitlement.is_premium';
  static const _sourceKey = 'premium.entitlement.source';
  static const _expiresAtKey = 'premium.entitlement.expires_at';
  static const _lastVerifiedAtKey = 'premium.entitlement.last_verified_at';

  final SharedPreferences _preferences;

  @override
  Future<PremiumEntitlementEntity> getCurrent() async {
    final sourceName = _preferences.getString(_sourceKey);
    final source = sourceName == null
        ? PremiumEntitlementSource.none
        : PremiumEntitlementSource.values.firstWhere(
            (value) => value.name == sourceName,
            orElse: () => PremiumEntitlementSource.cache,
          );
    return PremiumEntitlementEntity(
      isPremium: _preferences.getBool(_premiumKey) ?? false,
      source: source,
      expiresAt: _dateFromMillis(_preferences.getInt(_expiresAtKey)),
      lastVerifiedAt: _dateFromMillis(
        _preferences.getInt(_lastVerifiedAtKey),
      ),
    );
  }

  @override
  Future<void> save(PremiumEntitlementEntity entitlement) async {
    await _preferences.setBool(_premiumKey, entitlement.isPremium);
    await _preferences.setString(_sourceKey, entitlement.source.name);
    await _setDate(_expiresAtKey, entitlement.expiresAt);
    await _setDate(_lastVerifiedAtKey, entitlement.lastVerifiedAt);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_premiumKey);
    await _preferences.remove(_sourceKey);
    await _preferences.remove(_expiresAtKey);
    await _preferences.remove(_lastVerifiedAtKey);
  }

  DateTime? _dateFromMillis(int? value) =>
      value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);

  Future<void> _setDate(String key, DateTime? value) async {
    if (value == null) {
      await _preferences.remove(key);
    } else {
      await _preferences.setInt(key, value.millisecondsSinceEpoch);
    }
  }
}
