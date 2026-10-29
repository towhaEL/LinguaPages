import 'package:lingua_pages/core/env/app_environment.dart';

/// Build-time and environment-aware feature switches.
class AppFeatureFlags {
  const AppFeatureFlags({
    required this.premiumEnabled,
    required this.mockServicesEnabled,
  });

  factory AppFeatureFlags.forEnvironment(String environment) {
    return AppFeatureFlags(
      premiumEnabled: environment != AppEnvironment.development,
      mockServicesEnabled: environment == AppEnvironment.development,
    );
  }

  /// Whether premium/billing features are active.
  /// Disabled in development to skip paywall during testing.
  final bool premiumEnabled;

  /// Whether mock data sources are used instead of real implementations.
  final bool mockServicesEnabled;
}
