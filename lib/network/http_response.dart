// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Raw HTTP response container
class HttpResponse {
  final int statusCode;
  final Uint8List body;

  const HttpResponse({required this.statusCode, required this.body});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpResponse &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          _bytesEqual(body, other.body);

  @override
  int get hashCode => statusCode.hashCode ^ _bytesHashCode(body);

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _bytesHashCode(Uint8List bytes) {
    return bytes.fold(0, (hash, byte) => hash ^ byte.hashCode);
  }
}
