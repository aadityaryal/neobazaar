

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/hive/hive_service.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource extends IAuthDatasource {
  final HiveService _hiveService;
  static const _loggedInUserKey = 'logged_in_user_id';

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;
      
  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_loggedInUserKey);
      if (userId != null) {
        final user = _hiveService.getCurrentUser(userId);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_loggedInUserKey, user.authId);
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInUserKey);
      await _hiveService.logoutUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }
}