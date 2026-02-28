import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class GetOrderTimelineParams extends Equatable {
  final String orderId;

  const GetOrderTimelineParams({required this.orderId});

  @override
  List<Object?> get props => <Object?>[orderId];
}

final getOrderTimelineUsecaseProvider = Provider<GetOrderTimelineUsecase>((
  ref,
) {
  return GetOrderTimelineUsecase(repository: ref.read(tradeRepositoryProvider));
});

class GetOrderTimelineUsecase
    implements
        UsecaseWithParams<List<Map<String, dynamic>>, GetOrderTimelineParams> {
  final ITradeRepository _repository;

  GetOrderTimelineUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetOrderTimelineParams params,
  ) {
    return _repository.getOrderTimeline(params.orderId);
  }
}
