// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'link_forty_logger.dart';
import 'models/link_forty_config.dart';
import 'models/install_response.dart';
import 'models/deep_link_data.dart';
import 'models/create_link_options.dart';
import 'models/create_link_result.dart';
import 'models/dashboard_create_link_response.dart';
import 'network/network_manager.dart';
import 'network/http_method.dart';
import 'storage/storage_manager.dart';
import 'fingerprint/fingerprint_collector.dart';
import 'attribution/attribution_manager.dart';
import 'events/event_tracker.dart';
import 'deeplink/deeplink_handler.dart';
import 'errors/link_forty_error.dart';

/// Main SDK class - singleton interface for LinkForty
///
/// Usage:
/// ```dart
/// final config = LinkFortyConfig(
///   baseURL: Uri.parse('https://go.yourdomain.com'),
///   apiKey: 'your-api-key',
/// );
/// final response = await LinkForty.instance.initialize(config: config);
/// ```
class LinkForty {
  // MARK: - Singleton

  static LinkForty? _instance;

  /// Shared instance. Throws [NotInitializedError] if not yet initialized.
  static LinkForty get instance {
    final inst = _instance;
    if (inst == null) {
      throw const NotInitializedError();
    }
    return inst;
  }

  /// Shared instance (nullable). Returns null if not initialized.
  static LinkForty? get instanceOrNull => _instance;

  // MARK: - Properties

  LinkFortyConfig? _config;
  NetworkManager? _networkManager;
  AttributionManager? _attributionManager;
  EventTracker? _eventTracker;
  DeepLinkHandler? _deepLinkHandler;
  
  final Completer<void> _initializationCompleter = Completer<void>();
  bool _isInitialized = false;

  // Private constructor
  LinkForty._();

  // MARK: - Initialization

  /// Initializes the SDK with configuration
  ///
  /// - [config]: SDK configuration
  /// - [attributionWindowHours]: Attribution window in hours (default: 168 = 7 days)
  /// - [deviceId]: Optional device identifier for attribution
  /// - Returns: [InstallResponse] with attribution data
  /// - Throws: [LinkFortyError] if initialization fails
  static Future<InstallResponse> initialize({
    required LinkFortyConfig config,
    int attributionWindowHours = 168,
    String? deviceId,
  }) async {
    // Check if already initialized
    if (_instance != null) {
      throw const AlreadyInitializedError();
    }

    // Validate configuration
    config.validate();

    // Create new instance
    final sdk = LinkForty._();

    // Store configuration
    sdk._config = config;

    // Set debug mode
    LinkFortyLogger.isDebugEnabled = config.debug;

    // Create managers
    final storageManager = await StorageManager.create();
    final networkManager = NetworkManager(config: config);
    final fingerprintCollector = FingerprintCollector();

    sdk._networkManager = networkManager;

    sdk._attributionManager = AttributionManager(
      networkManager: networkManager,
      storageManager: storageManager,
      fingerprintCollector: fingerprintCollector,
    );

    sdk._eventTracker = EventTracker(
      networkManager: networkManager,
      storageManager: storageManager,
    );

    final deepLinkHandler = DeepLinkHandler();
    deepLinkHandler.configure(
      networkManager: networkManager,
      fingerprintCollector: fingerprintCollector,
      baseURL: config.baseURL,
    );
    sdk._deepLinkHandler = deepLinkHandler;

    // Mark as initialized
    sdk._isInitialized = true;
    _instance = sdk;
    sdk._initializationCompleter.complete();

    // Report install and get attribution data
    final response = await sdk._attributionManager!.reportInstall(
      attributionWindowHours: attributionWindowHours,
      deviceId: deviceId,
    );

    // If attributed, notify deferred deep link handler
    if (response.attributed && response.deepLinkData != null) {
      await sdk._deepLinkHandler?.deliverDeferredDeepLink(response.deepLinkData);
    }

    LinkFortyLogger.log(
      'SDK initialized successfully (attributed: ${response.attributed})',
    );

    return response;
  }

  // MARK: - Deep Linking

  /// Handles a deep link URI (App Link or custom scheme)
  ///
  /// - [uri]: Deep link URI to handle
  Future<void> handleDeepLink(Uri uri) async {
    if (!_isInitialized) {
      LinkFortyLogger.log('SDK not initialized. Call initialize() first.');
      return;
    }
    await _deepLinkHandler?.handleDeepLink(uri);
  }

  /// Registers a callback for deferred deep links (triggered on first launch after attributed install)
  ///
  /// - [callback]: Callback invoked with deep link data, or null for organic installs
  void onDeferredDeepLink(DeferredDeepLinkCallback callback) {
    if (!_isInitialized) {
      LinkFortyLogger.log('SDK not initialized. Call initialize() first.');
      return;
    }
    _deepLinkHandler?.onDeferredDeepLink(callback);
  }

  /// Registers a callback for direct deep links (triggered when app opens from link)
  ///
  /// - [callback]: Callback invoked with URI and deep link data
  void onDeepLink(DeepLinkCallback callback) {
    if (!_isInitialized) {
      LinkFortyLogger.log('SDK not initialized. Call initialize() first.');
      return;
    }
    _deepLinkHandler?.onDeepLink(callback);
  }

