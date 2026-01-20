import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/presentation/state/chat_inbox_state.dart';

final chatInboxNotifierProvider =
    NotifierProvider<ChatInboxNotifier, ChatInboxState>(ChatInboxNotifier.new);

class ChatInboxNotifier extends Notifier<ChatInboxState> {
  AnalyticsService get _analyticsService => ref.read(analyticsServiceProvider);

  @override
  ChatInboxState build() {
    Future<void>.microtask(loadInbox);
    return const ChatInboxState();
  }

  Future<void> loadInbox() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track('chat_inbox_load_started');

    try {
      final datasource = ref.read(chatRemoteDatasourceProvider);
      final chats = await datasource.listMine(
        query: const <String, dynamic>{'limit': 50},
      );
      final normalizedChats = chats
          .asMap()
          .entries
          .map((entry) => _normalizeChat(entry.key, entry.value))
          .toList(growable: false);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: AsyncStatus.success,
        chats: normalizedChats,
        clearError: true,
      );
      _analyticsService.track(
        'chat_inbox_load_success',
        properties: {'count': normalizedChats.length},
      );
    } catch (error) {
      if (!ref.mounted) {
        return;
      }
      _analyticsService.track(
        'chat_inbox_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Map<String, dynamic> _normalizeChat(int index, Map<String, dynamic> chat) {
    final normalized = Map<String, dynamic>.from(chat);

    final productId = normalized['productId']?.toString() ?? '';
    final title = normalized['title']?.toString();
    if (title == null || title.trim().isEmpty) {
      final suffix = productId.length >= 6
          ? productId.substring(productId.length - 6)
          : '${index + 1}';
      normalized['title'] = 'Listing #$suffix';
    }

    final lastHumanMessage = normalized['lastHumanMessage'];
    final lastMessage = normalized['lastMessage'];

    final previewSource = lastHumanMessage is Map
        ? lastHumanMessage
        : (lastMessage is Map ? lastMessage : null);

    if (previewSource != null) {
      final content =
          previewSource['content']?.toString() ??
          previewSource['text']?.toString() ??
          '';
      if (content.isNotEmpty) {
        normalized['preview'] = content;
      }
    }

    normalized['preview'] =
        normalized['preview']?.toString() ?? 'Open conversation';

    return normalized;
  }
}
