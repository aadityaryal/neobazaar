import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/realtime/websocket_service.dart';

class WebSocketReconnectBackoffState {
  final bool isActive;
  final int attempt;
  final Duration? nextDelay;

  const WebSocketReconnectBackoffState({
    this.isActive = false,
    this.attempt = 0,
    this.nextDelay,
  });
}

final websocketReconnectBackoffProvider =
    NotifierProvider<
      WebSocketReconnectBackoffNotifier,
      WebSocketReconnectBackoffState
    >(WebSocketReconnectBackoffNotifier.new);

class WebSocketReconnectBackoffNotifier
    extends Notifier<WebSocketReconnectBackoffState> {
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;
  final WebSocketReconnectPolicy _policy = const WebSocketReconnectPolicy();

  @override
  WebSocketReconnectBackoffState build() {
    final websocketService = ref.read(webSocketServiceProvider);

    _connectionSubscription?.cancel();
    _connectionSubscription = websocketService.connectionState.listen(
      _onConnectionState,
    );

    ref.onDispose(() {
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
    });

    return const WebSocketReconnectBackoffState();
  }

  void _onConnectionState(WebSocketConnectionState connectionState) {
    if (connectionState == WebSocketConnectionState.reconnecting) {
      final nextAttempt = state.attempt + 1;
      state = WebSocketReconnectBackoffState(
        isActive: true,
        attempt: nextAttempt,
        nextDelay: _policy.delayForAttempt(nextAttempt - 1),
      );
      return;
    }

    if (connectionState == WebSocketConnectionState.connected) {
      state = const WebSocketReconnectBackoffState();
      return;
    }

    if (connectionState == WebSocketConnectionState.disconnected &&
        state.isActive) {
      state = const WebSocketReconnectBackoffState();
    }
  }
}
