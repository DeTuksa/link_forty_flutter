// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_link_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLinkResult _$CreateLinkResultFromJson(Map<String, dynamic> json) =>
    CreateLinkResult(
      url: json['url'] as String,
      shortCode: json['shortCode'] as String,
      linkId: json['linkId'] as String,
      deduplicated: json['deduplicated'] as bool?,
    );

Map<String, dynamic> _$CreateLinkResultToJson(CreateLinkResult instance) =>
    <String, dynamic>{
      'url': instance.url,
      'shortCode': instance.shortCode,
      'linkId': instance.linkId,
      'deduplicated': instance.deduplicated,
    };
