import 'package:neobazaar/core/state/async_status.dart';

class WalletTopupState {
  final AsyncStatus status;
  final int amount;
  final String provider;
  final int currentTokenBalance;
  final String? error;

  const WalletTopupState({
    this.status = AsyncStatus.initial,
    this.amount = 0,
    this.provider = 'esewa',
    this.currentTokenBalance = 0,
    this.error,
  });

  WalletTopupState copyWith({
    AsyncStatus? status,
    int? amount,
    String? provider,
    int? currentTokenBalance,
    String? error,
    bool clearError = false,
  }) {
    return WalletTopupState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      provider: provider ?? this.provider,
      currentTokenBalance: currentTokenBalance ?? this.currentTokenBalance,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
