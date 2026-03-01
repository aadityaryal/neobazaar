import 'package:neobazaar/core/state/async_status.dart';

class ReferralCenterState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> referrals;
  final String? error;

  const ReferralCenterState({
    this.status = AsyncStatus.initial,
    this.referrals = const <Map<String, dynamic>>[],
    this.error,
  });

  ReferralCenterState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? referrals,
    String? error,
    bool clearError = false,
  }) {
    return ReferralCenterState(
      status: status ?? this.status,
      referrals: referrals ?? this.referrals,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
