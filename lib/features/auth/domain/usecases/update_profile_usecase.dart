import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<AuthEntity, AuthEntity> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(AuthEntity params) {
    return _authRepository.updateProfile(params);
  }
}
