import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/domain/entity/recap/recap_entity.dart';
import 'package:lingua_pages/domain/repository/recap/recap_repository.dart';

/// Deterministic local implementation for development UI and integration
/// tests. It never calls a network service and is not registered for release.
@Singleton(as: RecapRepository)
@Environment(AppEnvironment.development)
class MockRecapRepository implements RecapRepository {
  MockRecapRepository(this._featureFlags);

  final AppFeatureFlags _featureFlags;

  @override
  Future<RecapEntity> generate({
    required String textUpToCurrentPosition,
    required String sourceLanguage,
    required String outputLanguage,
    required String sourceLocator,
  }) async {
    if (!_featureFlags.aiRecapEnabled) {
      throw UnsupportedError('AI Recap is disabled by the build flag.');
    }

    final normalizedText = textUpToCurrentPosition.trim();
    final preview = normalizedText.length > 180
        ? '${normalizedText.substring(0, 180)}…'
        : normalizedText;

    return RecapEntity(
      summary: preview.isEmpty
          ? 'No readable text is available before this position.'
          : 'Mock recap up to the current position: $preview',
      characters: const [],
      sourceLocator: sourceLocator,
      generatedAt: DateTime.now(),
    );
  }
}
