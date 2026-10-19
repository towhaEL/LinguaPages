import 'package:lingua_pages/domain/entity/recap/recap_entity.dart';

abstract interface class RecapRepository {
  Future<RecapEntity> generate({
    required String textUpToCurrentPosition,
    required String sourceLanguage,
    required String outputLanguage,
    required String sourceLocator,
  });
}
