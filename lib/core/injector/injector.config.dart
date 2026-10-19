// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/data_source/library/local/app_file_storage_service.dart'
    as _i848;
import '../../data/data_source/library/local/file_picker_document_import_service.dart'
    as _i264;
import '../../data/data_source/library/local/incoming_document_service.dart'
    as _i222;
import '../../data/data_source/library/local/lingua_page_database.dart'
    as _i211;
import '../../data/data_source/library/local/local_document_metadata_extractor.dart'
    as _i570;
import '../../data/data_source/review/local/local_review_notification_scheduler.dart'
    as _i897;
import '../../data/data_source/translation/local/local_english_lemmatizer.dart'
    as _i422;
import '../../data/data_source/translation/local/local_sentence_translation_service.dart'
    as _i940;
import '../../data/data_source/translation/mock/mock_dictionary_data_source.dart'
    as _i66;
import '../../data/document_engine/local_document_engine_factory.dart' as _i996;
import '../../data/repository_impl/backup/local_backup_repository.dart'
    as _i1066;
import '../../data/repository_impl/library/drift_library_repository.dart'
    as _i623;
import '../../data/repository_impl/premium/local_premium_entitlement_repository.dart'
    as _i514;
import '../../data/repository_impl/reader/drift_reader_repositories.dart'
    as _i487;
import '../../data/repository_impl/recap/disabled_recap_repository.dart'
    as _i1007;
import '../../data/repository_impl/recap/mock_recap_repository.dart' as _i637;
import '../../data/repository_impl/review/drift_review_repository.dart'
    as _i931;
import '../../data/repository_impl/settings/drift_settings_repository.dart'
    as _i143;
import '../../data/repository_impl/translation/local_language_pack_repository.dart'
    as _i880;
import '../../data/repository_impl/vocabulary/drift_vocabulary_repository.dart'
    as _i814;
import '../../domain/repository/backup/backup_repository.dart' as _i862;
import '../../domain/repository/library/library_repository.dart' as _i603;
import '../../domain/repository/premium/premium_entitlement_repository.dart'
    as _i363;
import '../../domain/repository/reader/bookmark_repository.dart' as _i798;
import '../../domain/repository/reader/highlight_repository.dart' as _i749;
import '../../domain/repository/reader/reading_session_repository.dart'
    as _i121;
import '../../domain/repository/recap/recap_repository.dart' as _i185;
import '../../domain/repository/review/review_repository.dart' as _i621;
import '../../domain/repository/settings/settings_repository.dart' as _i55;
import '../../domain/repository/translation/dictionary_repository.dart'
    as _i899;
import '../../domain/repository/translation/language_pack_repository.dart'
    as _i782;
import '../../domain/repository/vocabulary/vocabulary_repository.dart' as _i9;
import '../../domain/service/document_engine_factory.dart' as _i304;
import '../../domain/service/document_import_service.dart' as _i536;
import '../../domain/service/document_metadata_extractor.dart' as _i47;
import '../../domain/service/document_storage_service.dart' as _i824;
import '../../domain/service/lemmatizer.dart' as _i190;
import '../../domain/service/review_notification_scheduler.dart' as _i407;
import '../../domain/service/sentence_translation_service.dart' as _i836;
import '../../domain/use_cases/backup/create_backup_use_case.dart' as _i590;
import '../../domain/use_cases/backup/restore_backup_use_case.dart' as _i895;
import '../../domain/use_cases/library/delete_library_book_use_case.dart'
    as _i486;
import '../../domain/use_cases/library/get_library_books_use_case.dart'
    as _i879;
import '../../domain/use_cases/library/import_document_use_case.dart' as _i964;
import '../../domain/use_cases/library/search_library_use_case.dart' as _i322;
import '../../domain/use_cases/reader/save_reading_progress_use_case.dart'
    as _i214;
import '../../domain/use_cases/review/review_card_use_case.dart' as _i514;
import '../../domain/use_cases/vocabulary/lookup_word_use_case.dart' as _i809;
import '../../domain/use_cases/vocabulary/save_vocabulary_use_case.dart'
    as _i78;
import '../../domain/use_cases/vocabulary/translate_sentence_use_case.dart'
    as _i592;
import '../../presentation/screen/home/cubits/library_cubit.dart' as _i655;
import '../feature_flags/app_feature_flags.dart' as _i101;
import '../helper/secure_storage_service.dart' as _i693;
import '../storage/onboarding_preferences.dart' as _i732;
import 'module.dart' as _i946;

