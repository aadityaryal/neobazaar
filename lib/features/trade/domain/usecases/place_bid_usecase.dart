import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class PlaceBidParams extends Equatable {
  final Map<String, dynamic> payload;

  const PlaceBidParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final placeBidUsecaseProvider = Provider<PlaceBidUsecase>((ref) {
  return PlaceBidUsecase(repository: ref.read(tradeRepositoryProvider));
});

class PlaceBidUsecase
    implements UsecaseWithParams<Map<String, dynamic>, PlaceBidParams> {
  final ITradeRepository _repository;

  PlaceBidUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(PlaceBidParams params) {
    return _repository.placeBid(params.payload);
  }
}
