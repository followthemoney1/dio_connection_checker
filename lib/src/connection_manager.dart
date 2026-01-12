import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'connection_status.dart';

/// Listener type for connection status streams
enum ListenerType {
  /// Listen to all events including duplicates
  live,

  /// Listen to unique events only (distinct)
  unique;

  String get methodName => switch (this) {
        ListenerType.live => 'listenLive',
        ListenerType.unique => 'listenUnique',
      };
}

/// Singleton service that manages global internet connection state
/// based on real API request success/failure.
///
/// IMPORTANT: You must add [ConnectionStatusInterceptor] to your Dio instance
/// for this to work. The manager will log warnings if you attempt to listen
/// without the interceptor being set up.
///
/// This is a framework-agnostic package - no dependencies on GetX, Provider, etc.
class ConnectionManager {
  static ConnectionManager? _instance;

  /// Get the singleton instance
  static ConnectionManager get instance {
    _instance ??= ConnectionManager._internal();
    return _instance!;
  }

  ConnectionManager._internal();

  final _statusController =
      BehaviorSubject<InternetConnectionStatus>.seeded(InternetConnectionStatus.unknown);

  bool _interceptorRegistered = false;
  DateTime? _lastStatusChange;

  /// Enable or disable logging. Defaults to true.
  bool enableLogging = true;

  /// Current connection status
  InternetConnectionStatus get status => _statusController.value;

  /// Check if currently connected
  bool get isConnected => status.isConnected;

  /// Check if currently disconnected
  bool get isDisconnected => status.isDisconnected;

  /// When the last status change occurred (null if no changes yet)
  DateTime? get lastStatusChange => _lastStatusChange;

  /// Listen to ALL connection status changes (including duplicates)
  ///
  /// This stream emits every status change, even if the new status
  /// is the same as the previous one.
  ///
  /// Example: disconnected → disconnected → connected → connected
  /// All 4 events will be emitted.
  Stream<InternetConnectionStatus> listenLive() {
    _checkInterceptorRegistered(ListenerType.live);
    return _statusController.stream;
  }

  /// Listen to UNIQUE connection status changes only
  ///
  /// This stream only emits when the status actually changes to a different value.
  /// Duplicate consecutive statuses are filtered out.
  ///
  /// Example: disconnected → disconnected → connected → connected
  /// Only: disconnected → connected will be emitted.
  Stream<InternetConnectionStatus> listenUnique() {
    _checkInterceptorRegistered(ListenerType.unique);
    return _statusController.stream.distinct();
  }

  /// Internal method called by the interceptor to update status
  void updateStatus(InternetConnectionStatus newStatus) {
    _lastStatusChange = DateTime.now();
    _statusController.add(newStatus);

    // Log status changes
    if (enableLogging) {
      switch (newStatus) {
        case InternetConnectionStatus.connected:
          log('🟢 [ConnectionManager] Internet CONNECTED', name: 'ConnectionManager');
          break;
        case InternetConnectionStatus.disconnected:
          log('🔴 [ConnectionManager] Internet DISCONNECTED', name: 'ConnectionManager');
          break;
        case InternetConnectionStatus.unknown:
          log('⚪ [ConnectionManager] Connection status UNKNOWN', name: 'ConnectionManager');
          break;
      }
    }
  }

  /// Mark that the interceptor has been registered
  void markInterceptorRegistered() {
    _interceptorRegistered = true;
    if (enableLogging) {
      log('✅ [ConnectionManager] Interceptor registered', name: 'ConnectionManager');
    }
  }

  /// Check if interceptor is registered and log warning if not
  void _checkInterceptorRegistered(ListenerType listenerType) {
    if (!_interceptorRegistered && enableLogging) {
      log(
        '⚠️ WARNING: You are calling ${listenerType.methodName}() '
        'but ConnectionStatusInterceptor has not been added to your Dio instance.\n'
        'Connection status will remain "unknown" until you add the interceptor.\n'
        'Add it like this:\n'
        '  dio.interceptors.add(ConnectionStatusInterceptor());',
        name: 'ConnectionManager',
        level: 900, // WARNING level
      );
    }
  }

  /// Reset the connection manager (useful for testing)
  void reset() {
    _statusController.add(InternetConnectionStatus.unknown);
    _interceptorRegistered = false;
    _lastStatusChange = null;
  }

  /// Dispose resources and close streams
  void dispose() {
    _statusController.close();
  }
}
