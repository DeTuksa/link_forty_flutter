// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'create_link_result.g.dart';

/// Result of creating a short link
@JsonSerializable()
class CreateLinkResult {
  /// Full shareable URL (e.g., "https://go.yourdomain.com/tmpl/abc123")
  final String url;

  /// The generated short code
  final String shortCode;

  /// Link UUID
  final String linkId;

  /// Creates a link creation result
  const CreateLinkResult({
    required this.url,
    required this.shortCode,
    required this.linkId,
  });

  /// JSON deserialization
  factory CreateLinkResult.fromJson(Map<String, dynamic> json) =>
      _$CreateLinkResultFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$CreateLinkResultToJson(this);

  @override
  String toString() =>
      'CreateLinkResult(url: $url, shortCode: $shortCode, linkId: $linkId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLinkResult &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          shortCode == other.shortCode &&
          linkId == other.linkId;

  @override
  int get hashCode => url.hashCode ^ shortCode.hashCode ^ linkId.hashCode;
}
