// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'utm_parameters.g.dart';

/// UTM parameters for campaign tracking
@JsonSerializable()
class UTMParameters {
  /// Campaign source (e.g., "google", "facebook", "email")
  final String? source;

  /// Campaign medium (e.g., "cpc", "banner", "email")
  final String? medium;

  /// Campaign name (e.g., "summer_sale", "product_launch")
  final String? campaign;

  /// Campaign term (e.g., "running+shoes")
  final String? term;

  /// Campaign content (e.g., "logolink", "textlink")
  final String? content;

  /// Creates UTM parameters
  const UTMParameters({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  /// Checks if any UTM parameter is set
  bool get hasAnyParameter =>
      source != null ||
      medium != null ||
      campaign != null ||
      term != null ||
      content != null;

  /// JSON serialization
  factory UTMParameters.fromJson(Map<String, dynamic> json) =>
      _$UTMParametersFromJson(json);

  /// JSON deserialization
  Map<String, dynamic> toJson() => _$UTMParametersToJson(this);

  @override
  String toString() {
    final parts = <String>[];
    if (source != null) parts.add('source=$source');
    if (medium != null) parts.add('medium=$medium');
    if (campaign != null) parts.add('campaign=$campaign');
    if (term != null) parts.add('term=$term');
    if (content != null) parts.add('content=$content');
    return 'UTMParameters(${parts.join(', ')})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UTMParameters &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          medium == other.medium &&
          campaign == other.campaign &&
          term == other.term &&
          content == other.content;

  @override
  int get hashCode =>
      source.hashCode ^
      medium.hashCode ^
      campaign.hashCode ^
      term.hashCode ^
      content.hashCode;
}
