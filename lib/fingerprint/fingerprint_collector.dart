// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'device_fingerprint.dart';

/// Protocol for dependency injection in tests
abstract class FingerprintCollectorProtocol {
  Future<DeviceFingerprint> collectFingerprint({
    required int attributionWindowHours,
    String? deviceId,
  });
}

/// Collects device fingerprint data for attribution matching
class FingerprintCollector implements FingerprintCollectorProtocol {
  final DeviceInfoPlugin _deviceInfo;
  final PackageInfo? _packageInfo;

  /// Creates a fingerprint collector
  ///
  /// - [deviceInfo]: Device info plugin instance
  /// - [packageInfo]: Package info (if already loaded)
  FingerprintCollector({DeviceInfoPlugin? deviceInfo, PackageInfo? packageInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
      _packageInfo = packageInfo;

  /// Collects device fingerprint for attribution
  ///
  /// - [attributionWindowHours]: Attribution window in hours
  /// - [deviceId]: Optional device ID (IDFA/IDFV/GAID) if user consented
  /// - Returns: Device fingerprint
  @override
  Future<DeviceFingerprint> collectFingerprint({
    required int attributionWindowHours,
    String? deviceId,
  }) async {
    final packageInfo = _packageInfo ?? await PackageInfo.fromPlatform();
    final (screenWidth, screenHeight) = _getScreenDimensions();
    final userAgent = await _generateUserAgent(packageInfo);
    final (platform, platformVersion) = await _getPlatformInfo();

    return DeviceFingerprint(
      userAgent: userAgent,
      timezone: _getTimezone(),
      language: _getLanguage(),
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      platform: platform,
      platformVersion: platformVersion,
      appVersion: packageInfo.version,
      deviceId: deviceId,
      attributionWindowHours: attributionWindowHours,
    );
  }

  // MARK: - Private Helpers

  /// Generates a User-Agent string
  ///
  /// Format: "AppName/AppVersion Platform/PlatformVersion"
  Future<String> _generateUserAgent(PackageInfo packageInfo) async {
    final appName = packageInfo.appName;
    final appVersion = packageInfo.version;
    final (platform, platformVersion) = await _getPlatformInfo();

    return '$appName/$appVersion $platform/$platformVersion';
  }

  /// Returns (width, height) in native pixels
  (int, int) _getScreenDimensions() {
    try {
      // Ensure bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Get the first view from the platform dispatcher
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isEmpty) {
        return (0, 0);
      }

      final view = views.first;
      final physicalSize = view.physicalSize;

      return (physicalSize.width.toInt(), physicalSize.height.toInt());
    } catch (e) {
      // Fallback for testing or headless environments
      return (0, 0);
    }
  }

  /// Gets timezone identifier (e.g., "America/New_York")
  String _getTimezone() {
    try {
      // Try to get the location timezone
      final location = tz.local;
      return location.name;
    } catch (_) {
      // Fallback to simple timezone name
      return DateTime.now().timeZoneName;
    }
  }

  /// Gets language identifier (e.g., "en-US")
  String _getLanguage() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      return '${locale.languageCode}-$countryCode';
    }
    return locale.languageCode;
  }

  /// Gets platform and version information
  Future<(String, String)> _getPlatformInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return ('Android', androidInfo.version.release);
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return ('iOS', iosInfo.systemVersion);
    } else if (Platform.isMacOS) {
      final macosInfo = await _deviceInfo.macOsInfo;
      return ('macOS', macosInfo.osRelease);
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      return ('Windows', windowsInfo.buildNumber.toString());
    } else if (Platform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      return ('Linux', linuxInfo.version ?? 'Unknown');
    } else {
      return (Platform.operatingSystem, 'Unknown');
    }
  }
}