const String _development = 'development';
const String _staging = 'staging';
const String _production = 'production';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final loggerModule = _$LoggerModule();
    final featureFlagsModule = _$FeatureFlagsModule();
    final databaseModule = _$DatabaseModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i974.Logger>(() => loggerModule.logger);
    gh.lazySingleton<_i101.AppFeatureFlags>(
      () => featureFlagsModule.featureFlags,
    );
    gh.lazySingleton<_i211.LinguaPageDatabase>(() => databaseModule.database);
    gh.lazySingleton<_i749.HighlightRepository>(
      () => _i487.DriftHighlightRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.lazySingleton<_i782.LanguagePackRepository>(
      () => _i880.LocalLanguagePackRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i9.VocabularyRepository>(
      () => _i814.DriftVocabularyRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.singleton<_i78.SaveVocabularyUseCase>(
      () => _i78.SaveVocabularyUseCase(
        gh<_i9.VocabularyRepository>(),
        gh<_i101.AppFeatureFlags>(),
        gh<_i363.PremiumEntitlementRepository>(),
      ),
    );
    gh.lazySingleton<_i693.SecureStorageService>(
      () => _i693.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i536.IncomingDocumentService>(
      () => _i222.PlatformIncomingDocumentService(),
    );
    gh.lazySingleton<_i363.PremiumEntitlementRepository>(
      () => _i514.LocalPremiumEntitlementRepository(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i824.DocumentStorageService>(
      () => _i848.AppFileStorageService(),
    );
    gh.lazySingleton<_i621.ReviewRepository>(
      () => _i931.DriftReviewRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.lazySingleton<_i55.SettingsRepository>(
      () => _i143.DriftSettingsRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.lazySingleton<_i899.DictionaryRepository>(
      () => _i66.MockDictionaryDataSource(),
    );
    gh.lazySingleton<_i304.DocumentEngineFactory>(
      () => _i996.LocalDocumentEngineFactory(),
    );
    gh.lazySingleton<_i732.OnboardingPreferences>(
      () => _i732.OnboardingPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i603.LibraryRepository>(
      () => _i623.DriftLibraryRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.singleton<_i514.ReviewCardUseCase>(
      () => _i514.ReviewCardUseCase(gh<_i621.ReviewRepository>()),
    );
    gh.lazySingleton<_i862.BackupRepository>(
      () => _i1066.LocalBackupRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.lazySingleton<_i798.BookmarkRepository>(
      () => _i487.DriftBookmarkRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.lazySingleton<_i190.Lemmatizer>(() => _i422.LocalEnglishLemmatizer());
    gh.lazySingleton<_i121.ReadingSessionRepository>(
      () => _i487.DriftReadingSessionRepository(gh<_i211.LinguaPageDatabase>()),
    );
    gh.singleton<_i879.GetLibraryBooksUseCase>(
      () => _i879.GetLibraryBooksUseCase(gh<_i603.LibraryRepository>()),
    );
    gh.singleton<_i322.SearchLibraryUseCase>(
      () => _i322.SearchLibraryUseCase(gh<_i603.LibraryRepository>()),
    );
    gh.singleton<_i214.SaveReadingProgressUseCase>(
      () => _i214.SaveReadingProgressUseCase(gh<_i603.LibraryRepository>()),
    );
    gh.lazySingleton<_i47.DocumentMetadataExtractor>(
      () => _i570.LocalDocumentMetadataExtractor(),
    );
    gh.singleton<_i590.CreateBackupUseCase>(
      () => _i590.CreateBackupUseCase(gh<_i862.BackupRepository>()),
    );
    gh.singleton<_i895.RestoreBackupUseCase>(
      () => _i895.RestoreBackupUseCase(gh<_i862.BackupRepository>()),
    );
    gh.lazySingleton<_i836.SentenceTranslationService>(
      () => _i940.LocalSentenceTranslationService(
        gh<_i899.DictionaryRepository>(),
        gh<_i190.Lemmatizer>(),
      ),
    );
    gh.singleton<_i185.RecapRepository>(
      () => _i637.MockRecapRepository(gh<_i101.AppFeatureFlags>()),
      registerFor: {_development},
    );
    gh.singleton<_i185.RecapRepository>(
      () => _i1007.DisabledRecapRepository(),
      registerFor: {_staging, _production},
    );
    gh.lazySingleton<_i536.DocumentImportService>(
      () => _i264.FilePickerDocumentImportService(
        gh<_i824.DocumentStorageService>(),
        gh<_i47.DocumentMetadataExtractor>(),
      ),
    );
    gh.singleton<_i809.LookupWordUseCase>(
      () => _i809.LookupWordUseCase(gh<_i899.DictionaryRepository>()),
    );
    gh.lazySingleton<_i407.ReviewNotificationScheduler>(
      () => _i897.LocalReviewNotificationScheduler(
        gh<_i621.ReviewRepository>(),
        gh<_i55.SettingsRepository>(),
      ),
    );
    gh.singleton<_i964.ImportDocumentUseCase>(
      () => _i964.ImportDocumentUseCase(
        gh<_i536.DocumentImportService>(),
        gh<_i603.LibraryRepository>(),
      ),
    );
    gh.singleton<_i486.DeleteLibraryBookUseCase>(
      () => _i486.DeleteLibraryBookUseCase(
        gh<_i603.LibraryRepository>(),
        gh<_i824.DocumentStorageService>(),
      ),
    );
    gh.singleton<_i592.TranslateSentenceUseCase>(
      () => _i592.TranslateSentenceUseCase(
        gh<_i836.SentenceTranslationService>(),
      ),
    );
    gh.factory<_i655.LibraryCubit>(
      () => _i655.LibraryCubit(
        gh<_i879.GetLibraryBooksUseCase>(),
        gh<_i486.DeleteLibraryBookUseCase>(),
        gh<_i964.ImportDocumentUseCase>(),
        gh<_i322.SearchLibraryUseCase>(),
        gh<_i536.IncomingDocumentService>(),
        gh<_i974.Logger>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i946.StorageModule {}

class _$LoggerModule extends _i946.LoggerModule {}

class _$FeatureFlagsModule extends _i946.FeatureFlagsModule {}

class _$DatabaseModule extends _i946.DatabaseModule {}
