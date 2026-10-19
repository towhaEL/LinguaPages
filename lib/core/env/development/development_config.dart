import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/core/env/env.dart';

class DevelopmentConfig extends Env {
  @override
  String name = AppEnvironment.development;
  @override
  String baseUrl = 'https://jsonplaceholder.typicode.com';
}