  // MARK: - Event Tracking

  /// Tracks a custom event
  ///
  /// - [name]: Event name (e.g., "purchase", "signup")
  /// - [properties]: Optional event properties (must be JSON-serializable)
  /// - Throws: [LinkFortyError] if tracking fails
  Future<void> trackEvent(String name, [Map<String, dynamic>? properties]) async {
    if (!_isInitialized) {
      throw const NotInitializedError();
    }
    await _eventTracker?.trackEvent(name, properties);
  }

  /// Tracks a revenue event
  ///
  /// - [amount]: Revenue amount (must be non-negative)
  /// - [currency]: Currency code (e.g., "USD")
  /// - [properties]: Optional additional properties
  /// - Throws: [LinkFortyError] if tracking fails
  Future<void> trackRevenue({
    required double amount,
    required String currency,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedError();
    }
    await _eventTracker?.trackRevenue(
      amount: amount,
      currency: currency,
      properties: properties,
    );
  }

  /// Flushes the event queue, attempting to send all queued events
  Future<void> flushEvents() async {
    if (!_isInitialized) {
      LinkFortyLogger.log('SDK not initialized. Call initialize() first.');
      return;
    }
    await _eventTracker?.flushQueue();
  }

  /// Returns the number of queued events
  int get queuedEventCount {
    if (!_isInitialized) return 0;
    return _eventTracker?.queuedEventCount ?? 0;
  }

  /// Clears the event queue without sending events
  void clearEventQueue() {
    if (!_isInitialized) {
      LinkFortyLogger.log('SDK not initialized. Call initialize() first.');
      return;
    }
    _eventTracker?.clearQueue();
  }

  // MARK: - Link Creation

  /// Creates a short link programmatically
  ///
  /// Requires an API key in [LinkFortyConfig].
  /// If [CreateLinkOptions.templateId] is provided, uses the dashboard endpoint (`POST /api/links`).
  /// Otherwise, uses the simplified SDK endpoint (`POST /api/sdk/v1/links`)
  /// which auto-selects the organization's most recent template.
  ///
  /// - [options]: Link creation options
  /// - Returns: [CreateLinkResult] with the shareable URL, short code, and link ID
  /// - Throws: [NotInitializedError] if SDK not initialized
  /// - Throws: [MissingApiKeyError] if no API key configured
  Future<CreateLinkResult> createLink(CreateLinkOptions options) async {
    if (!_isInitialized) {
      throw const NotInitializedError();
    }

    final config = _config;
    if (config == null) {
      throw const NotInitializedError();
    }

    if (config.apiKey == null) {
      throw const MissingApiKeyError();
    }

    final networkManager = _networkManager;
    if (networkManager == null) {
      throw const NotInitializedError();
    }

    if (options.templateId != null) {
      // Use dashboard endpoint with explicit templateId
      final response = await networkManager.request<DashboardCreateLinkResponse>(
        endpoint: '/api/links',
        method: HttpMethod.post,
        body: options.toJson(),
        fromJson: (json) => DashboardCreateLinkResponse.fromJson(json),
      );

      // Construct URL from parts
      final baseUrl = config.baseURL.toString().replaceAll(RegExp(r'/$'), '');
      final templateSlug = options.templateSlug ?? '';
      final pathSegment = templateSlug.isEmpty
          ? response.shortCode
          : '$templateSlug/${response.shortCode}';
      final url = '$baseUrl/$pathSegment';

      return CreateLinkResult(
        url: url,
        shortCode: response.shortCode,
        linkId: response.id,
      );
    } else {
      // Use simplified SDK endpoint (auto-selects template)
      return await networkManager.request<CreateLinkResult>(
        endpoint: '/api/sdk/v1/links',
        method: HttpMethod.post,
        body: options.toJson(),
        fromJson: (json) => CreateLinkResult.fromJson(json),
      );
    }
  }

  // MARK: - Attribution Data

  /// Returns the install ID if available
  String? getInstallId() {
    if (!_isInitialized) return null;
    return _attributionManager?.getInstallId();
  }

  /// Returns the install attribution data if available
  DeepLinkData? getInstallData() {
    if (!_isInitialized) return null;
    return _attributionManager?.getInstallData();
  }

  /// Returns whether this is the first launch
  bool isFirstLaunch() {
    if (!_isInitialized) return true;
    return _attributionManager?.isFirstLaunch() ?? true;
  }

  // MARK: - Data Management

  /// Clears all stored SDK data
  Future<void> clearData() async {
    await _attributionManager?.clearData();
    _eventTracker?.clearQueue();
    _deepLinkHandler?.clearCallbacks();
    LinkFortyLogger.log('All SDK data cleared');
  }

  /// Resets the SDK to uninitialized state
  ///
  /// Note: This does NOT clear stored data. Call [clearData] first if needed.
  void reset() {
    _config = null;
    _networkManager = null;
    _attributionManager = null;
    _eventTracker = null;
    _deepLinkHandler = null;
    _isInitialized = false;
    _instance = null;
    LinkFortyLogger.log('SDK reset to uninitialized state');
  }
}