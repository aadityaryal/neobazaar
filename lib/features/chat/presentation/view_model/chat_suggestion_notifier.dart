import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/presentation/state/chat_suggestion_state.dart';

final chatSuggestionNotifierProvider =
    NotifierProvider<ChatSuggestionNotifier, ChatSuggestionState>(
      ChatSuggestionNotifier.new,
    );

class ChatSuggestionNotifier extends Notifier<ChatSuggestionState> {
  static const int suggestionDebounceMs = 600;

  Timer? _debounceTimer;
  late final AnalyticsService _analyticsService;

  @override
  ChatSuggestionState build() {
    _analyticsService = ref.read(analyticsServiceProvider);
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _debounceTimer = null;
    });

    return const ChatSuggestionState();
  }

  void updateInput(String value) {
    state = state.copyWith(inputText: value, clearError: true);
  }

  void insertSuggestionToInput(String suggestion) {
    final existing = state.inputText.trimRight();
    final separator = existing.isEmpty ? '' : ' ';
    final nextInput = '$existing$separator$suggestion'.trimLeft();

    state = state.copyWith(inputText: nextInput, clearError: true);
    _analyticsService.track(
      'chat_suggestion_inserted',
      properties: {'inputLength': nextInput.length},
    );
  }

  Future<void> requestSuggestionsDebounced({
    required String chatId,
    required String messageInput,
  }) async {
    _debounceTimer?.cancel();

    if (messageInput.trim().isEmpty) {
      state = state.copyWith(
        status: AsyncStatus.initial,
        suggestions: const <String>[],
        clearError: true,
      );
      return;
    }

    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track(
      'chat_suggestion_request_started',
      properties: {
        'chatId': chatId,
        'inputLength': messageInput.length,
        'debounceMs': suggestionDebounceMs,
      },
    );

    final completer = Completer<void>();
    _debounceTimer = Timer(
      const Duration(milliseconds: suggestionDebounceMs),
      () async {
        try {
          final datasource = ref.read(chatRemoteDatasourceProvider);
          final response = await datasource.suggestReplies(<String, dynamic>{
            'chatId': chatId,
            'text': messageInput,
          });

          final suggestions = response
              .map(_extractSuggestionText)
              .where((value) => value.isNotEmpty)
              .toList(growable: false);

          state = state.copyWith(
            status: AsyncStatus.success,
            suggestions: suggestions,
            clearError: true,
          );
          _analyticsService.track(
            'chat_suggestion_request_success',
            properties: {'chatId': chatId, 'count': suggestions.length},
          );
          completer.complete();
        } catch (error) {
          _analyticsService.track(
            'chat_suggestion_request_error',
            properties: {'chatId': chatId, 'message': error.toString()},
          );
          state = state.copyWith(
            status: AsyncStatus.error,
            suggestions: const <String>[],
            error: error.toString(),
          );
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  String _extractSuggestionText(Map<String, dynamic> item) {
    final candidates = <dynamic>[
      item['text'],
      item['suggestion'],
      item['value'],
      item['label'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString() ?? '';
      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }
}
