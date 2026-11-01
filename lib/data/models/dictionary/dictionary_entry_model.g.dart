// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntryModel _$DictionaryEntryModelFromJson(
  Map<String, dynamic> json,
) => DictionaryEntryModel(
  word: json['word'] as String,
  phonetic: json['phonetic'] as String?,
  phonetics:
      (json['phonetics'] as List<dynamic>?)
          ?.map((e) => PhoneticModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meanings:
      (json['meanings'] as List<dynamic>?)
          ?.map((e) => MeaningModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  license: json['license'] == null
      ? null
      : LicenseModel.fromJson(json['license'] as Map<String, dynamic>),
  sourceUrls:
      (json['sourceUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$DictionaryEntryModelToJson(
  DictionaryEntryModel instance,
) => <String, dynamic>{
  'word': instance.word,
  'phonetic': instance.phonetic,
  'phonetics': instance.phonetics.map((e) => e.toJson()).toList(),
  'meanings': instance.meanings.map((e) => e.toJson()).toList(),
  'license': instance.license?.toJson(),
  'sourceUrls': instance.sourceUrls,
};

PhoneticModel _$PhoneticModelFromJson(Map<String, dynamic> json) =>
    PhoneticModel(
      text: json['text'] as String?,
      audio: json['audio'] as String?,
    );

Map<String, dynamic> _$PhoneticModelToJson(PhoneticModel instance) =>
    <String, dynamic>{'text': instance.text, 'audio': instance.audio};

MeaningModel _$MeaningModelFromJson(Map<String, dynamic> json) => MeaningModel(
  partOfSpeech: json['partOfSpeech'] as String,
  definitions:
      (json['definitions'] as List<dynamic>?)
          ?.map((e) => DefinitionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  synonyms:
      (json['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  antonyms:
      (json['antonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$MeaningModelToJson(MeaningModel instance) =>
    <String, dynamic>{
      'partOfSpeech': instance.partOfSpeech,
      'definitions': instance.definitions.map((e) => e.toJson()).toList(),
      'synonyms': instance.synonyms,
      'antonyms': instance.antonyms,
    };

DefinitionModel _$DefinitionModelFromJson(
  Map<String, dynamic> json,
) => DefinitionModel(
  definition: json['definition'] as String,
  example: json['example'] as String?,
  synonyms:
      (json['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  antonyms:
      (json['antonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$DefinitionModelToJson(DefinitionModel instance) =>
    <String, dynamic>{
      'definition': instance.definition,
      'example': instance.example,
      'synonyms': instance.synonyms,
      'antonyms': instance.antonyms,
    };

LicenseModel _$LicenseModelFromJson(Map<String, dynamic> json) =>
    LicenseModel(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$LicenseModelToJson(LicenseModel instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};
