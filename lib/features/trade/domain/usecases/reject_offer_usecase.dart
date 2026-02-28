import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class RejectOfferParams extends Equatable {
  final String offerId;
  final Map<String, dynamic> payload;

  const RejectOfferParams({
    required this.offerId,
    this.payload = const <String, dynamic>{},
  });

  @override
  List<Object?> get props => <Object?>[offerId, payload];
}

final rejectOfferUsecaseProvider = Provider<RejectOfferUsecase>((ref) {
  return RejectOfferUsecase(repository: ref.read(tradeRepositoryProvider));
});

class RejectOfferUsecase
    implements UsecaseWithParams<Map<String, dynamic>, RejectOfferParams> {
  final ITradeRepository _repository;

  RejectOfferUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(RejectOfferParams params) {
    return _repository.rejectOffer(params.offerId, params.payload);
  }
}
