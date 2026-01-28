import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/realtime/generated_socket_events.dart';
import 'package:neobazaar/core/services/realtime/websocket_service.dart';

class WebSocketDispatchedEvent {
  final String scope;
  final String type;
  final dynamic payload;
  final DateTime receivedAt;
  final GeneratedSocketEventEnvelope? generatedEnvelope;

  const WebSocketDispatchedEvent({
    required this.scope,
    required this.type,
    required this.payload,
    required this.receivedAt,
    required this.generatedEnvelope,
  });

  bool get isKnownType => GeneratedSocketEvents.all.contains(type);
}

class WebSocketEventDispatcher {
  final StreamController<WebSocketDispatchedEvent> _allEventsController =
      StreamController<WebSocketDispatchedEvent>.broadcast();
  final Map<String, StreamController<WebSocketDispatchedEvent>>
  _scopeControllers = <String, StreamController<WebSocketDispatchedEvent>>{};

  Stream<WebSocketDispatchedEvent> watchAll() => _allEventsController.stream;

  Stream<WebSocketDispatchedEvent> watchScope(String scope) {
    return _scopeControllers
        .putIfAbsent(
          scope,
          () => StreamController<WebSocketDispatchedEvent>.broadcast(),
        )
        .stream;
  }

  void dispatch(WebSocketIncomingEvent sourceEvent) {
    final resolvedType = sourceEvent.type ?? 'unknown';
    final envelope = _toGeneratedEnvelope(resolvedType, sourceEvent.payload);

    final event = WebSocketDispatchedEvent(
      scope: sourceEvent.scope ?? 'global',
      type: resolvedType,
      payload: sourceEvent.payload,
      receivedAt: sourceEvent.receivedAt,
      generatedEnvelope: envelope,
    );

    _allEventsController.add(event);
    _scopeControllers
        .putIfAbsent(
          event.scope,
          () => StreamController<WebSocketDispatchedEvent>.broadcast(),
        )
        .add(event);
  }

  GeneratedSocketEventEnvelope? _toGeneratedEnvelope(
    String type,
    dynamic payload,
  ) {
    if (!GeneratedSocketEvents.all.contains(type)) {
      return null;
    }

    if (payload is Map<String, dynamic>) {
      return GeneratedSocketEventEnvelope(type: type, payload: payload);
    }

    if (payload is Map) {
      return GeneratedSocketEventEnvelope(
        type: type,
        payload: payload.map((key, value) => MapEntry(key.toString(), value)),
      );
    }

    return GeneratedSocketEventEnvelope(
      type: type,
      payload: <String, dynamic>{'value': payload},
    );
  }

  Future<void> dispose() async {
    await _allEventsController.close();

    for (final controller in _scopeControllers.values) {
      await controller.close();
    }
    _scopeControllers.clear();
  }
}

final websocketEventDispatcherProvider = Provider<WebSocketEventDispatcher>((
  ref,
) {
  final dispatcher = WebSocketEventDispatcher();
  final service = ref.read(webSocketServiceProvider);

  final subscription = service.events.listen(dispatcher.dispatch);

  ref.onDispose(() async {
    await subscription.cancel();
    await dispatcher.dispose();
  });

  return dispatcher;
});
