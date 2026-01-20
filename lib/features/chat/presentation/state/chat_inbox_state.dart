import 'package:neobazaar/core/state/async_status.dart';

class ChatInboxState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> chats;
  final String? error;

  const ChatInboxState({
    this.status = AsyncStatus.initial,
    this.chats = const <Map<String, dynamic>>[],
    this.error,
  });

  ChatInboxState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? chats,
    String? error,
    bool clearError = false,
  }) {
    return ChatInboxState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
