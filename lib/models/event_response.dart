// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'event_response.g.dart';

/// Response from event tracking endpoint
@JsonSerializable()
class EventResponse {
  /// Whether the event was successfully tracked
  final bool success;

  /// Creates an event response
  const EventResponse({
    required this.success,
  });

  /// JSON deserialization
  factory EventResponse.fromJson(Map<String, dynamic> json) =>
      _$EventResponseFromJson(json);

  /// JSON serialization
  Map<String, dynamic> toJson() => _$EventResponseToJson(this);

  @override
  String toString() => 'EventResponse(success: $success)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventResponse &&
          runtimeType == other.runtimeType &&
          success == other.success;

  @override
  int get hashCode => success.hashCode;
}
