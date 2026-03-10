import 'package:neobazaar/core/state/async_status.dart';

class ChatDetailState {
  final AsyncStatus status;
  final String? activeChatId;
  final List<Map<String, dynamic>> messages;
  final bool isSending;
  final String? error;

  const ChatDetailState({
    this.status = AsyncStatus.initial,
    this.activeChatId,
    this.messages = const <Map<String, dynamic>>[],
    this.isSending = false,
    this.error,
  });

  ChatDetailState copyWith({
    AsyncStatus? status,
    String? activeChatId,
    bool clearActiveChatId = false,
    List<Map<String, dynamic>>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) {
    return ChatDetailState(
      status: status ?? this.status,
      activeChatId: clearActiveChatId
          ? null
          : (activeChatId ?? this.activeChatId),
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
