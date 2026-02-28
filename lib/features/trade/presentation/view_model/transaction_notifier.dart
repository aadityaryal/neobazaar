import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/trade/domain/entities/transaction_entity.dart';
import 'package:neobazaar/features/trade/domain/usecases/append_dispute_evidence_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/confirm_transaction_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/create_transaction_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/dispute_transaction_usecase.dart';
import 'package:neobazaar/features/trade/domain/usecases/list_transactions_usecase.dart';
import 'package:neobazaar/features/trade/presentation/state/transaction_state.dart';

final transactionNotifierProvider =
    NotifierProvider<TransactionNotifier, TransactionState>(
      TransactionNotifier.new,
    );

class TransactionNotifier extends Notifier<TransactionState> {
  late final CreateTransactionUsecase _createTransactionUsecase;
  late final ConfirmTransactionUsecase _confirmTransactionUsecase;
  late final ListTransactionsUsecase _listTransactionsUsecase;
  late final DisputeTransactionUsecase _disputeTransactionUsecase;
  late final AppendDisputeEvidenceUsecase _appendDisputeEvidenceUsecase;
  late final AnalyticsService _analyticsService;

  @override
  TransactionState build() {
    _createTransactionUsecase = ref.read(createTransactionUsecaseProvider);
    _confirmTransactionUsecase = ref.read(confirmTransactionUsecaseProvider);
    _listTransactionsUsecase = ref.read(listTransactionsUsecaseProvider);
    _disputeTransactionUsecase = ref.read(disputeTransactionUsecaseProvider);
    _appendDisputeEvidenceUsecase = ref.read(
      appendDisputeEvidenceUsecaseProvider,
    );
    _analyticsService = ref.read(analyticsServiceProvider);
    return const TransactionState();
  }

  void resetState() {
    state = const TransactionState();
  }

  Future<void> fetchHistory({String? status}) async {
    state = state.copyWith(
      createStatus: AsyncStatus.loading,
      errorMessage: null,
    );

    final result = await _listTransactionsUsecase(
      ListTransactionsParams(
        query: status == null ? null : <String, dynamic>{'status': status},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'transaction_history_fetch_error',
          properties: {'status': status, 'message': failure.message},
        );
        state = state.copyWith(
          createStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        _analyticsService.track(
          'transaction_history_fetch_success',
          properties: {'status': status, 'count': items.length},
        );
        state = state.copyWith(
          createStatus: AsyncStatus.success,
          transactions: items
              .map(
                (item) => _toEntity(
                  item,
                  fallbackAmount: item['amount'] as num? ?? 0,
                ),
              )
              .toList(),
          errorMessage: null,
        );
      },
    );
  }

  void selectTransactionForDispute(TransactionEntity transaction) {
    final createdAt = transaction.createdAt;
    final now = DateTime.now();
    // Backend dispute window is 48 hours from transaction creation.
    final canDispute = createdAt != null
      ? now.difference(createdAt).inHours <= 48
      : false;

    state = state.copyWith(
      selectedTransactionId: transaction.id,
      canDispute: canDispute,
      disputeTimeline: <String>[
        'Opened transaction ${transaction.id}',
        if (!canDispute) 'Dispute window expired',
      ],
    );
    _analyticsService.track(
      'transaction_dispute_selected',
      properties: {'transactionId': transaction.id, 'canDispute': canDispute},
    );
  }

