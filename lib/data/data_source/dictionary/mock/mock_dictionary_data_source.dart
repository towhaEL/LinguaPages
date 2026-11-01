import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/core/env/app_environment.dart';
import 'package:lingua_pages/data/data_source/dictionary/dictionary_data_source.dart';
import 'package:lingua_pages/data/models/dictionary/dictionary_entry_model.dart';

/// Offline fixture used by the development flavor. Unknown words behave like
/// the real API's 404 response.
@LazySingleton(as: DictionaryDataSource, env: [AppEnvironment.development])
class MockDictionaryDataSource implements DictionaryDataSource {
  static const _license = LicenseModel(
    name: 'CC BY-SA 3.0',
    url: 'https://creativecommons.org/licenses/by-sa/3.0',
  );

  static const _entries = {
    'hello': DictionaryEntryModel(
      word: 'hello',
      phonetics: [PhoneticModel(text: '/həˈləʊ/')],
      meanings: [
        MeaningModel(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionModel(definition: '"Hello!" or an equivalent greeting.'),
          ],
          synonyms: ['greeting'],
        ),
        MeaningModel(
          partOfSpeech: 'interjection',
          definitions: [
            DefinitionModel(
              definition:
                  'A greeting (salutation) said when meeting someone or '
                  'acknowledging someone’s arrival or presence.',
              example: 'Hello, everyone.',
            ),
          ],
        ),
      ],
      license: _license,
      sourceUrls: ['https://en.wiktionary.org/wiki/hello'],
    ),
    'book': DictionaryEntryModel(
      word: 'book',
      phonetic: '/bʊk/',
      meanings: [
        MeaningModel(
          partOfSpeech: 'noun',
          definitions: [
            DefinitionModel(
              definition:
                  'A collection of sheets of paper bound together to hinge '
                  'at one edge, containing printed or written material.',
              example: 'I read a book every week.',
            ),
          ],
          synonyms: ['volume', 'tome'],
        ),
        MeaningModel(
          partOfSpeech: 'verb',
          definitions: [
            DefinitionModel(
              definition: 'To reserve something for future use.',
              example: 'We booked a table for two.',
            ),
          ],
          synonyms: ['reserve'],
        ),
      ],
      license: _license,
      sourceUrls: ['https://en.wiktionary.org/wiki/book'],
    ),
    'read': DictionaryEntryModel(
      word: 'read',
      phonetic: '/ɹiːd/',
      meanings: [
        MeaningModel(
          partOfSpeech: 'verb',
          definitions: [
            DefinitionModel(
              definition:
                  'To look at and interpret letters or other information '
                  'that is written.',
              example: 'She likes to read before bed.',
            ),
          ],
        ),
      ],
      license: _license,
      sourceUrls: ['https://en.wiktionary.org/wiki/read'],
    ),
  };

  @override
  Future<List<DictionaryEntryModel>> entries(String word) async {
    final entry = _entries[word];
    if (entry != null) return [entry];
    final requestOptions = RequestOptions(path: 'entries/en/$word');
    throw DioException.badResponse(
      statusCode: 404,
      requestOptions: requestOptions,
      response: Response(requestOptions: requestOptions, statusCode: 404),
    );
  }
}
