// Copyright 2026 The Forty Link Authors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import '../link_forty_logger.dart';
import '../models/event_request.dart';

/// Queue for storing events when offline
class EventQueue {
  /// Maximum number of events to queue
  static const int _maxQueueSize = 100;

  /// Queued events
  final Queue<EventRequest> _queue = Queue<EventRequest>();

  /// Adds an event to the queue
  /// 
  /// - [event]: Event to queue
  /// - Returns: True if added, false if queue is full
  bool enqueue(EventRequest event) {
    if (_queue.length >= _maxQueueSize) {
      LinkFortyLogger.log(
          'Event queue full, dropping event: ${event.eventName}');
      return false;
    }

    _queue.addLast(event);
    LinkFortyLogger.log(
        'Event queued: ${event.eventName} (queue size: ${_queue.length})');
    return true;
  }

  /// Dequeues the oldest event
  /// 
  /// - Returns: The oldest event, or null if queue is empty
  EventRequest? dequeue() {
    if (_queue.isEmpty) return null;
    return _queue.removeFirst();
  }

  /// Returns all queued events without removing them
  /// 
  /// - Returns: List of queued events
  List<EventRequest> peek() {
    return List<EventRequest>.from(_queue);
  }

  /// Clears all events from the queue
  void clear() {
    final count = _queue.length;
    _queue.clear();
    if (count > 0) {
      LinkFortyLogger.log('Event queue cleared ($count events removed)');
    }
  }

  /// Returns the number of queued events
  int get count => _queue.length;

  /// Checks if the queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Checks if the queue is full
  bool get isFull => _queue.length >= _maxQueueSize;
}