  Future<void> submitDispute({required String reason}) async {
    final txnId = state.selectedTransactionId;
    if (txnId == null || txnId.isEmpty) {
      return;
    }

    state = state.copyWith(
      disputeStatus: AsyncStatus.loading,
      errorMessage: null,
    );
    final result = await _disputeTransactionUsecase(
      DisputeTransactionParams(
        txnId: txnId,
        payload: <String, dynamic>{'reason': reason},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'transaction_dispute_error',
          properties: {'transactionId': txnId, 'message': failure.message},
        );
        state = state.copyWith(
          disputeStatus: AsyncStatus.error,
          errorMessage: failure.message,
          disputeTimeline: <String>[...state.disputeTimeline, 'Dispute failed'],
        );
      },
      (_) {
        _analyticsService.track(
          'transaction_dispute_success',
          properties: {'transactionId': txnId},
        );
        state = state.copyWith(
          disputeStatus: AsyncStatus.success,
          disputeTimeline: <String>[
            ...state.disputeTimeline,
            'Dispute submitted',
          ],
        );
      },
    );
  }

  Future<void> appendDisputeEvidence({required String note}) async {
    final txnId = state.selectedTransactionId;
    if (txnId == null || txnId.isEmpty) {
      return;
    }

    final result = await _appendDisputeEvidenceUsecase(
      AppendDisputeEvidenceParams(
        txnId: txnId,
        payload: <String, dynamic>{'evidenceUrls': <String>[note]},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'transaction_evidence_error',
          properties: {'transactionId': txnId, 'message': failure.message},
        );
        state = state.copyWith(
          errorMessage: failure.message,
          disputeTimeline: <String>[
            ...state.disputeTimeline,
            'Evidence add failed',
          ],
        );
      },
      (_) {
        _analyticsService.track(
          'transaction_evidence_success',
          properties: {'transactionId': txnId},
        );
        state = state.copyWith(
          disputeTimeline: <String>[
            ...state.disputeTimeline,
            'Evidence attached',
          ],
        );
      },
    );
  }

  Future<void> create({required String productId, required num amount}) async {
    state = state.copyWith(
      createStatus: AsyncStatus.loading,
      errorMessage: null,
      showCompletionAnimation: false,
    );

    final result = await _createTransactionUsecase(
      CreateTransactionParams(
        payload: <String, dynamic>{
          'productId': productId,
          'tokenAmount': amount,
        },
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'transaction_create_error',
          properties: {'productId': productId, 'message': failure.message},
        );
        state = state.copyWith(
          createStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        final transaction = _toEntity(payload, fallbackAmount: amount);
        _analyticsService.track(
          'transaction_create_success',
          properties: {
            'transactionId': transaction.id,
            'productId': productId,
            'amount': amount,
          },
        );
        state = state.copyWith(
          createStatus: AsyncStatus.success,
          transaction: transaction,
          escrowVisualState: 'escrow',
          errorMessage: null,
        );
      },
    );
  }

  Future<void> confirm({required String actor}) async {
    final current = state.transaction;
    if (current == null) {
      return;
    }

    state = state.copyWith(
      confirmStatus: AsyncStatus.loading,
      errorMessage: null,
    );

    final result = await _confirmTransactionUsecase(
      ConfirmTransactionParams(
        txnId: current.id,
        payload: <String, dynamic>{'actor': actor},
      ),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'transaction_confirm_error',
          properties: {
            'transactionId': current.id,
            'actor': actor,
            'message': failure.message,
          },
        );
        state = state.copyWith(
          confirmStatus: AsyncStatus.error,
          errorMessage: failure.message,
        );
      },
      (payload) {
        var updated = _toEntity(payload, fallbackAmount: current.amount);
        if (actor == 'buyer' && !updated.buyerConfirmed) {
          updated = TransactionEntity(
            id: updated.id,
            productId: updated.productId,
            buyerId: updated.buyerId,
            sellerId: updated.sellerId,
            amount: updated.amount,
            status: updated.status,
            escrowEnabled: updated.escrowEnabled,
            buyerConfirmed: true,
            sellerConfirmed: updated.sellerConfirmed,
            disputeStatus: updated.disputeStatus,
            createdAt: updated.createdAt,
            updatedAt: updated.updatedAt,
          );
        }
        if (actor == 'seller' && !updated.sellerConfirmed) {
          updated = TransactionEntity(
            id: updated.id,
            productId: updated.productId,
            buyerId: updated.buyerId,
            sellerId: updated.sellerId,
            amount: updated.amount,
            status: updated.status,
            escrowEnabled: updated.escrowEnabled,
            buyerConfirmed: updated.buyerConfirmed,
            sellerConfirmed: true,
            disputeStatus: updated.disputeStatus,
            createdAt: updated.createdAt,
            updatedAt: updated.updatedAt,
          );
        }

        final isCompleted = updated.buyerConfirmed && updated.sellerConfirmed;
        _analyticsService.track(
          'transaction_confirm_success',
          properties: {
            'transactionId': updated.id,
            'actor': actor,
            'isCompleted': isCompleted,
          },
        );

        state = state.copyWith(
          confirmStatus: AsyncStatus.success,
          transaction: updated,
          escrowVisualState: isCompleted ? 'completed' : 'escrow',
          showCompletionAnimation: isCompleted,
          errorMessage: null,
        );
      },
    );
  }

  TransactionEntity _toEntity(
    Map<String, dynamic> payload, {
    required num fallbackAmount,
  }) {
    return TransactionEntity(
      id: (payload['txnId'] ?? payload['id'] ?? payload['_id'] ?? '')
          .toString(),
      productId: payload['productId']?.toString(),
      buyerId: payload['buyerId']?.toString(),
      sellerId: payload['sellerId']?.toString(),
      amount: payload['amount'] as num? ?? fallbackAmount,
      status: payload['status']?.toString() ?? 'pending',
      escrowEnabled: payload['escrowEnabled'] != false,
      buyerConfirmed: payload['buyerConfirmed'] == true,
      sellerConfirmed: payload['sellerConfirmed'] == true,
      disputeStatus: payload['disputeStatus']?.toString(),
      createdAt: DateTime.tryParse(payload['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(payload['updatedAt']?.toString() ?? ''),
    );
  }
}
