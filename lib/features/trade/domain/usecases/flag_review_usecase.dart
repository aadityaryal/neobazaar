import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class FlagReviewParams extends Equatable {
  final String reviewId;
  final Map<String, dynamic> payload;

  const FlagReviewParams({required this.reviewId, required this.payload});

  @override
  List<Object?> get props => <Object?>[reviewId, payload];
}

final flagReviewUsecaseProvider = Provider<FlagReviewUsecase>((ref) {
  return FlagReviewUsecase(repository: ref.read(tradeRepositoryProvider));
});

class FlagReviewUsecase
    implements UsecaseWithParams<Map<String, dynamic>, FlagReviewParams> {
  final ITradeRepository _repository;

  FlagReviewUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(FlagReviewParams params) {
    return _repository.flagReview(params.reviewId, params.payload);
  }
}
