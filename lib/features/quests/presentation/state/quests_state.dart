import 'package:neobazaar/core/state/async_status.dart';

class QuestsState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> quests;
  final bool showCompletionConfetti;
  final String? error;

  const QuestsState({
    this.status = AsyncStatus.initial,
    this.quests = const <Map<String, dynamic>>[],
    this.showCompletionConfetti = false,
    this.error,
  });

  QuestsState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? quests,
    bool? showCompletionConfetti,
    String? error,
    bool clearError = false,
  }) {
    return QuestsState(
      status: status ?? this.status,
      quests: quests ?? this.quests,
      showCompletionConfetti:
          showCompletionConfetti ?? this.showCompletionConfetti,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
