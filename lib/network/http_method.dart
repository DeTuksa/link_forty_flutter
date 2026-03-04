// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

/// HTTP methods supported by the SDK
enum HttpMethod { get, post, put, delete }

/// Extension to provide string values for HttpMethod
extension HttpMethodExtension on HttpMethod {
  /// The string representation of the HTTP method
  String get value {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }
}
