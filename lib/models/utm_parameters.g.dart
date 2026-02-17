// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utm_parameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UTMParameters _$UTMParametersFromJson(Map<String, dynamic> json) =>
    UTMParameters(
      source: json['source'] as String?,
      medium: json['medium'] as String?,
      campaign: json['campaign'] as String?,
      term: json['term'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$UTMParametersToJson(UTMParameters instance) =>
    <String, dynamic>{
      'source': instance.source,
      'medium': instance.medium,
      'campaign': instance.campaign,
      'term': instance.term,
      'content': instance.content,
    };
