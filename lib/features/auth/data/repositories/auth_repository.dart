import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:neobazaar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';

// provider 
final authRepositoryProvider = Provider<IAuthRepository>((ref){
  return AuthRepository(authDatasource: ref.watch(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository{
  final IAuthDatasource _authDatasource;

    AuthRepository({required IAuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async{
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));      
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final user= await _authDatasource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: "Invalid email or password"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));      
    }

  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to logout user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));      
    }

  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async{

    try {
      // convert to model
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Failed to register user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));      
    }

  }
}