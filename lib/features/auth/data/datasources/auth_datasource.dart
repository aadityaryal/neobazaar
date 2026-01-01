import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();

  // get email exists 
  Future<bool> isEmailExists(String email);

}