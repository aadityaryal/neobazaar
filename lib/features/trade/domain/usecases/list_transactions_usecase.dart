import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class ListTransactionsParams extends Equatable {
  final Map<String, dynamic>? query;

  const ListTransactionsParams({this.query});

  @override
  List<Object?> get props => <Object?>[query];
}

final listTransactionsUsecaseProvider = Provider<ListTransactionsUsecase>((
  ref,
) {
  return ListTransactionsUsecase(repository: ref.read(tradeRepositoryProvider));
});

class ListTransactionsUsecase
    implements
        UsecaseWithParams<List<Map<String, dynamic>>, ListTransactionsParams> {
  final ITradeRepository _repository;

  ListTransactionsUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    ListTransactionsParams params,
  ) {
    return _repository.listTransactions(query: params.query);
  }
}
