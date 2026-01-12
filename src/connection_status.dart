/// Represents the current internet connection status based on actual API requests
enum InternetConnectionStatus {
  /// Connection status is unknown (no requests made yet)
  unknown,

  /// Internet is available (last request succeeded)
  connected,

  /// No internet connection (last request failed with network error)
  disconnected;

  bool get isConnected => this == InternetConnectionStatus.connected;
  bool get isDisconnected => this == InternetConnectionStatus.disconnected;
  bool get isUnknown => this == InternetConnectionStatus.unknown;
}
