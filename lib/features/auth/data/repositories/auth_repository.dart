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
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
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
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDataSource = authDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Invalid credentials'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login Failed',
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

    // try {
    //   final user = await _authDataSource.login(email, password);
    //   if (user != null) {
    //     final entity = user.toEntity();
    //     return Right(entity);
    //   }
    //   return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    // } catch (e) {
    //   return Left(LocalDatabaseFailure(message: e.toString()));
    // }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
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
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration Failed',
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
}
