// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';
import 'utm_parameters.dart';

part 'create_link_options.g.dart';

/// Options for creating a short link
@JsonSerializable()
class CreateLinkOptions {
  /// Template ID (auto-selected if omitted)
  final String? templateId;

  /// Template slug (only needed with templateId)
  final String? templateSlug;

  /// Deep link parameters for in-app routing (e.g., {"route": "VIDEO_VIEWER", "id": "..."})
  final Map<String, String>? deepLinkParameters;

  /// Link title
  final String? title;

  /// Link description
  final String? description;

  /// Custom short code (auto-generated if omitted)
  final String? customCode;

  /// UTM parameters for campaign tracking
  final UTMParameters? utmParameters;

  /// Creates link creation options
  const CreateLinkOptions({
    this.templateId,
    this.templateSlug,
    this.deepLinkParameters,
    this.title,
    this.description,
    this.customCode,
    this.utmParameters,
  });

  /// JSON serialization
  factory CreateLinkOptions.fromJson(Map<String, dynamic> json) =>
      _$CreateLinkOptionsFromJson(json);

  /// JSON deserialization
  Map<String, dynamic> toJson() => _$CreateLinkOptionsToJson(this);
}