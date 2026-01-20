import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:neobazaar/features/chat/presentation/view_model/chat_inbox_notifier.dart';

class ChatInboxPage extends ConsumerWidget {
  const ChatInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatInboxNotifierProvider);

    if (state.status == AsyncStatus.loading && state.chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AsyncStatus.error && state.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? 'Unable to load chats.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.read(chatInboxNotifierProvider.notifier).loadInbox(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.chats.isEmpty) {
      return const Center(child: Text('No chats yet.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatInboxNotifierProvider.notifier).loadInbox(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = state.chats[index];
          final chatId = _readChatId(chat);
          final title =
              chat['title']?.toString() ??
              chat['participantName']?.toString() ??
              'Chat ${index + 1}';
          final subtitle = _readPreview(chat);
          final unreadCount = _readUnreadCount(chat);

          return Material(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.chat_bubble_outline),
              ),
              title: Text(title),
              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: unreadCount > 0
                  ? CircleAvatar(
                      radius: 11,
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(fontSize: 10),
                      ),
                    )
                  : null,
              onTap: chatId == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ChatDetailPage(chatId: chatId, title: title),
                        ),
                      );
                    },
            ),
          );
        },
      ),
    );
  }

  String? _readChatId(Map<String, dynamic> chat) {
    return chat['chatId']?.toString() ?? chat['id']?.toString();
  }

  String _readPreview(Map<String, dynamic> chat) {
    final preview = chat['preview']?.toString();
    if (preview != null && preview.trim().isNotEmpty) {
      return preview;
    }

    final lastHumanMessage = chat['lastHumanMessage'];
    if (lastHumanMessage is Map) {
      final content =
          lastHumanMessage['content']?.toString() ??
          lastHumanMessage['text']?.toString() ??
          '';
      if (content.trim().isNotEmpty) {
        return content;
      }
    }

    final lastMessage = chat['lastMessage'];
    if (lastMessage is Map) {
      final content =
          lastMessage['content']?.toString() ??
          lastMessage['text']?.toString() ??
          '';
      if (content.trim().isNotEmpty) {
        return content;
      }
    }

    return 'Open conversation';
  }

  int _readUnreadCount(Map<String, dynamic> chat) {
    final raw = chat['unreadCount'];
    if (raw is int) {
      return raw;
    }
    if (raw is String) {
      return int.tryParse(raw) ?? 0;
    }
    return 0;
  }
}
