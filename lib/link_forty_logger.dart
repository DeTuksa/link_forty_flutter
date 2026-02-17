// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:logger/logger.dart';

/// Internal logger for the LinkForty SDK
/// 
/// Only logs when debug mode is enabled
class LinkFortyLogger {
  // Private constructor to prevent instantiation
  LinkFortyLogger._();

  static const String _tag = 'LinkForty';

  /// Controls whether debug logging is enabled
  static bool isDebugEnabled = false;

  /// Logger instance
  static final Logger _logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    ),
    level: Level.debug,
  );

  /// Logs a debug message if debug mode is enabled
  /// 
  /// - [message]: The message to log
  static void log(String message) {
    if (isDebugEnabled) {
      _logger.d('[$_tag] $message');
    }
  }

  /// Logs an info message if debug mode is enabled
  /// 
  /// - [message]: The message to log
  static void info(String message) {
    if (isDebugEnabled) {
      _logger.i('[$_tag] $message');
    }
  }

  /// Logs a warning message if debug mode is enabled
  /// 
  /// - [message]: The warning message to log
  static void warning(String message) {
    if (isDebugEnabled) {
      _logger.w('[$_tag] $message');
    }
  }

  /// Logs an error message if debug mode is enabled
  /// 
  /// - [message]: The error message to log
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (isDebugEnabled) {
      _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);
    }
  }
}