// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

part 'dashboard_create_link_response.g.dart';

/// Response from the dashboard link creation endpoint (POST /api/links)
/// Maps the snake_case response to CreateLinkResult@JsonSerializable()
@JsonSerializable()
class DashboardCreateLinkResponse {
    /// The id
    final String id;

    /// The generated short code
    final String shortCode;

    const DashboardCreateLinkResponse({
        required this.id,
        required this.shortCode,
    });

    /// JSON deserialization
    factory DashboardCreateLinkResponse.fromJson(Map<String, dynamic> json) =>
        _$DashboardCreateLinkResponseFromJson(json);

    /// JSON serialization
    Map<String, dynamic> toJson() => _$DashboardCreateLinkResponseToJson(this);

    @override
    String toString() =>
        'DashboardCreateLinkResponse(id: $id, shortCode: $shortCode)';

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
        other is DashboardCreateLinkResponse &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            shortCode == other.shortCode;

    @override
    int get hashCode => id.hashCode ^ shortCode.hashCode;
}
