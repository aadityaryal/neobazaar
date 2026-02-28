import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class DisputeTransactionParams extends Equatable {
  final String txnId;
  final Map<String, dynamic> payload;

  const DisputeTransactionParams({required this.txnId, required this.payload});

  @override
  List<Object?> get props => <Object?>[txnId, payload];
}

final disputeTransactionUsecaseProvider = Provider<DisputeTransactionUsecase>((
  ref,
) {
  return DisputeTransactionUsecase(
    repository: ref.read(tradeRepositoryProvider),
  );
});

class DisputeTransactionUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, DisputeTransactionParams> {
  final ITradeRepository _repository;

  DisputeTransactionUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    DisputeTransactionParams params,
  ) {
    return _repository.disputeTransaction(params.txnId, params.payload);
  }
}
