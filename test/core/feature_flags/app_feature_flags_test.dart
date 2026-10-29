import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production enables premium and disables mock services', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.production);

    expect(flags.mockServicesEnabled, isFalse);
    expect(flags.premiumEnabled, isTrue);
  });

  test('development uses mock services and disables premium', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.development);

    expect(flags.mockServicesEnabled, isTrue);
    expect(flags.premiumEnabled, isFalse);
  });

  test('staging enables premium but not mocks', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.staging);

    expect(flags.premiumEnabled, isTrue);
    expect(flags.mockServicesEnabled, isFalse);
  });
}
