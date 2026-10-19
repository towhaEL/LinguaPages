import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/core/env/env.dart';

class ProductionConfig extends Env {
  @override
  String name = AppEnvironment.production;
  @override
  String baseUrl = 'https://jsonplaceholder.typicode.com';
}
