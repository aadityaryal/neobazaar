import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<AuthHiveModel> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> logout();

  //get email exists
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> getUserById(String authId);
}