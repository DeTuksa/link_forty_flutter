import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deep_link_data.dart';
import 'storage_keys.dart';

/// Protocol for SharedPreferences to enable mocking in tests
abstract class SharedPreferencesProtocol {
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);
  Future<bool> remove(String key);
}

/// Wrapper for SharedPreferences to conform to the protocol
class SharedPreferencesWrapper implements SharedPreferencesProtocol {
  final SharedPreferences _prefs;

  SharedPreferencesWrapper(this._prefs);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);
}

/// Manages persistent storage for the SDK using SharedPreferences
class StorageManager implements StorageManagerProtocol {
  final SharedPreferencesProtocol _prefs;

  /// Creates a storage manager with the specified SharedPreferencesProtocol
  ///
  /// - [prefs]: The SharedPreferencesProtocol instance to use
  StorageManager(this._prefs);

  /// Factory constructor to create a storage manager asynchronously
  static Future<StorageManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageManager(SharedPreferencesWrapper(prefs));
  }

  // MARK: - Install ID

  /// Saves the install ID
  ///
  /// - [installId]: The install ID to save
  /// - Returns: True if successful, false otherwise
  @override
  Future<bool> saveInstallId(String installId) async {
    try {
      return await _prefs.setString(StorageKeys.installId, installId);
    } catch (e) {
      LinkFortyLogger.log('Failed to save install ID: $e');
      return false;
    }
  }

  /// Retrieves the saved install ID
  ///
  /// - Returns: The install ID if it exists, null otherwise
  @override
  String? getInstallId() {
    return _prefs.getString(StorageKeys.installId);
  }

  // MARK: - Install Data

  /// Saves the deep link data from attribution
  ///
  /// - [data]: The deep link data to save
  /// - Returns: True if successful, false otherwise
  @override
  Future<bool> saveInstallData(DeepLinkData data) async {
    try {
      final json = jsonEncode(data.toJson());
      return await _prefs.setString(StorageKeys.installData, json);
    } catch (e) {
      LinkFortyLogger.log('Failed to encode install data: $e');
      return false;
    }
  }

  /// Retrieves the saved deep link data
  ///
  /// - Returns: The deep link data if it exists and can be decoded, null otherwise
  @override
  DeepLinkData? getInstallData() {
    try {
      final jsonString = _prefs.getString(StorageKeys.installData);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DeepLinkData.fromJson(json);
    } catch (e) {
      LinkFortyLogger.log('Failed to decode install data: $e');
      return null;
    }
  }

  // MARK: - First Launch

  /// Checks if this is the first launch of the app
  ///
  /// - Returns: True if this is the first launch, false otherwise
  @override
  bool isFirstLaunch() {
    // If the key doesn't exist, it defaults to null, so we check if it's not true
    // We store "hasLaunched" and check if it's false
    final hasLaunched = _prefs.getBool(StorageKeys.firstLaunch) ?? false;
    return !hasLaunched;
  }

  /// Marks that the app has launched (no longer first launch)
  ///
  /// - Returns: True if successful, false otherwise
  @override
  Future<bool> setHasLaunched() async {
    try {
      return await _prefs.setBool(StorageKeys.firstLaunch, true);
    } catch (e) {
      LinkFortyLogger.log('Failed to set has launched: $e');
      return false;
    }
  }

  // MARK: - Clear Data

  /// Clears all stored SDK data
  ///
  /// This removes install ID, install data, and first launch flag
  ///
  /// - Returns: True if all removals were successful, false otherwise
  @override
  Future<bool> clearAll() async {
    try {
      final results = await Future.wait([
        _prefs.remove(StorageKeys.installId),
        _prefs.remove(StorageKeys.installData),
        _prefs.remove(StorageKeys.firstLaunch),
      ]);

      // Return true only if all removals were successful
      return results.every((result) => result);
    } catch (e) {
      LinkFortyLogger.log('Failed to clear all data: $e');
      return false;
    }
  }
}

/// Protocol for dependency injection in tests
abstract class StorageManagerProtocol {
  Future<bool> saveInstallId(String installId);
  String? getInstallId();
  Future<bool> saveInstallData(DeepLinkData data);
  DeepLinkData? getInstallData();
  bool isFirstLaunch();
  Future<bool> setHasLaunched();
  Future<bool> clearAll();
}

/// Simple logger for debug mode
class LinkFortyLogger {
  static bool isDebugEnabled = false;

  static void log(String message) {
    if (isDebugEnabled) {
      // ignore: avoid_print
      print('[LinkForty] $message');
    }
  }
}
