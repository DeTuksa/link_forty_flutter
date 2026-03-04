// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import '../models/deep_link_data.dart';
import '../models/utm_parameters.dart';

/// Utility for parsing URLs and extracting parameters
class URLParser {
  // Private constructor to prevent instantiation
  const URLParser._();

  /// Extracts the short code from a URL path
  ///
  /// Short code is typically the last path component
  /// e.g., https://go.example.com/abc123 -> "abc123"
  ///
  /// - [url]: The URL to parse
  /// - Returns: Short code if found, null otherwise
  static String? extractShortCode(Uri url) {
    final pathSegments = url.pathSegments.where((s) => s.isNotEmpty).toList();
    return pathSegments.isNotEmpty ? pathSegments.last : null;
  }

  /// Extracts UTM parameters from URL query
  ///
  /// - [url]: The URL to parse
  /// - Returns: UTM parameters if any are found, null otherwise
  static UTMParameters? extractUTMParameters(Uri url) {
    final params = url.queryParameters;

    final utmSource = params['utm_source'];
    final utmMedium = params['utm_medium'];
    final utmCampaign = params['utm_campaign'];
    final utmTerm = params['utm_term'];
    final utmContent = params['utm_content'];

    // Only create UTM parameters if at least one is present
    if (utmSource == null &&
        utmMedium == null &&
        utmCampaign == null &&
        utmTerm == null &&
        utmContent == null) {
      return null;
    }

    return UTMParameters(
      source: utmSource,
      medium: utmMedium,
      campaign: utmCampaign,
      term: utmTerm,
      content: utmContent,
    );
  }

  /// Extracts custom (non-UTM) query parameters from URL
  ///
  /// - [url]: The URL to parse
  /// - Returns: Map of custom parameters, empty if none found
  static Map<String, String> extractCustomParameters(Uri url) {
    final utmKeys = {
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
    };

    final customParams = <String, String>{};
    final params = url.queryParameters;

    for (final entry in params.entries) {
      // Skip UTM parameters
      if (!utmKeys.contains(entry.key)) {
        customParams[entry.key] = entry.value;
      }
    }

    return customParams;
  }

  /// Parses a URL into DeepLinkData
  ///
  /// - [url]: The URL to parse
  /// - Returns: DeepLinkData with extracted information, null if no short code found
  static DeepLinkData? parseDeepLink(Uri url) {
    final shortCode = extractShortCode(url);
    if (shortCode == null) {
      return null;
    }

    final utmParameters = extractUTMParameters(url);
    final customParameters = extractCustomParameters(url);

    // Determine platform-specific URL field
    // In Flutter, we set both iosURL and androidURL to the same value
    // or you can use Platform.isIOS/Platform.isAndroid to set conditionally
    return DeepLinkData(
      shortCode: shortCode,
      iosURL: url.toString(),
      androidURL: url.toString(),
      utmParameters: utmParameters,
      customParameters: customParameters.isNotEmpty ? customParameters : null,
    );
  }
}
