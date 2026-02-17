// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_fingerprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceFingerprint _$DeviceFingerprintFromJson(Map<String, dynamic> json) =>
    DeviceFingerprint(
      userAgent: json['userAgent'] as String,
      timezone: json['timezone'] as String,
      language: json['language'] as String,
      screenWidth: (json['screenWidth'] as num).toInt(),
      screenHeight: (json['screenHeight'] as num).toInt(),
      platform: json['platform'] as String,
      platformVersion: json['platformVersion'] as String,
      appVersion: json['appVersion'] as String,
      deviceId: json['deviceId'] as String?,
      attributionWindowHours: (json['attributionWindowHours'] as num).toInt(),
    );

Map<String, dynamic> _$DeviceFingerprintToJson(DeviceFingerprint instance) =>
    <String, dynamic>{
      'userAgent': instance.userAgent,
      'timezone': instance.timezone,
      'language': instance.language,
      'screenWidth': instance.screenWidth,
      'screenHeight': instance.screenHeight,
      'platform': instance.platform,
      'platformVersion': instance.platformVersion,
      'appVersion': instance.appVersion,
      'deviceId': instance.deviceId,
      'attributionWindowHours': instance.attributionWindowHours,
    };
