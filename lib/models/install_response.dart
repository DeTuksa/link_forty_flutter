// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';
import 'deep_link_data.dart';

part 'install_response.g.dart';

/// The server response containing attribution information for an app install.
@JsonSerializable(explicitToJson: true)
class InstallResponse {
  /// Identifies the unique app installation on the LinkForty backend.
  final String installId;

  /// Whether this install was attributed to a link click
  final bool attributed;

  /// Confidence score for attribution (0-100)
  final double confidenceScore;

  /// Which fingerprint factors matched
  final List<String> matchedFactors;

  /// Deep link data if attributed, null if organic
  final DeepLinkData? deepLinkData;

  /// Creates an install response
  const InstallResponse({
    required this.installId,
    required this.attributed,
    required this.confidenceScore,
    required this.matchedFactors,
    this.deepLinkData,
  });

  /// JSON deserialization
  factory InstallResponse.fromJson(Map<String, dynamic> json) =>
      _$InstallResponseFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$InstallResponseToJson(this);

  @override
  String toString() {
    return '''InstallResponse(
    installId: $installId,
    attributed: $attributed,
    confidenceScore: $confidenceScore,
    matchedFactors: $matchedFactors
)''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallResponse &&
          runtimeType == other.runtimeType &&
          installId == other.installId &&
          attributed == other.attributed &&
          confidenceScore == other.confidenceScore &&
          _listEquals(matchedFactors, other.matchedFactors) &&
          deepLinkData == other.deepLinkData;

  @override
  int get hashCode =>
      installId.hashCode ^
      attributed.hashCode ^
      confidenceScore.hashCode ^
      _listHashCode(matchedFactors) ^
      deepLinkData.hashCode;

  /// Helper for list equality comparison
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Helper for list hash code
  static int _listHashCode(List<String> list) {
    return list.fold(0, (hash, item) => hash ^ item.hashCode);
  }
}
