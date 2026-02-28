import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class CreateOfferParams extends Equatable {
  final Map<String, dynamic> payload;

  const CreateOfferParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final createOfferUsecaseProvider = Provider<CreateOfferUsecase>((ref) {
  return CreateOfferUsecase(repository: ref.read(tradeRepositoryProvider));
});

class CreateOfferUsecase
    implements UsecaseWithParams<Map<String, dynamic>, CreateOfferParams> {
  final ITradeRepository _repository;

  CreateOfferUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CreateOfferParams params) {
    return _repository.createOffer(params.payload);
  }
}
