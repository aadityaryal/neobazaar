import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class ListOffersParams extends Equatable {
  final Map<String, dynamic>? query;

  const ListOffersParams({this.query});

  @override
  List<Object?> get props => <Object?>[query];
}

final listOffersUsecaseProvider = Provider<ListOffersUsecase>((ref) {
  return ListOffersUsecase(repository: ref.read(tradeRepositoryProvider));
});

class ListOffersUsecase
    implements UsecaseWithParams<List<Map<String, dynamic>>, ListOffersParams> {
  final ITradeRepository _repository;

  ListOffersUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    ListOffersParams params,
  ) {
    return _repository.listOffers(query: params.query);
  }
}
