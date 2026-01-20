import 'package:neobazaar/core/state/async_status.dart';

class ChatReadReceiptState {
  final AsyncStatus status;
  final Map<String, bool> receiptByMessageId;
  final String? error;

  const ChatReadReceiptState({
    this.status = AsyncStatus.initial,
    this.receiptByMessageId = const <String, bool>{},
    this.error,
  });

  ChatReadReceiptState copyWith({
    AsyncStatus? status,
    Map<String, bool>? receiptByMessageId,
    String? error,
    bool clearError = false,
  }) {
    return ChatReadReceiptState(
      status: status ?? this.status,
      receiptByMessageId: receiptByMessageId ?? this.receiptByMessageId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
