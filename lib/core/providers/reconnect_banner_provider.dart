import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/realtime/websocket_service.dart';

class ReconnectBannerState {
  final bool visible;
  final String? message;

  const ReconnectBannerState({this.visible = false, this.message});

  ReconnectBannerState copyWith({bool? visible, String? message}) {
    return ReconnectBannerState(
      visible: visible ?? this.visible,
      message: message ?? this.message,
    );
  }
}

final reconnectBannerProvider =
    NotifierProvider<ReconnectBannerNotifier, ReconnectBannerState>(
      ReconnectBannerNotifier.new,
    );

class ReconnectBannerNotifier extends Notifier<ReconnectBannerState> {
  StreamSubscription<WebSocketConnectionState>? _connectionSubscription;
  var _hasConnectedAtLeastOnce = false;

  @override
  ReconnectBannerState build() {
    final websocketService = ref.read(webSocketServiceProvider);

    _connectionSubscription?.cancel();
    _connectionSubscription = websocketService.connectionState.listen(
      _onConnectionStateChanged,
    );

    ref.onDispose(() {
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
    });

    return const ReconnectBannerState();
  }

  void _onConnectionStateChanged(WebSocketConnectionState connectionState) {
    switch (connectionState) {
      case WebSocketConnectionState.connected:
        _hasConnectedAtLeastOnce = true;
        state = const ReconnectBannerState();
        break;
      case WebSocketConnectionState.reconnecting:
        if (_hasConnectedAtLeastOnce) {
          state = const ReconnectBannerState(
            visible: true,
            message: 'Reconnecting to realtime updates...',
          );
        } else {
          state = const ReconnectBannerState();
        }
        break;
      case WebSocketConnectionState.connecting:
        if (_hasConnectedAtLeastOnce) {
          state = const ReconnectBannerState(
            visible: true,
            message: 'Restoring realtime connection...',
          );
        }
        break;
      case WebSocketConnectionState.disconnected:
        if (_hasConnectedAtLeastOnce) {
          state = const ReconnectBannerState(
            visible: true,
            message: 'Realtime disconnected. Retrying automatically...',
          );
        }
        break;
    }
  }
}
