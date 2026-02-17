// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import '../models/link_forty_config.dart';
import '../errors/link_forty_error.dart';
import '../link_forty_logger.dart';
import 'http_client.dart';
import 'http_method.dart';
import 'http_response.dart';

/// Protocol for dependency injection in tests
abstract class NetworkManagerProtocol {
  Future<T> request<T>({
    required String endpoint,
    required HttpMethod method,
    Object? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  });
}

/// Manages network requests for the SDK
class NetworkManager implements NetworkManagerProtocol {
  final LinkFortyConfig _config;
  final HttpClient _httpClient;

  /// Maximum number of retry attempts
  static const int _maxRetries = 3;

  NetworkManager({required LinkFortyConfig config, HttpClient? httpClient})
    : _config = config,
      _httpClient = httpClient ?? HttpClientImpl();

  /// Performs a network request with automatic retry and decodes the response
  ///
  /// - [endpoint]: API endpoint path (e.g., "/api/sdk/v1/install")
  /// - [method]: HTTP method
  /// - [body]: Optional request body (will be serialized to JSON)
  /// - [headers]: Optional additional headers
  /// - [fromJson]: Function to decode the response
  /// - Returns: Decoded response of type T
  /// - Throws: [LinkFortyError] on failure
  @override
  Future<T> request<T>({
    required String endpoint,
    required HttpMethod method,
    Object? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    LinkFortyError? lastError;

    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _performRequest<T>(
          endpoint: endpoint,
          method: method,
          body: body,
          headers: headers,
          fromJson: fromJson,
        );
      } catch (e) {
        // If it's already a LinkFortyError (from above rethrow), just rethrow it
        if (e is LinkFortyError) {
          rethrow;
        }

        // Otherwise wrap it
        lastError = NetworkError(e);

        // Exponential backoff: 1s, 2s, 4s
        if (attempt < _maxRetries) {
          final delaySeconds = math.pow(2.0, attempt - 1).toInt();
          LinkFortyLogger.log(
            'Request failed (attempt $attempt/$_maxRetries), retrying in ${delaySeconds}s... Error: $e',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }
    }

    throw lastError ??
        NetworkError(Exception('Request failed after $_maxRetries attempts'));
  }

  // MARK: - Private Methods

  /// Performs a single network request
  Future<T> _performRequest<T>({
    required String endpoint,
    required HttpMethod method,
    Object? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    // Build URL
    final baseUrl = _config.baseURL.toString().replaceAll(RegExp(r'/$'), '');
    final url = '$baseUrl$endpoint';

    // Build headers
    final requestHeaders = <String, String>{'Content-Type': 'application/json'};

    // Add API key if present
    if (_config.apiKey != null) {
      requestHeaders['Authorization'] = 'Bearer ${_config.apiKey}';
    }

    // Add custom headers
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Encode body
    Uint8List? bodyBytes;
    if (body != null) {
      try {
        final jsonString = jsonEncode(body);
        bodyBytes = Uint8List.fromList(utf8.encode(jsonString));
      } catch (e) {
        throw EncodingError(e);
      }
    }

    // Log request in debug mode
    if (_config.debug) {
      _logRequest(method, url, bodyBytes);
    }

    // Perform request
    final response = await _httpClient.execute(
      url: url,
      method: method,
      body: bodyBytes,
      headers: requestHeaders,
    );

    // Log response in debug mode
    if (_config.debug) {
      _logResponse(response);
    }

    // Check status code
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = utf8.decode(response.body);
      throw InvalidResponseError(
        statusCode: response.statusCode,
        responseMessage: message,
      );
    }

    // Decode response
    try {
      final jsonString = utf8.decode(response.body);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } on LinkFortyError {
      rethrow;
    } catch (e) {
      throw DecodingError(e);
    }
  }

  // MARK: - Logging

  void _logRequest(HttpMethod method, String url, Uint8List? body) {
    final buffer = StringBuffer('[LinkForty] → ${method.value} $url');

    if (_config.apiKey != null) {
      final apiKey = _config.apiKey!;
      final maskedKey = apiKey.length > 4
          ? '***${apiKey.substring(apiKey.length - 4)}'
          : '***';
      buffer.write('\n  Authorization: Bearer $maskedKey');
    }

    if (body != null) {
      final jsonString = utf8.decode(body);
      buffer.write('\n  Body: $jsonString');
    }

    LinkFortyLogger.log(buffer.toString());
  }

  void _logResponse(HttpResponse response) {
    final buffer = StringBuffer('[LinkForty] ← ${response.statusCode}');
    final jsonString = utf8.decode(response.body);
    buffer.write('\n  Response: $jsonString');
    LinkFortyLogger.log(buffer.toString());
  }
}
