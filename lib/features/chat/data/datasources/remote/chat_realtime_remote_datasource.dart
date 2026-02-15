import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/websocket_event_dispatcher_provider.dart';
import 'package:neobazaar/core/providers/websocket_subscription_registry_provider.dart';
import 'package:neobazaar/core/realtime/generated_socket_events.dart';
import 'package:neobazaar/core/services/realtime/websocket_service.dart';
import 'package:neobazaar/features/chat/data/datasources/chat_realtime_datasource.dart';

final chatRealtimeDatasourceProvider = Provider<IChatRealtimeDatasource>((ref) {
  final datasource = ChatRealtimeRemoteDatasource(
    webSocketService: ref.read(webSocketServiceProvider),
    registry: ref.read(websocketSubscriptionRegistryProvider),
    eventDispatcher: ref.read(websocketEventDispatcherProvider),
  );

  ref.onDispose(() async {
    await datasource.dispose();
  });

  return datasource;
});

class ChatRealtimeRemoteDatasource implements IChatRealtimeDatasource {
  static const String _scope = 'chat';

  final WebSocketService _webSocketService;
  final WebSocketSubscriptionRegistry _registry;
  final WebSocketEventDispatcher _eventDispatcher;
  final StreamController<List<Map<String, dynamic>>> _messageFeedController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final Map<String, Map<String, dynamic>> _messagesById =
      <String, Map<String, dynamic>>{};
  StreamSubscription<WebSocketDispatchedEvent>? _messageEventSubscription;

  ChatRealtimeRemoteDatasource({
    required WebSocketService webSocketService,
    required WebSocketSubscriptionRegistry registry,
    required WebSocketEventDispatcher eventDispatcher,
  }) : _webSocketService = webSocketService,
       _registry = registry,
       _eventDispatcher = eventDispatcher {
    _messageEventSubscription = _eventDispatcher
        .watchAll()
        .where((event) {
          return event.type == GeneratedSocketEvents.ChatMessage ||
              event.type == GeneratedSocketEvents.ChatMessageCreatedV1;
        })
        .listen(_ingestRealtimeMessageEvent);
  }

  @override
  Future<void> subscribeToChatChannel(String chatId) async {
    final channel = _chatChannel(chatId);

    if (_registry.isSubscribed(scope: _scope, channel: channel)) {
      return;
    }

    try {
      await _webSocketService.connect();
      _webSocketService.sendJson(<String, dynamic>{
        'type': 'subscribe',
        'scope': _scope,
        'channel': channel,
        'payload': <String, dynamic>{'chatId': chatId},
      });

      _registry.subscribe(scope: _scope, channel: channel);
    } catch (_) {
      // Realtime is best-effort; callers should continue with REST fallback.
    }
  }

  @override
  Future<void> unsubscribeFromChatChannel(String chatId) async {
    final channel = _chatChannel(chatId);

    if (!_registry.isSubscribed(scope: _scope, channel: channel)) {
      return;
    }

    try {
      _webSocketService.sendJson(<String, dynamic>{
        'type': 'unsubscribe',
        'scope': _scope,
        'channel': channel,
        'payload': <String, dynamic>{'chatId': chatId},
      });

      _registry.unsubscribe(scope: _scope, channel: channel);
    } catch (_) {
      _registry.unsubscribe(scope: _scope, channel: channel);
    }
  }

  @override
  Stream<Map<String, dynamic>> watchChatMessageAliasEvents() {
    return _watchByType(GeneratedSocketEvents.ChatMessage);
  }

  @override
  Stream<Map<String, dynamic>> watchChatMessageCreatedV1Events() {
    return _watchByType(GeneratedSocketEvents.ChatMessageCreatedV1);
  }

  @override
  Stream<Map<String, dynamic>> watchChatSuggestionCreatedV1Events() {
    return _watchByType(GeneratedSocketEvents.ChatSuggestionCreatedV1);
  }

  @override
  Stream<Map<String, dynamic>> watchChatMessageReceiptUpdatedV1Events() {
    return _watchByType(GeneratedSocketEvents.ChatMessageReceiptUpdatedV1);
  }

  @override
  Stream<Map<String, dynamic>> watchAuctionBidAliasEvents() {
    return _watchByType(GeneratedSocketEvents.AuctionBid);
  }

  @override
  Stream<Map<String, dynamic>> watchAuctionBidPlacedV1Events() {
    return _watchByType(GeneratedSocketEvents.AuctionBidPlacedV1);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchMessageFeed({String? chatId}) {
    if (chatId == null || chatId.isEmpty) {
      return _messageFeedController.stream;
    }

    return _messageFeedController.stream.map((messages) {
      return messages
          .where((message) => message['chatId']?.toString() == chatId)
          .toList(growable: false);
    });
  }

  @override
  List<Map<String, dynamic>> deduplicateMessagesById(
    Iterable<Map<String, dynamic>> messages,
  ) {
    final deduplicated = <String, Map<String, dynamic>>{};

    for (final message in messages) {
      final messageId =
          message['messageId']?.toString() ?? message['id']?.toString() ?? '';
      if (messageId.isEmpty) {
        continue;
      }
      deduplicated[messageId] = message;
    }

    return deduplicated.values.toList(growable: false);
  }

  @override
  List<Map<String, dynamic>> stabilizeMessageOrderByTimestamp(
    Iterable<Map<String, dynamic>> messages,
  ) {
    final sorted = messages.toList(growable: false);
    sorted.sort((left, right) {
      final leftTime = _parseTimestamp(left['createdAt'] ?? left['timestamp']);
      final rightTime = _parseTimestamp(
        right['createdAt'] ?? right['timestamp'],
      );
      return leftTime.compareTo(rightTime);
    });
    return sorted;
  }

  String _chatChannel(String chatId) => 'chat:$chatId';

  Stream<Map<String, dynamic>> _watchByType(String type) {
    return _eventDispatcher
        .watchAll()
        .where((event) => event.type == type)
        .map(
          (event) => <String, dynamic>{
            'type': event.type,
            'scope': event.scope,
            'payload': _asMap(event.payload),
            'receivedAt': event.receivedAt.toIso8601String(),
          },
        );
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{'value': payload};
  }

  Future<void> dispose() async {
    await _messageEventSubscription?.cancel();
    await _messageFeedController.close();
  }

  void _ingestRealtimeMessageEvent(WebSocketDispatchedEvent event) {
    final envelope = _asMap(event.payload);
    final message = _extractMessageMap(envelope);
    final messageId =
        message['messageId']?.toString() ?? message['id']?.toString();

    if (messageId == null || messageId.isEmpty) {
      return;
    }

    final normalized = <String, dynamic>{
      ...message,
      'messageId': messageId,
      'chatId': message['chatId'] ?? envelope['chatId'],
      'timestamp': message['timestamp'] ?? message['createdAt'],
    };

    _messagesById[messageId] = normalized;
    final deduplicated = deduplicateMessagesById(_messagesById.values);
    final ordered = stabilizeMessageOrderByTimestamp(deduplicated);
    _messageFeedController.add(ordered);
  }

  Map<String, dynamic> _extractMessageMap(Map<String, dynamic> envelope) {
    final nested = envelope['message'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    if (nested is Map) {
      return nested.map((key, value) => MapEntry(key.toString(), value));
    }
    return envelope;
  }

  DateTime _parseTimestamp(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }

    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed.toUtc();
    }

    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
