import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

final listSessionsUsecaseProvider = Provider<ListSessionsUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ListSessionsUsecase(authRepository: authRepository);
});

class ListSessionsUsecase
    implements UsecaseWithoutParams<List<AuthSessionEntity>> {
  final IAuthRepository _authRepository;

  ListSessionsUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, List<AuthSessionEntity>>> call() {
    return _authRepository.listSessions();
  }
}
