import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/trade/data/repositories/trade_repository_impl.dart';
import 'package:neobazaar/features/trade/domain/repositories/trade_repository.dart';

class AppendDisputeEvidenceParams extends Equatable {
  final String txnId;
  final Map<String, dynamic> payload;

  const AppendDisputeEvidenceParams({
    required this.txnId,
    required this.payload,
  });

  @override
  List<Object?> get props => <Object?>[txnId, payload];
}

final appendDisputeEvidenceUsecaseProvider =
    Provider<AppendDisputeEvidenceUsecase>((ref) {
      return AppendDisputeEvidenceUsecase(
        repository: ref.read(tradeRepositoryProvider),
      );
    });

class AppendDisputeEvidenceUsecase
    implements
        UsecaseWithParams<Map<String, dynamic>, AppendDisputeEvidenceParams> {
  final ITradeRepository _repository;

  AppendDisputeEvidenceUsecase({required ITradeRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    AppendDisputeEvidenceParams params,
  ) {
    return _repository.appendDisputeEvidence(params.txnId, params.payload);
  }
}
