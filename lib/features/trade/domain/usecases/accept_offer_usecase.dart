import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class AcceptOfferParams extends Equatable {
  final String offerId;
  final Map<String, dynamic> payload;

  const AcceptOfferParams({
    required this.offerId,
    this.payload = const <String, dynamic>{},
  });

  @override
  List<Object?> get props => <Object?>[offerId, payload];
}

final acceptOfferUsecaseProvider = Provider<AcceptOfferUsecase>((ref) {
  return AcceptOfferUsecase(repository: ref.read(tradeRepositoryProvider));
});

class AcceptOfferUsecase
    implements UsecaseWithParams<Map<String, dynamic>, AcceptOfferParams> {
  final ITradeRepository _repository;

  AcceptOfferUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(AcceptOfferParams params) {
    return _repository.acceptOffer(params.offerId, params.payload);
  }
}
