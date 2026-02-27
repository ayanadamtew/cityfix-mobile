import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/api_client.dart';

class SocketNotifier extends Notifier<IO.Socket?> {
  @override
  IO.Socket? build() {
    return null;
  }

  void connect() {
    if (state != null && state!.connected) return;

    // Use the base URL from ApiClient
    final baseUrl = ApiClient.instance.dio.options.baseUrl;
    
    final socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    socket.onConnect((_) {
      print('[Socket] Connected');
    });

    socket.onDisconnect((_) {
      print('[Socket] Disconnected');
    });
    
    socket.connect();
    state = socket;
  }

  void disconnect() {
    if (state != null) {
      state!.disconnect();
      state!.dispose();
      state = null;
    }
  }
}

final socketProvider = NotifierProvider<SocketNotifier, IO.Socket?>(
  () => SocketNotifier(),
);
