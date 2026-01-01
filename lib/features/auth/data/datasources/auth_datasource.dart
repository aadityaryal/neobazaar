import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';

abstract class AuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String authId);
  Future<bool> logout(String authId);
}