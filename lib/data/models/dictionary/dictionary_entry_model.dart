import 'package:json_annotation/json_annotation.dart';

part 'dictionary_entry_model.g.dart';

/// Response item of `GET https://api.dictionaryapi.dev/api/v2/entries/en/<word>`.
/// The same JSON is stored in the local cache.
@JsonSerializable(explicitToJson: true)
class DictionaryEntryModel {
  const DictionaryEntryModel({
    required this.word,
    this.phonetic,
    this.phonetics = const [],
    this.meanings = const [],
    this.license,
    this.sourceUrls = const [],
  });

  factory DictionaryEntryModel.fromJson(Map<String, dynamic> json) =>
      _$DictionaryEntryModelFromJson(json);

  final String word;
  final String? phonetic;
  final List<PhoneticModel> phonetics;
  final List<MeaningModel> meanings;
  final LicenseModel? license;
  final List<String> sourceUrls;

  Map<String, dynamic> toJson() => _$DictionaryEntryModelToJson(this);
}

@JsonSerializable()
class PhoneticModel {
  const PhoneticModel({this.text, this.audio});

  factory PhoneticModel.fromJson(Map<String, dynamic> json) =>
      _$PhoneticModelFromJson(json);

  final String? text;
  final String? audio;

  Map<String, dynamic> toJson() => _$PhoneticModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MeaningModel {
  const MeaningModel({
    required this.partOfSpeech,
    this.definitions = const [],
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory MeaningModel.fromJson(Map<String, dynamic> json) =>
      _$MeaningModelFromJson(json);

  final String partOfSpeech;
  final List<DefinitionModel> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  Map<String, dynamic> toJson() => _$MeaningModelToJson(this);
}

@JsonSerializable()
class DefinitionModel {
  const DefinitionModel({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory DefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$DefinitionModelFromJson(json);

  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  Map<String, dynamic> toJson() => _$DefinitionModelToJson(this);
}

@JsonSerializable()
class LicenseModel {
  const LicenseModel({required this.name, required this.url});

  factory LicenseModel.fromJson(Map<String, dynamic> json) =>
      _$LicenseModelFromJson(json);

  final String name;
  final String url;

  Map<String, dynamic> toJson() => _$LicenseModelToJson(this);
}
