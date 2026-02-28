import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class ListProductReviewsParams extends Equatable {
  final String productId;

  const ListProductReviewsParams({required this.productId});

  @override
  List<Object?> get props => <Object?>[productId];
}

final listProductReviewsUsecaseProvider = Provider<ListProductReviewsUsecase>((
  ref,
) {
  return ListProductReviewsUsecase(
    repository: ref.read(tradeRepositoryProvider),
  );
});

class ListProductReviewsUsecase
    implements
        UsecaseWithParams<
          List<Map<String, dynamic>>,
          ListProductReviewsParams
        > {
  final ITradeRepository _repository;

  ListProductReviewsUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    ListProductReviewsParams params,
  ) {
    return _repository.listProductReviews(params.productId);
  }
}
