import 'package:neobazaar/core/state/async_status.dart';

class LeaderboardState {
  final AsyncStatus status;
  final String tab;
  final List<Map<String, dynamic>> entries;
  final String? error;

  const LeaderboardState({
    this.status = AsyncStatus.initial,
    this.tab = 'global',
    this.entries = const <Map<String, dynamic>>[],
    this.error,
  });

  LeaderboardState copyWith({
    AsyncStatus? status,
    String? tab,
    List<Map<String, dynamic>>? entries,
    String? error,
    bool clearError = false,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      tab: tab ?? this.tab,
      entries: entries ?? this.entries,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
