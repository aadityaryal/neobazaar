import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_realtime_remote_datasource.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/presentation/state/chat_read_receipt_state.dart';

final chatReadReceiptNotifierProvider =
    NotifierProvider<ChatReadReceiptNotifier, ChatReadReceiptState>(
      ChatReadReceiptNotifier.new,
    );

class ChatReadReceiptNotifier extends Notifier<ChatReadReceiptState> {
  StreamSubscription<Map<String, dynamic>>? _receiptEventSubscription;

  @override
  ChatReadReceiptState build() {
    final realtimeDatasource = ref.read(chatRealtimeDatasourceProvider);

    _receiptEventSubscription?.cancel();
    _receiptEventSubscription = realtimeDatasource
        .watchChatMessageReceiptUpdatedV1Events()
        .listen(_onReceiptEvent);

    ref.onDispose(() {
      _receiptEventSubscription?.cancel();
      _receiptEventSubscription = null;
    });

    return const ChatReadReceiptState();
  }

  Future<void> markMessageRead({
    required String chatId,
    required String messageId,
  }) async {
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(chatRemoteDatasourceProvider);
      final response = await datasource.markMessageRead(
        chatId,
        messageId,
        <String, dynamic>{'read': true},
      );

      final isRead = _extractReadValue(response) ?? true;
      _applyReceipt(messageId: messageId, isRead: isRead);
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  void _onReceiptEvent(Map<String, dynamic> eventEnvelope) {
    final payload = _asMap(eventEnvelope['payload']);
    final messageId =
        payload['messageId']?.toString() ?? payload['id']?.toString();
    if (messageId == null || messageId.isEmpty) {
      return;
    }

    final isRead = _extractReadValue(payload) ?? true;
    _applyReceipt(messageId: messageId, isRead: isRead);
  }

  void _applyReceipt({required String messageId, required bool isRead}) {
    final nextReceipts = <String, bool>{
      ...state.receiptByMessageId,
      messageId: isRead,
    };

    state = state.copyWith(
      status: AsyncStatus.success,
      receiptByMessageId: nextReceipts,
      clearError: true,
    );
  }

  bool? _extractReadValue(Map<String, dynamic> payload) {
    final direct = payload['read'];
    if (direct is bool) {
      return direct;
    }

    final statusValue = payload['status']?.toString().toLowerCase();
    if (statusValue == 'read') {
      return true;
    }
    if (statusValue == 'sent' || statusValue == 'delivered') {
      return false;
    }

    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }
}
