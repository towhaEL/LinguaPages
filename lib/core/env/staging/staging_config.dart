import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/core/env/env.dart';

class StagingConfig extends Env {
  @override
  String name = AppEnvironment.staging;
  @override
  String baseUrl = 'https://jsonplaceholder.typicode.com';
}
