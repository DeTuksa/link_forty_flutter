// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'device_fingerprint.g.dart';

/// Device fingerprint for attribution matching
@JsonSerializable()
class DeviceFingerprint {
  /// User-Agent string (e.g., "MyApp/1.0 iOS/15.0")
  final String userAgent;

  /// Timezone identifier (e.g., "America/New_York")
  final String timezone;

  /// Preferred language (e.g., "en-US")
  final String language;

  /// Screen width in pixels
  final int screenWidth;

  /// Screen height in pixels
  final int screenHeight;

  /// Platform name (e.g., "Android", "iOS")
  final String platform;

  /// Platform version (e.g., "15.0", "13")
  final String platformVersion;

  /// App version (e.g., "1.0.0")
  final String appVersion;

  /// Optional device ID (IDFA, IDFV, GAID, or custom) - only if user consented
  final String? deviceId;

  /// Attribution window in hours
  final int attributionWindowHours;

  /// Creates a device fingerprint
  const DeviceFingerprint({
    required this.userAgent,
    required this.timezone,
    required this.language,
    required this.screenWidth,
    required this.screenHeight,
    required this.platform,
    required this.platformVersion,
    required this.appVersion,
    this.deviceId,
    required this.attributionWindowHours,
  });

  /// JSON deserialization
  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) =>
      _$DeviceFingerprintFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$DeviceFingerprintToJson(this);

  @override
  String toString() {
    return '''DeviceFingerprint(
    userAgent: $userAgent,
    timezone: $timezone,
    language: $language,
    screen: ${screenWidth}x$screenHeight,
    platform: $platform $platformVersion,
    appVersion: $appVersion
)''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceFingerprint &&
          runtimeType == other.runtimeType &&
          userAgent == other.userAgent &&
          timezone == other.timezone &&
          language == other.language &&
          screenWidth == other.screenWidth &&
          screenHeight == other.screenHeight &&
          platform == other.platform &&
          platformVersion == other.platformVersion &&
          appVersion == other.appVersion &&
          deviceId == other.deviceId &&
          attributionWindowHours == other.attributionWindowHours;

  @override
  int get hashCode =>
      userAgent.hashCode ^
      timezone.hashCode ^
      language.hashCode ^
      screenWidth.hashCode ^
      screenHeight.hashCode ^
      platform.hashCode ^
      platformVersion.hashCode ^
      appVersion.hashCode ^
      deviceId.hashCode ^
      attributionWindowHours.hashCode;
}
