import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class CreateTransactionParams extends Equatable {
  final Map<String, dynamic> payload;

  const CreateTransactionParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final createTransactionUsecaseProvider = Provider<CreateTransactionUsecase>((
  ref,
) {
  return CreateTransactionUsecase(
    repository: ref.read(tradeRepositoryProvider),
  );
});

class CreateTransactionUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, CreateTransactionParams> {
  final ITradeRepository _repository;

  CreateTransactionUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    CreateTransactionParams params,
  ) {
    return _repository.createTransaction(params.payload);
  }
}
