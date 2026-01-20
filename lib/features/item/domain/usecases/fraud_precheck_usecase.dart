import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/extension_repository_impl.dart';
import 'package:neobazaar/features/item/domain/repositories/extension_repository.dart';

class FraudPrecheckParams extends Equatable {
  final Map<String, dynamic> payload;

  const FraudPrecheckParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final fraudPrecheckUsecaseProvider = Provider<FraudPrecheckUsecase>((ref) {
  return FraudPrecheckUsecase(
    repository: ref.read(extensionRepositoryProvider),
  );
});

class FraudPrecheckUsecase
    implements UsecaseWithParams<Map<String, dynamic>, FraudPrecheckParams> {
  final IExtensionRepository _repository;

  FraudPrecheckUsecase({required IExtensionRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    FraudPrecheckParams params,
  ) {
    return _repository.fraud(params.payload);
  }
}
