import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password, {
    String? idempotencyKey,
  });
  Future<Either<Failure, bool>> register(
    AuthEntity entity, {
    String? idempotencyKey,
  });
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, List<AuthSessionEntity>>> listSessions();
  Future<Either<Failure, bool>> revokeSession(String sessionId);
  Future<Either<Failure, bool>> revokeAllSessions();
  Future<Either<Failure, Map<String, dynamic>>> requestVerificationChallenge({
    required String channel,
    required String target,
  });
  Future<Either<Failure, bool>> submitVerificationCode({
    required String challengeId,
    required String code,
  });
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity entity);
}
