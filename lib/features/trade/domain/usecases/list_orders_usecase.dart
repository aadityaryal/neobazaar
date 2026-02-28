import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class ListOrdersParams extends Equatable {
  final Map<String, dynamic>? query;

  const ListOrdersParams({this.query});

  @override
  List<Object?> get props => <Object?>[query];
}

final listOrdersUsecaseProvider = Provider<ListOrdersUsecase>((ref) {
  return ListOrdersUsecase(repository: ref.read(tradeRepositoryProvider));
});

class ListOrdersUsecase
    implements UsecaseWithParams<List<Map<String, dynamic>>, ListOrdersParams> {
  final ITradeRepository _repository;

  ListOrdersUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    ListOrdersParams params,
  ) {
    return _repository.listOrders(query: params.query);
  }
}
