// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallResponse _$InstallResponseFromJson(Map<String, dynamic> json) =>
    InstallResponse(
      installId: json['installId'] as String,
      attributed: json['attributed'] as bool,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      matchedFactors: (json['matchedFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deepLinkData: json['deepLinkData'] == null
          ? null
          : DeepLinkData.fromJson(json['deepLinkData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InstallResponseToJson(InstallResponse instance) =>
    <String, dynamic>{
      'installId': instance.installId,
      'attributed': instance.attributed,
      'confidenceScore': instance.confidenceScore,
      'matchedFactors': instance.matchedFactors,
      'deepLinkData': instance.deepLinkData,
    };
