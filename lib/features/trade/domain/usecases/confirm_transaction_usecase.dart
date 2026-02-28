import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class ConfirmTransactionParams extends Equatable {
  final String txnId;
  final Map<String, dynamic> payload;

  const ConfirmTransactionParams({required this.txnId, required this.payload});

  @override
  List<Object?> get props => <Object?>[txnId, payload];
}

final confirmTransactionUsecaseProvider = Provider<ConfirmTransactionUsecase>((
  ref,
) {
  return ConfirmTransactionUsecase(
    repository: ref.read(tradeRepositoryProvider),
  );
});

class ConfirmTransactionUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, ConfirmTransactionParams> {
  final ITradeRepository _repository;

  ConfirmTransactionUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    ConfirmTransactionParams params,
  ) {
    return _repository.confirmTransaction(params.txnId, params.payload);
  }
}
