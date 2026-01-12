# dio_connection_checker

A Dio-based internet connection checker that detects **real** internet connectivity by monitoring actual HTTP request outcomes, rather than relying on OS network state.

## Why?

OS-level connectivity checks (like `connectivity_plus`) only tell you if you're connected to WiFi/mobile data, not if you actually have internet access. This package monitors your Dio HTTP requests to determine real connectivity.

**Framework-Agnostic**: Works with any Flutter/Dart project - no dependencies on GetX, Provider, Riverpod, or any other state management framework.

## Features

- ✅ Real internet detection (not just WiFi/mobile state)
- ✅ Automatic status updates based on API requests
- ✅ Two listening modes: live (all events) and unique (distinct only)
- ✅ Framework-agnostic (works with GetX, Provider, Riverpod, or plain Dart)
- ✅ Singleton pattern with simple API
- ✅ Configurable logging (can be disabled)
- ✅ Automatic warnings if interceptor not configured
- ✅ Zero additional network requests

## Installation

Since this is a local package, add it to your `pubspec.yaml`:

```yaml
dependencies:
  dio_connection_checker:
    path: lib/dio_connection_checker
```

## Usage

### 1. Add Interceptor to Dio

```dart
import 'package:dio_connection_checker/dio_connection_checker.dart';

final dio = Dio();
dio.interceptors.add(ConnectionStatusInterceptor());
```

### 2. Configure ConnectionManager (Optional)

```dart
// Optional: Disable logging if you don't want console output
ConnectionManager.instance.enableLogging = false;

// Optional: Register with GetX if you're using GetX in your app
Get.put<ConnectionManager>(
  ConnectionManager.instance,
  permanent: true,
);
```

### 3. Listen to Connection Changes

```dart
// Listen to ALL events (including duplicates)
ConnectionManager.instance.listenLive().listen((status) {
  switch (status) {
    case ConnectionStatus.connected:
      print('🟢 Internet available');
      break;
    case ConnectionStatus.disconnected:
      print('🔴 No internet');
      break;
    case ConnectionStatus.unknown:
      print('⚪ Status unknown');
      break;
  }
});

// Listen to UNIQUE changes only (recommended)
ConnectionManager.instance.listenUnique().listen((status) {
  if (status.isConnected) {
    // Reconnect WebSocket, sync data, etc.
  }
});
```

### 4. Check Current Status

```dart
final manager = ConnectionManager.instance;

if (manager.isConnected) {
  // Make network request
}

print('Current status: ${manager.status}');
```

## How It Works

1. **Network Exception** → Interceptor detects → Emits `ConnectionStatus.disconnected`
2. **Successful Request** → Interceptor detects → Emits `ConnectionStatus.connected`
3. **No Requests Yet** → Status remains `ConnectionStatus.unknown`

## Connection Status Enum

```dart
enum ConnectionStatus {
  unknown,      // No API requests made yet
  connected,    // Last request succeeded
  disconnected  // Last request failed with network error
}
```

## Listen Modes

### listenLive() - All Events

Emits every status update, including duplicates:

```
disconnected → disconnected → connected → connected
(All 4 events emitted)
```

### listenUnique() - Distinct Only

Only emits when status changes:

```
disconnected → disconnected → connected → connected
(Only: disconnected → connected emitted)
```

## Safety Features

- Warns if you listen without adding the interceptor
- Singleton pattern prevents multiple instances
- Thread-safe status updates
- Configurable logging

## License

MIT
