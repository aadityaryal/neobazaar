import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/usecases/app_usecase.dart';
import 'package:neobazaar/features/auth/data/repositories/auth_repository.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

class RequestVerificationChallengeParams extends Equatable {
  final String channel;
  final String target;

  const RequestVerificationChallengeParams({
    required this.channel,
    required this.target,
  });

  @override
  List<Object?> get props => <Object?>[channel, target];
}

final requestVerificationChallengeUsecaseProvider =
    Provider<RequestVerificationChallengeUsecase>((ref) {
      final authRepository = ref.read(authRepositoryProvider);
      return RequestVerificationChallengeUsecase(
        authRepository: authRepository,
      );
    });

class RequestVerificationChallengeUsecase
    implements
        UsecaseWithParams<
          Map<String, dynamic>,
          RequestVerificationChallengeParams
        > {
  final IAuthRepository _authRepository;

  RequestVerificationChallengeUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    RequestVerificationChallengeParams params,
  ) {
    return _authRepository.requestVerificationChallenge(
      channel: params.channel,
      target: params.target,
    );
  }
}
