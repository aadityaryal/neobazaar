import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

class RevokeSessionUsecaseParams extends Equatable {
  final String sessionId;

  const RevokeSessionUsecaseParams({required this.sessionId});

  @override
  List<Object?> get props => <Object?>[sessionId];
}

final revokeSessionUsecaseProvider = Provider<RevokeSessionUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RevokeSessionUsecase(authRepository: authRepository);
});

class RevokeSessionUsecase
    implements UsecaseWithParams<bool, RevokeSessionUsecaseParams> {
  final IAuthRepository _authRepository;

  RevokeSessionUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RevokeSessionUsecaseParams params) {
    return _authRepository.revokeSession(params.sessionId);
  }
}
