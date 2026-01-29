import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/services/connectivity/network_info.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:neobazaar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:neobazaar/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
import 'package:neobazaar/features/auth/data/models/profile_patch_request_model.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDataSource = ref.read(authLocalDatasourceProvider);
  final authRemoteDataSource = ref.read(authRemoteProvider);
  final nerworkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDataSource: authDataSource,
    authRemoteDataSource: authRemoteDataSource,
    networkInfo: nerworkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final INetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required INetworkInfo networkInfo,
  }) : _authDataSource = authDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

  String _extractApiMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final first = errors.first as Map;
        final detail = first['detail']?.toString();
        if (detail != null && detail.isNotEmpty) {
          return detail;
        }
      }

      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (body is String && body.isNotEmpty) {
      return body;
    }

    return fallback;
  }

  String _extractDioMessage(DioException error, String fallback) {
    final fromBody = _extractApiMessage(error.response?.data, fallback);
    if (fromBody != fallback) {
      return fromBody;
    }

    final direct = error.message?.trim();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final raw = error.error?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }

    return fallback;
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDataSource.getCurrentUser();
        if (user != null) {
          return Right(user.toEntity());
        }
        return const Left(ApiFailure(message: 'No active user session'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractDioMessage(e, 'Failed to get user'),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return const Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password, {
    String? idempotencyKey,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(
          email,
          password,
          idempotencyKey: idempotencyKey,
        );
        final entity = apiModel.toEntity();
        return Right(entity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractApiMessage(e.response?.data, 'Login Failed'),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: 'Invalid email or password'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _authRemoteDataSource.logout();
        if (result) {
          return const Right(true);
        }
        return const Left(ApiFailure(message: 'Failed to logout user'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Logout Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final result = await _authDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(
    AuthEntity user, {
    String? idempotencyKey,
  }) async {
    // try {
    //   //model ma convert gara
    //   final model = AuthHiveModel.fromEntity(entity);
    //   final result = await _authDataSource.register(model);
    //   if (result) {
    //     return Right(true);
    //   }
    //   return Left(LocalDatabaseFailure(message: 'Failed to register User'));
    // } catch (e) {
    //   return Left(LocalDatabaseFailure(message: e.toString()));
    // }
    if (await _networkInfo.isConnected) {
      // go to remote
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(
          apiModel,
          idempotencyKey: idempotencyKey,
        );
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: _extractApiMessage(
              e.response?.data,
              'Registration Failed',
            ),
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final exisitingUser = await _authDataSource.getUserByEmail(user.email);
        if (exisitingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }

        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          username: user.username,
          password: user.password,
          profilePicture: user.profilePicture,
          location: user.location,
          neoTokens: user.neoTokens,
          xp: user.xp,
          reputationScore: user.reputationScore,
          kycVerified: user.kycVerified,
          badges: user.badges,
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AuthSessionEntity>>> listSessions() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Session listing requires network connectivity'),
      );
    }

    try {
      final sessions = await _authRemoteDataSource.listSessions();
      return Right(sessions);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to list sessions',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> revokeSession(String sessionId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Session revoke requires network connectivity'),
      );
    }

    try {
      final success = await _authRemoteDataSource.revokeSession(sessionId);
      return Right(success);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to revoke session',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> revokeAllSessions() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'Revoke all sessions requires network connectivity',
        ),
      );
    }

    try {
      final success = await _authRemoteDataSource.revokeAllSessions();
      return Right(success);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to revoke sessions',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestVerificationChallenge({
    required String channel,
    required String target,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'Verification challenge requires network connectivity',
        ),
      );
    }

    try {
      final challenge = await _authRemoteDataSource
          .requestVerificationChallenge(channel: channel, target: target);
      return Right(challenge);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              'Failed to request verification challenge',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> submitVerificationCode({
    required String challengeId,
    required String code,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'Verification submit requires network connectivity',
        ),
      );
    }

    try {
      final success = await _authRemoteDataSource.submitVerificationCode(
        challengeId: challengeId,
        code: code,
      );
      return Right(success);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              'Failed to submit verification code',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(AuthEntity entity) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'Profile update requires network connectivity'),
      );
    }

    final userId = entity.authId;
    if (userId == null || userId.isEmpty) {
      return const Left(
        ApiFailure(message: 'Missing user id for profile update'),
      );
    }

    try {
      final request = ProfilePatchRequestModel(
        fullName: entity.fullName,
        username: entity.username,
        phoneNumber: entity.phoneNumber,
        // campus: entity.campus,
        location: entity.location,
        profilePicture: entity.profilePicture,
      );

      final updated = await _authRemoteDataSource.patchUserProfile(
        userId: userId,
        request: request,
      );

      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
