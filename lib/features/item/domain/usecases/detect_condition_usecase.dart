import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/item/data/repositories/extension_repository_impl.dart';
import 'package:neobazaar/features/item/domain/repositories/extension_repository.dart';

class DetectConditionParams extends Equatable {
  final Map<String, dynamic> payload;

  const DetectConditionParams({required this.payload});

  @override
  List<Object?> get props => <Object?>[payload];
}

final detectConditionUsecaseProvider = Provider<DetectConditionUsecase>((ref) {
  return DetectConditionUsecase(
    repository: ref.read(extensionRepositoryProvider),
  );
});

class DetectConditionUsecase
    implements UsecaseWithParams<Map<String, dynamic>, DetectConditionParams> {
  final IExtensionRepository _repository;

  DetectConditionUsecase({required IExtensionRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    DetectConditionParams params,
  ) {
    return _repository.detect(params.payload);
  }
}
