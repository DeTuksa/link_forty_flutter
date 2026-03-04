// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';
import 'utm_parameters.dart';

part 'deep_link_data.g.dart';

/// Deep link data returned from attribution or direct deep links
@JsonSerializable(explicitToJson: true)
class DeepLinkData {
  /// The short code of the link (e.g., "abc123")
  final String shortCode;

  /// iOS-specific URL (Universal Link or custom scheme)
  @JsonKey(name: 'iosUrl')
  final String? iosURL;

  /// Android-specific URL (App Link or custom scheme)
  @JsonKey(name: 'androidUrl')
  final String? androidURL;

  /// Web fallback URL
  @JsonKey(name: 'webUrl')
  final String? webURL;

  /// UTM parameters from the link
  final UTMParameters? utmParameters;

  /// Custom query parameters from the link
  final Map<String, String>? customParameters;

  /// Deep link path for in-app routing (e.g., "/product/123")
  final String? deepLinkPath;

  /// App URI scheme (e.g., "myapp")
  final String? appScheme;

  /// When the link was clicked (for attributed installs)
  @JsonKey(
    name: 'clickedAt',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime? clickedAt;

  /// The link ID from the backend
  final String? linkId;

  /// Creates deep link data
  const DeepLinkData({
    required this.shortCode,
    this.iosURL,
    this.androidURL,
    this.webURL,
    this.utmParameters,
    this.customParameters,
    this.deepLinkPath,
    this.appScheme,
    this.clickedAt,
    this.linkId,
  });

  /// JSON deserialization
  factory DeepLinkData.fromJson(Map<String, dynamic> json) =>
      _$DeepLinkDataFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$DeepLinkDataToJson(this);

  /// Parses ISO 8601 date string to DateTime
  static DateTime? _dateTimeFromJson(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }

  /// Converts DateTime to ISO 8601 string
  static String? _dateTimeToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  @override
  String toString() {
    return '''DeepLinkData(
    shortCode: $shortCode,
    iosURL: ${iosURL ?? 'null'},
    deepLinkPath: ${deepLinkPath ?? 'null'},
    appScheme: ${appScheme ?? 'null'},
    linkId: ${linkId ?? 'null'},
    utmSource: ${utmParameters?.source ?? 'null'}
)''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeepLinkData &&
          runtimeType == other.runtimeType &&
          shortCode == other.shortCode &&
          iosURL == other.iosURL &&
          androidURL == other.androidURL &&
          webURL == other.webURL &&
          utmParameters == other.utmParameters &&
          _mapEquals(customParameters, other.customParameters) &&
          deepLinkPath == other.deepLinkPath &&
          appScheme == other.appScheme &&
          clickedAt == other.clickedAt &&
          linkId == other.linkId;

  @override
  int get hashCode =>
      shortCode.hashCode ^
      iosURL.hashCode ^
      androidURL.hashCode ^
      webURL.hashCode ^
      utmParameters.hashCode ^
      _mapHashCode(customParameters) ^
      deepLinkPath.hashCode ^
      appScheme.hashCode ^
      clickedAt.hashCode ^
      linkId.hashCode;

  /// Helper for map equality comparison
  static bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  /// Helper for map hash code
  static int _mapHashCode(Map<String, String>? map) {
    if (map == null) return 0;
    return map.entries.fold(
      0,
      (hash, entry) => hash ^ entry.key.hashCode ^ entry.value.hashCode,
    );
  }
}
