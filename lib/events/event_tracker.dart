// Copyright 2026 The Link Forty Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../network/network_manager.dart';

import '../models/event_request.dart';
import '../models/event_response.dart';
import '../network/http_method.dart';
import '../storage/storage_manager.dart';
import '../errors/link_forty_error.dart';
import '../link_forty_logger.dart';
import 'event_queue.dart';

/// Responsible for tracking custom in-app events and managing the offline queue.
///
/// This tracker handles immediate event submission and falls back to a
/// persistent [EventQueue] when the network is unavailable or requests fail.
class EventTracker implements EventTrackerProtocol {
  final NetworkManagerProtocol _networkManager;
  final StorageManagerProtocol _storageManager;
  final EventQueue _eventQueue;

  /// Creates an event tracker
  ///
  /// - [networkManager]: Network manager for API requests
  /// - [storageManager]: Storage manager for install ID and event queue persistence
  /// - [eventQueue]: Event queue for offline support
  EventTracker({
    required NetworkManagerProtocol networkManager,
    required StorageManagerProtocol storageManager,
    EventQueue? eventQueue,
  }) : _networkManager = networkManager,
       _storageManager = storageManager,
       _eventQueue = eventQueue ?? EventQueue() {
    // Restore any events that were persisted before the last app session
    _restorePersistedQueue();
  }

  // MARK: - Event Tracking

  /// Tracks a custom event
  ///
  /// - [name]: Event name (e.g., "purchase", "signup")
  /// - [properties]: Optional event properties (must be JSON-serializable)
  /// - Throws: [LinkFortyError] if tracking fails
  @override
  Future<void> trackEvent(
    String name, [
    Map<String, dynamic>? properties,
  ]) async {
    // Validate event name
    if (name.trim().isEmpty) {
      throw InvalidEventDataError('Event name cannot be empty');
    }

    // Get install ID
    final installId = _storageManager.getInstallId();
    if (installId == null) {
      throw const NotInitializedError();
    }

    // Create event request
    final event = EventRequest(
      installId: installId,
      eventName: name,
      eventData: properties ?? {},
    );

    // Try to send immediately
    try {
      await _sendEvent(event);
      LinkFortyLogger.log('Event tracked: $name');

      // If send succeeds, try to flush queue
      await flushQueue();
    } catch (e) {
      // If send fails, queue the event and persist
      _eventQueue.enqueue(event);
      await _persistQueue();
      LinkFortyLogger.log('Event queued due to error: $e');
      rethrow;
    }
  }

  /// Tracks a revenue-generating event.
  ///
  /// This is a convenience method that wraps [trackEvent] with specialized
  /// revenue properties (`revenue` and `currency`).
  ///
  /// Parameters:
  /// - [amount]: The decimal value of the transaction.
  /// - [currency]: The 3-letter ISO code (e.g., "USD").
  /// - [properties]: Optional additional context.
  @override
  Future<void> trackRevenue({
    required double amount,
    required String currency,
    Map<String, dynamic>? properties,
  }) async {
    if (amount < 0) {
      throw InvalidEventDataError('Revenue amount must be non-negative');
    }

    final eventProperties = Map<String, dynamic>.from(properties ?? {});
    eventProperties['revenue'] = amount;
    eventProperties['currency'] = currency;

    await trackEvent('revenue', eventProperties);
  }

  // MARK: - Queue Management

  /// Flushes the event queue, attempting to send all queued events
  @override
  Future<void> flushQueue() async {
    LinkFortyLogger.log('Flushing event queue (${_eventQueue.count} events)');

    while (!_eventQueue.isEmpty) {
      final event = _eventQueue.dequeue();
      if (event == null) break;

      try {
        await _sendEvent(event);
        await _persistQueue();
        LinkFortyLogger.log('Queued event sent: ${event.eventName}');
      } catch (e) {
        // Re-queue if send fails
        _eventQueue.enqueue(event);
        await _persistQueue();
        LinkFortyLogger.log('Failed to send queued event: $e');
        return;
      }
    }
  }

  /// Returns the number of queued events
  @override
  int get queuedEventCount => _eventQueue.count;

  /// Clears the event queue
  @override
  void clearQueue() {
    _eventQueue.clear();
  }

  // MARK: - Private Helpers

  /// Sends an event to the backend
  ///
  /// - [event]: Event to send
  /// - Throws: [LinkFortyError] on failure
  Future<void> _sendEvent(EventRequest event) async {
    await _networkManager.request<EventResponse>(
      endpoint: '/api/sdk/v1/event',
      method: HttpMethod.post,
      body: event,
      fromJson: (json) => EventResponse.fromJson(json),
    );
  }

  /// Persists the current event queue state to storage
  Future<void> _persistQueue() async {
    await _storageManager.saveEventQueue(_eventQueue.peek());
  }

  /// Restores persisted events from storage into the in-memory queue
  void _restorePersistedQueue() {
    final persisted = _storageManager.loadEventQueue();
    for (final event in persisted) {
      _eventQueue.enqueue(event);
    }
    if (persisted.isNotEmpty) {
      LinkFortyLogger.log(
        'Restored ${persisted.length} event(s) from persistent storage',
      );
    }
  }
}

/// Protocol for EventTracker to enable mocking in tests
abstract class EventTrackerProtocol {
  Future<void> trackEvent(String name, [Map<String, dynamic>? properties]);
  Future<void> trackRevenue({
    required double amount,
    required String currency,
    Map<String, dynamic>? properties,
  });
  Future<void> flushQueue();
  int get queuedEventCount;
  void clearQueue();
}
