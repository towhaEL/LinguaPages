import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production disables AI Recap, mock services, and mock translation', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.production);

    expect(flags.aiRecapEnabled, isFalse);
    expect(flags.mockServicesEnabled, isFalse);
    expect(flags.mockTranslationEnabled, isFalse);
    expect(flags.premiumEnabled, isTrue);
    expect(flags.cloudSyncEnabled, isTrue);
  });

  test('development uses mock services and disables premium', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.development);

    expect(flags.mockServicesEnabled, isTrue);
    expect(flags.mockTranslationEnabled, isTrue);
    expect(flags.premiumEnabled, isFalse);
    expect(flags.cloudSyncEnabled, isFalse);
    expect(flags.aiRecapEnabled, isFalse);
  });

  test('staging enables premium and cloud sync but not mocks', () {
    final flags = AppFeatureFlags.forEnvironment(AppEnvironment.staging);

    expect(flags.premiumEnabled, isTrue);
    expect(flags.cloudSyncEnabled, isTrue);
    expect(flags.mockServicesEnabled, isFalse);
    expect(flags.mockTranslationEnabled, isFalse);
  });
}
