// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

/// HTTP methods supported by the SDK
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String value;

  const HttpMethod(this.value);
}