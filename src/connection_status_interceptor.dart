import 'dart:io';
import 'package:dio/dio.dart';
import 'connection_manager.dart';
import 'connection_status.dart';

/// Dio interceptor that detects internet connectivity based on actual request outcomes.
///
/// How it works:
/// - Network exceptions (SocketException, etc.) → Sets status to DISCONNECTED
/// - Successful responses → Sets status to CONNECTED
/// - Other errors (400, 500, etc.) → Also considered CONNECTED (server is reachable)
///
/// Add this to your Dio instance:
/// ```dart
/// dio.interceptors.add(ConnectionStatusInterceptor());
/// ```
class ConnectionStatusInterceptor extends Interceptor {
  ConnectionStatusInterceptor() {
    ConnectionManager.instance.markInterceptorRegistered();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    ConnectionManager.instance.updateStatus(InternetConnectionStatus.connected);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isNetworkError = _isNetworkError(err);

    if (isNetworkError) {
      ConnectionManager.instance.updateStatus(InternetConnectionStatus.disconnected);
    } else {
      ConnectionManager.instance.updateStatus(InternetConnectionStatus.connected);
    }

    super.onError(err, handler);
  }

  /// Determine if the error is a network connectivity issue (no internet)
  ///
  /// Returns true only for actual connection errors, not server errors (4xx, 5xx)
  /// or timeouts (which indicate server is reachable but slow).
  bool _isNetworkError(DioException err) {
    if (err.type == DioExceptionType.connectionError) return true;

    final error = err.error;
    if (error == null) return false;

    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is HandshakeException) return true;
    if (error is TlsException) return true;

    if (err.type == DioExceptionType.unknown) {
      final errorString = error.toString().toLowerCase();
      return errorString.contains('network is unreachable') ||
          errorString.contains('failed host lookup') ||
          errorString.contains('no address associated with hostname');
    }

    return false;
  }
}
