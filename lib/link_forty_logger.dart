// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:logger/logger.dart';

/// Internal logger for the LinkForty SDK.
///
/// This logger is designed for internal SDK debugging and troubleshooting.
/// It only outputs logs to consoles when [isDebugEnabled] is set to `true`
/// via the [LinkFortyConfig].
class LinkFortyLogger {
  // Private constructor to prevent instantiation.
  const LinkFortyLogger._();

  static const String _tag = 'LinkForty';

  /// Controls whether debug logging is enabled for the SDK.
  ///
  /// This should typically be enabled only during development or when
  /// troubleshooting integration issues.
  static bool isDebugEnabled = false;

  static final Logger _logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: false,
      ),
    ),
    level: Level.debug,
  );

  /// Logs a debug [message] if [isDebugEnabled] is `true`.
  static void log(String message) {
    if (isDebugEnabled) {
      _logger.d('[$_tag] $message');
    }
  }

  /// Logs an informational [message] if [isDebugEnabled] is `true`.
  static void info(String message) {
    if (isDebugEnabled) {
      _logger.i('[$_tag] $message');
    }
  }

  /// Logs a warning [message] if [isDebugEnabled] is `true`.
  static void warning(String message) {
    if (isDebugEnabled) {
      _logger.w('[$_tag] $message');
    }
  }

  /// Logs an error [message], optional [error] and [stackTrace] if
  /// [isDebugEnabled] is `true`.
  static void logError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (isDebugEnabled) {
      _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
    }
  }
}
