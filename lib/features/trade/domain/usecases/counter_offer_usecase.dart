import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class CounterOfferParams extends Equatable {
  final String offerId;
  final Map<String, dynamic> payload;

  const CounterOfferParams({required this.offerId, required this.payload});

  @override
  List<Object?> get props => <Object?>[offerId, payload];
}

final counterOfferUsecaseProvider = Provider<CounterOfferUsecase>((ref) {
  return CounterOfferUsecase(repository: ref.read(tradeRepositoryProvider));
});

class CounterOfferUsecase
    implements UsecaseWithParams<Map<String, dynamic>, CounterOfferParams> {
  final ITradeRepository _repository;

  CounterOfferUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    CounterOfferParams params,
  ) {
    return _repository.counterOffer(params.offerId, params.payload);
  }
}
