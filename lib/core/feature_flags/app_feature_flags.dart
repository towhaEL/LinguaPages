import 'package:lingua_pages/core/env/app_environment.dart';

/// Build-time and environment-aware feature switches.
///
/// AI Recap is intentionally disabled by default. A development build can
/// enable the mock experience with:
///
/// `--dart-define=LINGUAPAGE_AI_RECAP=true`
///
/// Production builds never enable the mock or remote AI path through this
/// class. A real AI integration will require a separate v1.1 implementation.
class AppFeatureFlags {
  const AppFeatureFlags({
    required this.aiRecapEnabled,
    required this.premiumEnabled,
    required this.cloudSyncEnabled,
    required this.mockServicesEnabled,
    required this.mockTranslationEnabled,
  });

  factory AppFeatureFlags.forEnvironment(String environment) {
    return AppFeatureFlags(
      aiRecapEnabled:
          environment != AppEnvironment.production && _aiRecapBuildEnabled,
      premiumEnabled: environment != AppEnvironment.development,
      cloudSyncEnabled: environment != AppEnvironment.development,
      mockServicesEnabled: environment == AppEnvironment.development,
      mockTranslationEnabled: environment == AppEnvironment.development,
    );
  }

  static const bool _aiRecapBuildEnabled = bool.fromEnvironment(
    'LINGUAPAGE_AI_RECAP',
    defaultValue: false,
  );

  /// Whether the AI Recap feature is available.
  final bool aiRecapEnabled;

  /// Whether premium/billing features are active.
  /// Disabled in development to skip paywall during testing.
  final bool premiumEnabled;

  /// Whether cloud synchronization is active.
  final bool cloudSyncEnabled;

  /// Whether mock data sources are used instead of real implementations.
  final bool mockServicesEnabled;

  /// Whether translation uses mock fixtures instead of real language packs.
  /// Useful for UI development without downloading language data.
  final bool mockTranslationEnabled;
}
