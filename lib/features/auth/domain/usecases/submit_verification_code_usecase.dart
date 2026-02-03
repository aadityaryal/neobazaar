import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

class SubmitVerificationCodeParams extends Equatable {
  final String challengeId;
  final String code;

  const SubmitVerificationCodeParams({
    required this.challengeId,
    required this.code,
  });

  @override
  List<Object?> get props => <Object?>[challengeId, code];
}

final submitVerificationCodeUsecaseProvider =
    Provider<SubmitVerificationCodeUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return SubmitVerificationCodeUsecase(authRepository: authRepository);
    });

class SubmitVerificationCodeUsecase
    implements UsecaseWithParams<bool, SubmitVerificationCodeParams> {
  final IAuthRepository _authRepository;

  SubmitVerificationCodeUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(SubmitVerificationCodeParams params) {
    return _authRepository.submitVerificationCode(
      challengeId: params.challengeId,
      code: params.code,
    );
  }
}
