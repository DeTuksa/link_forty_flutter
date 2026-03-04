// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import '../link_forty_logger.dart';
import '../models/install_response.dart';
import '../models/deep_link_data.dart';
import '../network/network_manager.dart';
import '../network/http_method.dart';
import '../storage/storage_manager.dart';
import '../fingerprint/fingerprint_collector.dart';
import '../errors/link_forty_error.dart';

/// Manages install attribution and deferred deep linking
class AttributionManager {
  final NetworkManagerProtocol _networkManager;
  final StorageManagerProtocol _storageManager;
  final FingerprintCollectorProtocol _fingerprintCollector;

  /// Creates an attribution manager
  ///
  /// - [networkManager]: Network manager for API requests
  /// - [storageManager]: Storage manager for caching data
  /// - [fingerprintCollector]: Fingerprint collector for device data
  AttributionManager({
    required NetworkManagerProtocol networkManager,
    required StorageManagerProtocol storageManager,
    required FingerprintCollectorProtocol fingerprintCollector,
  }) : _networkManager = networkManager,
       _storageManager = storageManager,
       _fingerprintCollector = fingerprintCollector;

  // MARK: - Install Attribution

  /// Reports an install to the backend and retrieves attribution data
  ///
  /// On first launch (no stored installId): collects fingerprint and POSTs to
  /// the server. If the network call fails, treats the install as organic and
  /// returns a synthetic response so the SDK remains operational.
  ///
  /// On subsequent launches (installId already stored): loads cached attribution
  /// data from local storage without a network call.
  ///
  /// - [attributionWindowHours]: Attribution window in hours
  /// - [deviceId]: Optional device ID (IDFA/IDFV/GAID) if user consented
  /// - Returns: Install response with attribution data
  Future<InstallResponse> reportInstall({
    required int attributionWindowHours,
    String? deviceId,
  }) async {
    // --- Subsequent launch: return cached data, no network call ---
    final storedInstallId = _storageManager.getInstallId();
    if (storedInstallId != null) {
      final cachedData = _storageManager.getInstallData();
      LinkFortyLogger.log(
        'Subsequent launch — loading cached attribution (installId: $storedInstallId)',
      );
      return InstallResponse(
        installId: storedInstallId,
        attributed: cachedData != null,
        confidenceScore: cachedData != null ? 100.0 : 0.0,
        matchedFactors: const [],
        deepLinkData: cachedData,
      );
    }

    // --- First launch: collect fingerprint and report install ---
    final fingerprint = await _fingerprintCollector.collectFingerprint(
      attributionWindowHours: attributionWindowHours,
      deviceId: deviceId,
    );

    LinkFortyLogger.log('Reporting install with fingerprint: $fingerprint');

    InstallResponse response;
    try {
      response = await _networkManager.request<InstallResponse>(
        endpoint: '/api/sdk/v1/install',
        method: HttpMethod.post,
        body: fingerprint.toJson(),
        fromJson: (json) => InstallResponse.fromJson(json),
      );
      LinkFortyLogger.log('Install response: $response');
    } on LinkFortyError catch (e) {
      // Treat network failure as organic so the SDK remains operational.
      // The install can be re-attributed on the next launch if no installId
      // was persisted (i.e., the failure path does not call setHasLaunched).
      LinkFortyLogger.log(
        'Install network call failed — treating as organic. Error: $e',
      );
      return InstallResponse(
        installId: '',
        attributed: false,
        confidenceScore: 0.0,
        matchedFactors: const [],
      );
    }

    // Cache install ID
    await _storageManager.saveInstallId(response.installId);

    // Cache deep link data if attributed
    final deepLinkData = response.deepLinkData;
    if (deepLinkData != null) {
      await _storageManager.saveInstallData(deepLinkData);
      LinkFortyLogger.log(
        'Install attributed with confidence: ${response.confidenceScore}%',
      );
    } else {
      LinkFortyLogger.log('Organic install (no attribution)');
    }

    // Mark that app has launched (only on successful reporting)
    await _storageManager.setHasLaunched();

    return response;
  }

  // MARK: - Data Retrieval

  /// Retrieves the install ID
  ///
  /// - Returns: Install ID if available, null otherwise
  String? getInstallId() {
    return _storageManager.getInstallId();
  }

  /// Retrieves the cached install attribution data
  ///
  /// - Returns: Deep link data if available, null otherwise
  DeepLinkData? getInstallData() {
    return _storageManager.getInstallData();
  }

  /// Checks if this is the first launch
  ///
  /// - Returns: True if first launch, false otherwise
  bool isFirstLaunch() {
    return _storageManager.isFirstLaunch();
  }

  // MARK: - Data Management

  /// Clears all cached attribution data
  Future<void> clearData() async {
    await _storageManager.clearAll();
    LinkFortyLogger.log('Attribution data cleared');
  }
}
