import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class WebSocketIncomingEvent {
  final String? type;
  final String? scope;
  final dynamic payload;
  final String raw;
  final DateTime receivedAt;

  const WebSocketIncomingEvent({
    required this.type,
    required this.scope,
    required this.payload,
    required this.raw,
    required this.receivedAt,
  });
}

class WebSocketReconnectPolicy {
  final List<Duration> _delays;

  const WebSocketReconnectPolicy({
    List<Duration> delays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 30),
    ],
  }) : _delays = delays;

  Duration delayForAttempt(int attemptIndex) {
    if (attemptIndex <= 0) {
      return _delays.first;
    }

    final index = attemptIndex < _delays.length
        ? attemptIndex
        : _delays.length - 1;
    return _delays[index];
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService(url: _defaultWebSocketUrl());
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

class WebSocketService {
  final String url;
  final WebSocketReconnectPolicy reconnectPolicy;
  final Duration heartbeatInterval;
  final Duration staleConnectionThreshold;

  IOWebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _heartbeatTimer;
  Timer? _staleTimer;
  Timer? _reconnectTimer;

  var _manualClose = false;
  var _isDisposed = false;
  var _reconnectAttempt = 0;
  DateTime? _lastInboundAt;
  var _currentState = WebSocketConnectionState.disconnected;

  final StreamController<WebSocketIncomingEvent> _eventsController =
      StreamController<WebSocketIncomingEvent>.broadcast();
  final StreamController<WebSocketConnectionState> _connectionController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketService({
    required this.url,
    this.reconnectPolicy = const WebSocketReconnectPolicy(),
    this.heartbeatInterval = const Duration(seconds: 25),
    this.staleConnectionThreshold = const Duration(seconds: 45),
  });

  Stream<WebSocketIncomingEvent> get events => _eventsController.stream;
  Stream<WebSocketConnectionState> get connectionState =>
      _connectionController.stream;
  WebSocketConnectionState get currentState => _currentState;
  bool get isConnected => _currentState == WebSocketConnectionState.connected;

  Future<void> connect({Map<String, dynamic>? headers}) async {
    if (_isDisposed) {
      return;
    }

    if (isConnected || _currentState == WebSocketConnectionState.connecting) {
      return;
    }

    _manualClose = false;
    _setConnectionState(WebSocketConnectionState.connecting);

    await _disposeChannel();

    try {
      final normalizedUrl = _normalizeWebSocketUrl(url);
      final socket = await WebSocket.connect(normalizedUrl, headers: headers);
      _channel = IOWebSocketChannel(socket);
      _channelSubscription = _channel!.stream.listen(
        _handleInboundData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _setConnectionState(WebSocketConnectionState.reconnecting);
      _scheduleReconnect();
      return;
    }

    _reconnectAttempt = 0;
    _lastInboundAt = DateTime.now();
    _startHeartbeat();
    _startStaleConnectionDetection();
    _setConnectionState(WebSocketConnectionState.connected);
  }

  void sendJson(Map<String, dynamic> payload) {
    final data = jsonEncode(payload);
    sendRaw(data);
  }

  void sendRaw(String message) {
    if (_isDisposed) {
      return;
    }

    try {
      _channel?.sink.add(message);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> close() async {
    if (_isDisposed) {
      return;
    }

    _manualClose = true;
    await _disposeChannel();
    _stopHeartbeat();
    _stopStaleConnectionDetection();
    _cancelReconnectTimer();
    _setConnectionState(WebSocketConnectionState.disconnected);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    await close();
    _isDisposed = true;

    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }

    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
  }

  void _handleInboundData(dynamic data) {
    if (_eventsController.isClosed) {
      return;
    }

    final raw = data?.toString() ?? '';
    _lastInboundAt = DateTime.now();

    String? type;
    String? scope;
    dynamic payload;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        type = (decoded['type'] ?? decoded['event'])?.toString();
        scope = (decoded['scope'] ?? decoded['channel'] ?? decoded['feature'])
            ?.toString();
        payload = decoded['payload'] ?? decoded;
      } else {
        payload = decoded;
      }
    } catch (_) {
      payload = raw;
    }

    _eventsController.add(
      WebSocketIncomingEvent(
        type: type,
        scope: scope,
        payload: payload,
        raw: raw,
        receivedAt: _lastInboundAt!,
      ),
    );
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      final ping = <String, dynamic>{
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      };
      sendJson(ping);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _startStaleConnectionDetection() {
    _stopStaleConnectionDetection();
    _staleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final lastInboundAt = _lastInboundAt;
      if (lastInboundAt == null) {
        return;
      }

      final elapsed = DateTime.now().difference(lastInboundAt);
      if (elapsed > staleConnectionThreshold) {
        _channel?.sink.close(status.goingAway, 'stale-connection');
      }
    });
  }

  void _stopStaleConnectionDetection() {
    _staleTimer?.cancel();
    _staleTimer = null;
  }

  void _scheduleReconnect() {
    if (_manualClose || _isDisposed) {
      return;
    }

    if (_reconnectTimer?.isActive ?? false) {
      return;
    }

    _setConnectionState(WebSocketConnectionState.reconnecting);
    final delay = reconnectPolicy.delayForAttempt(_reconnectAttempt);
    _reconnectAttempt += 1;

    _reconnectTimer = Timer(delay, () async {
      await connect();
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _disposeChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;

    try {
      await _channel?.sink.close(status.normalClosure, 'client-reset');
    } catch (_) {
      // Ignore close errors during reconnect/dispose cleanup.
    }
    _channel = null;
  }

  void _setConnectionState(WebSocketConnectionState state) {
    _currentState = state;
    if (!_connectionController.isClosed) {
      _connectionController.add(state);
    }
  }
}

String _defaultWebSocketUrl() {
  final base = AppConstants.apiBaseUrlV1.replaceFirst(RegExp(r'^http'), 'ws');

  if (base.endsWith('/api/v1')) {
    return '${base.substring(0, base.length - 7)}/ws';
  }

  if (base.endsWith('/api')) {
    return '${base.substring(0, base.length - 4)}/ws';
  }

  return '$base/ws';
}

String _normalizeWebSocketUrl(String rawUrl) {
  final uri = Uri.parse(rawUrl.trim());
  final scheme = uri.scheme.toLowerCase();

  if (scheme == 'ws' || scheme == 'wss') {
    return uri.toString();
  }

  if (scheme == 'http') {
    return uri.replace(scheme: 'ws').toString();
  }

  if (scheme == 'https') {
    return uri.replace(scheme: 'wss').toString();
  }

  return uri.toString();
}
