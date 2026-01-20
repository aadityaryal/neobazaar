import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/presentation/state/chat_detail_state.dart';
import 'package:neobazaar/features/chat/presentation/view_model/chat_detail_notifier.dart';
import 'package:neobazaar/features/chat/presentation/view_model/chat_read_receipt_notifier.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final String chatId;
  final String? title;

  const ChatDetailPage({super.key, required this.chatId, this.title});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();

    Future<void>.microtask(() {
      ref.read(chatDetailNotifierProvider.notifier).openChat(widget.chatId);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(chatDetailNotifierProvider);
    final receiptState = ref.watch(chatReadReceiptNotifierProvider);
    final currentUserId = ref.watch(appSessionProvider).user?.authId;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: _buildMessages(
              detailState,
              receiptState.receiptByMessageId,
              currentUserId,
            ),
          ),
          _ComposerBar(
            controller: _inputController,
            isSending: detailState.isSending,
            onChanged: (_) {},
            onSend: () async {
              final text = _inputController.text;
              await ref
                  .read(chatDetailNotifierProvider.notifier)
                  .sendMessage(text);
              _inputController.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(
    ChatDetailState state,
    Map<String, bool> readReceipts,
    String? currentUserId,
  ) {
    if (state.status == AsyncStatus.loading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AsyncStatus.error && state.messages.isEmpty) {
      return Center(child: Text(state.error ?? 'Failed to load messages.'));
    }

    if (state.messages.isEmpty) {
      return const Center(child: Text('No messages yet.'));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[state.messages.length - 1 - index];
        final messageId =
            message['messageId']?.toString() ?? message['id']?.toString() ?? '';
        final text =
            message['text']?.toString() ?? message['content']?.toString() ?? '';
        final senderId = message['senderId']?.toString();
        final isMine =
          (message['isMine'] as bool?) ??
          (currentUserId != null &&
            currentUserId.isNotEmpty &&
            senderId == currentUserId);
        final isRead = readReceipts[messageId] ?? false;

        if (messageId.isNotEmpty && !isRead) {
          Future<void>.microtask(() {
            ref
                .read(chatReadReceiptNotifierProvider.notifier)
                .markMessageRead(chatId: widget.chatId, messageId: messageId);
          });
        }

        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMine
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(text.isEmpty ? '...' : text)),
                if (isMine) ...[
                  const SizedBox(width: 8),
                  Icon(isRead ? Icons.done_all : Icons.done, size: 14),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const _ComposerBar({
    required this.controller,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  semanticCounterText: 'Chat message composer input',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Send message',
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
