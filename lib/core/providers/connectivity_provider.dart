// lib/core/providers/connectivity_provider.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected, isNotDetermined }

final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.isDisconnected;
    }
    return ConnectivityStatus.isConnected;
  });
});

final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityProvider).valueOrNull;
  // Fallback to false (online) if status is not yet determined
  return status == ConnectivityStatus.isDisconnected;
});
