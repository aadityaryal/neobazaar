import 'package:neobazaar/core/state/async_status.dart';

class RiskScoreState {
  final AsyncStatus status;
  final bool isAuthorized;
  final Map<String, dynamic>? score;
  final String? error;

  const RiskScoreState({
    this.status = AsyncStatus.initial,
    this.isAuthorized = false,
    this.score,
    this.error,
  });

  RiskScoreState copyWith({
    AsyncStatus? status,
    bool? isAuthorized,
    Map<String, dynamic>? score,
    bool clearScore = false,
    String? error,
    bool clearError = false,
  }) {
    return RiskScoreState(
      status: status ?? this.status,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      score: clearScore ? null : (score ?? this.score),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
