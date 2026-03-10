import 'package:neobazaar/core/state/async_status.dart';

class ChatSuggestionState {
  final AsyncStatus status;
  final List<String> suggestions;
  final String inputText;
  final String? error;

  const ChatSuggestionState({
    this.status = AsyncStatus.initial,
    this.suggestions = const <String>[],
    this.inputText = '',
    this.error,
  });

  ChatSuggestionState copyWith({
    AsyncStatus? status,
    List<String>? suggestions,
    String? inputText,
    String? error,
    bool clearError = false,
  }) {
    return ChatSuggestionState(
      status: status ?? this.status,
      suggestions: suggestions ?? this.suggestions,
      inputText: inputText ?? this.inputText,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
