import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class AppendOrderTimelineParams extends Equatable {
  final String orderId;
  final Map<String, dynamic> payload;

  const AppendOrderTimelineParams({
    required this.orderId,
    required this.payload,
  });

  @override
  List<Object?> get props => <Object?>[orderId, payload];
}

final appendOrderTimelineUsecaseProvider = Provider<AppendOrderTimelineUsecase>(
  (ref) {
    return AppendOrderTimelineUsecase(
      repository: ref.read(tradeRepositoryProvider),
    );
  },
);

class AppendOrderTimelineUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, AppendOrderTimelineParams> {
  final ITradeRepository _repository;

  AppendOrderTimelineUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    AppendOrderTimelineParams params,
  ) {
    return _repository.appendOrderTimeline(params.orderId, params.payload);
  }
}
