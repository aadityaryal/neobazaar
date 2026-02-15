import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_realtime_remote_datasource.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/presentation/state/chat_detail_state.dart';

final chatDetailNotifierProvider =
    NotifierProvider<ChatDetailNotifier, ChatDetailState>(
      ChatDetailNotifier.new,
    );

class ChatDetailNotifier extends Notifier<ChatDetailState> {
  StreamSubscription<List<Map<String, dynamic>>>? _messageFeedSubscription;
  late final AnalyticsService _analyticsService;

  @override
  ChatDetailState build() {
    _analyticsService = ref.read(analyticsServiceProvider);
    ref.onDispose(() {
      _messageFeedSubscription?.cancel();
      _messageFeedSubscription = null;
    });

    return const ChatDetailState();
  }

  Future<void> openChat(String chatId) async {
    if (state.activeChatId == chatId && state.status == AsyncStatus.success) {
      return;
    }

    state = state.copyWith(
      status: AsyncStatus.loading,
      activeChatId: chatId,
      clearError: true,
    );
    _analyticsService.track(
      'chat_detail_open_started',
      properties: {'chatId': chatId},
    );

    await _messageFeedSubscription?.cancel();
    final realtimeDatasource = ref.read(chatRealtimeDatasourceProvider);
    _messageFeedSubscription = realtimeDatasource
        .watchMessageFeed(chatId: chatId)
        .listen((messages) {
          final merged = _mergeMessages(state.messages, messages);
          state = state.copyWith(
            status: AsyncStatus.success,
            messages: merged,
            clearError: true,
          );
          _analyticsService.track(
            'chat_realtime_feed_updated',
            properties: {
              'chatId': state.activeChatId,
              'messageCount': merged.length,
            },
          );
        });

    await loadMessages();
    await realtimeDatasource.subscribeToChatChannel(chatId);
    _analyticsService.track(
      'chat_realtime_subscribed',
      properties: {'chatId': chatId},
    );
  }

  Future<void> loadMessages() async {
    final chatId = state.activeChatId;
    if (chatId == null || chatId.isEmpty) {
      return;
    }

    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track(
      'chat_messages_load_started',
      properties: {'chatId': chatId},
    );

    try {
      final remoteDatasource = ref.read(chatRemoteDatasourceProvider);
      final realtimeDatasource = ref.read(chatRealtimeDatasourceProvider);
      final remoteMessages = await remoteDatasource.getMessages(
        chatId,
        query: const <String, dynamic>{'limit': 100},
      );

      final deduplicated = realtimeDatasource.deduplicateMessagesById(
        remoteMessages,
      );
      final ordered = realtimeDatasource.stabilizeMessageOrderByTimestamp(
        deduplicated,
      );

      state = state.copyWith(
        status: AsyncStatus.success,
        messages: ordered,
        clearError: true,
      );
      _analyticsService.track(
        'chat_messages_load_success',
        properties: {'chatId': chatId, 'messageCount': ordered.length},
      );
    } catch (error) {
      _analyticsService.track(
        'chat_messages_load_error',
        properties: {'chatId': chatId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final chatId = state.activeChatId;
    final trimmed = text.trim();

    if (chatId == null || chatId.isEmpty || trimmed.isEmpty) {
      return;
    }

    state = state.copyWith(isSending: true, clearError: true);
    _analyticsService.track(
      'chat_send_started',
      properties: {'chatId': chatId},
    );

    try {
      final datasource = ref.read(chatRemoteDatasourceProvider);
      await datasource.createMessage(chatId, <String, dynamic>{
        'content': trimmed,
      });
      await loadMessages();
      state = state.copyWith(isSending: false, clearError: true);
      _analyticsService.track(
        'chat_send_success',
        properties: {'chatId': chatId},
      );
    } catch (error) {
      _analyticsService.track(
        'chat_send_error',
        properties: {'chatId': chatId, 'message': error.toString()},
      );
      state = state.copyWith(
        isSending: false,
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> existing,
    List<Map<String, dynamic>> incoming,
  ) {
    final mergedById = <String, Map<String, dynamic>>{};

    for (final message in existing) {
      final id = message['messageId']?.toString() ?? message['id']?.toString();
      if (id != null && id.isNotEmpty) {
        mergedById[id] = message;
      }
    }

    for (final message in incoming) {
      final id = message['messageId']?.toString() ?? message['id']?.toString();
      if (id != null && id.isNotEmpty) {
        mergedById[id] = message;
      }
    }

    final merged = mergedById.values.toList(growable: false);
    merged.sort((left, right) {
      final l = DateTime.tryParse(
        left['createdAt']?.toString() ?? left['timestamp']?.toString() ?? '',
      );
      final r = DateTime.tryParse(
        right['createdAt']?.toString() ?? right['timestamp']?.toString() ?? '',
      );
      return (l ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        r ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    });
    return merged;
  }
}
