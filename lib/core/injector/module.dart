import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingua_pages/core/env/env.dart';
import 'package:lingua_pages/core/feature_flags/app_feature_flags.dart';
import 'package:lingua_pages/data/data_source/library/local/lingua_page_database.dart';

@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage =>
      const FlutterSecureStorage(aOptions: AndroidOptions());

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}

@module
abstract class LoggerModule {
  @lazySingleton
  Logger get logger => Logger();
}

@module
abstract class FeatureFlagsModule {
  @lazySingleton
  AppFeatureFlags get featureFlags =>
      AppFeatureFlags.forEnvironment(Env.shared.name);
}

@module
abstract class DatabaseModule {
  @lazySingleton
  LinguaPageDatabase get database => LinguaPageDatabase.defaults();
}
