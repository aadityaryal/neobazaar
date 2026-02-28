import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/transaction_entity.dart';

class TransactionState {
  final AsyncStatus createStatus;
  final AsyncStatus confirmStatus;
  final AsyncStatus disputeStatus;
  final TransactionEntity? transaction;
  final List<TransactionEntity> transactions;
  final String? selectedTransactionId;
  final bool canDispute;
  final List<String> disputeTimeline;
  final String escrowVisualState;
  final bool showCompletionAnimation;
  final String? errorMessage;

  const TransactionState({
    this.createStatus = AsyncStatus.initial,
    this.confirmStatus = AsyncStatus.initial,
    this.disputeStatus = AsyncStatus.initial,
    this.transaction,
    this.transactions = const <TransactionEntity>[],
    this.selectedTransactionId,
    this.canDispute = false,
    this.disputeTimeline = const <String>[],
    this.escrowVisualState = 'pending',
    this.showCompletionAnimation = false,
    this.errorMessage,
  });

  TransactionState copyWith({
    AsyncStatus? createStatus,
    AsyncStatus? confirmStatus,
    AsyncStatus? disputeStatus,
    Object? transaction = _transactionStateSentinel,
    List<TransactionEntity>? transactions,
    Object? selectedTransactionId = _transactionStateSentinel,
    bool? canDispute,
    List<String>? disputeTimeline,
    String? escrowVisualState,
    bool? showCompletionAnimation,
    Object? errorMessage = _transactionStateSentinel,
  }) {
    return TransactionState(
      createStatus: createStatus ?? this.createStatus,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      disputeStatus: disputeStatus ?? this.disputeStatus,
      transaction: transaction == _transactionStateSentinel
          ? this.transaction
          : transaction as TransactionEntity?,
      transactions: transactions ?? this.transactions,
      selectedTransactionId: selectedTransactionId == _transactionStateSentinel
          ? this.selectedTransactionId
          : selectedTransactionId as String?,
      canDispute: canDispute ?? this.canDispute,
      disputeTimeline: disputeTimeline ?? this.disputeTimeline,
      escrowVisualState: escrowVisualState ?? this.escrowVisualState,
      showCompletionAnimation:
          showCompletionAnimation ?? this.showCompletionAnimation,
      errorMessage: errorMessage == _transactionStateSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _transactionStateSentinel = Object();
