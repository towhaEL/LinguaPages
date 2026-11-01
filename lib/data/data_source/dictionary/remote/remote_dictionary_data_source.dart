import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/data/data_source/dictionary/dictionary_data_source.dart';
import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';
import 'package:retrofit/retrofit.dart';

part 'remote_dictionary_data_source.g.dart';

/// Free Dictionary API (Wiktionary content, CC BY-SA 3.0).
@RestApi(baseUrl: 'https://api.dictionaryapi.dev/api/v2/')
@LazySingleton(
  as: DictionaryDataSource,
  env: [AppEnvironment.staging, AppEnvironment.production],
)
abstract class RemoteDictionaryDataSource implements DictionaryDataSource {
  @factoryMethod
  factory RemoteDictionaryDataSource(Dio dio) = _RemoteDictionaryDataSource;

  @override
  @GET('entries/en/{word}')
  Future<List<DictionaryEntryModel>> entries(@Path('word') String word);
}
