import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class CreateReviewParams extends Equatable {
  final Map<String, dynamic> payload;

  const CreateReviewParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final createReviewUsecaseProvider = Provider<CreateReviewUsecase>((ref) {
  return CreateReviewUsecase(repository: ref.read(tradeRepositoryProvider));
});

class CreateReviewUsecase
    implements UsecaseWithParams<Map<String, dynamic>, CreateReviewParams> {
  final ITradeRepository _repository;

  CreateReviewUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    CreateReviewParams params,
  ) {
    return _repository.createReview(params.payload);
  }
}
