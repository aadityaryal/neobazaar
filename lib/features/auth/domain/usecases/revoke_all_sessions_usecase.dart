import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

final revokeAllSessionsUsecaseProvider = Provider<RevokeAllSessionsUsecase>((
  ref,
) {
  final authRepository = ref.read(authRepositoryProvider);
  return RevokeAllSessionsUsecase(authRepository: authRepository);
});

class RevokeAllSessionsUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  RevokeAllSessionsUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.revokeAllSessions();
  }
}
