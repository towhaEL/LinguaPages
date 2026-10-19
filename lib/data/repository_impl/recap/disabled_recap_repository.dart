import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/domain/entity/recap/recap_entity.dart';
import 'package:lingua_pages/domain/repository/recap/recap_repository.dart';

/// Explicitly disables Recap in staging and production until v1.1.
@Singleton(as: RecapRepository)
@Environment(AppEnvironment.staging)
@Environment(AppEnvironment.production)
class DisabledRecapRepository implements RecapRepository {
  @override
  Future<RecapEntity> generate({
    required String textUpToCurrentPosition,
    required String sourceLanguage,
    required String outputLanguage,
    required String sourceLocator,
  }) {
    throw UnsupportedError('AI Recap is not enabled in this build.');
  }
}
