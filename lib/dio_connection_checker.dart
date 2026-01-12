/// Dio-based internet connection checker.
///
/// Detects real internet connectivity by monitoring actual HTTP request
/// success/failure instead of relying on OS network state.
///
/// ## Usage
///
/// 1. Add the interceptor to your Dio instance:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(ConnectionStatusInterceptor());
/// ```
///
/// 2. Listen to connection changes:
/// ```dart
/// // Listen to all events (including duplicates)
/// ConnectionManager.instance.listenLive().listen((status) {
///   print('Connection: $status');
/// });
///
/// // Listen to unique changes only
/// ConnectionManager.instance.listenUnique().listen((status) {
///   if (status.isConnected) {
///     // Internet restored
///   }
/// });
/// ```
library dio_connection_checker;

export 'src/connection_status.dart';
export 'src/connection_manager.dart';
export 'src/connection_status_interceptor.dart';
