// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:neobazaar/core/services/hive/hive_service.dart';
// import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
// import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Provider
// final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
//   final hiveService = ref.watch(hiveServiceProvider);
//   return AuthLocalDatasource(hiveService: hiveService);
// });

// class AuthLocalDatasource extends IAuthLocalDataSource {
//   final HiveService _hiveService;
//   static const _loggedInUserKey = 'logged_in_user_id';

//   AuthLocalDatasource({required HiveService hiveService})
//       : _hiveService = hiveService;

//   @override
//   Future<AuthHiveModel?> getCurrentUser() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString(_loggedInUserKey);
//       if (userId != null) {
//         final user = _hiveService.getCurrentUser(userId);
//         return user;
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<bool> isEmailExists(String email) {
//     try {
//       final exists = _hiveService.isEmailExists(email);
//       return Future.value(exists);
//     } catch (e) {
//       return Future.value(false);
//     }
//   }

//   @override
//   Future<AuthHiveModel?> login(String email, String password) async {
//     try {
//       final user = await _hiveService.loginUser(email, password);
//       if (user != null) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_loggedInUserKey, user.authId);
//       }
//       return user;
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Future<bool> logout() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_loggedInUserKey);
//       await _hiveService.logoutUser();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<bool> register(AuthHiveModel model) async {
//     try {
//       await _hiveService.registerUser(model);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<AuthHiveModel?> getUserByEmail(String email) {
//     // Pending implementation: getUserByEmail
//     throw UnimplementedError();
//   }

//   @override
//   Future<AuthHiveModel> getUserById(String authId) {
//     // Pending implementation: getUserById
//     throw UnimplementedError();
//   }
// }

//Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/hive/hive_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final userId = _userSessionService.getUserId();
      if (userId == null || userId.isEmpty) {
        return null;
      }
      return _hiveService.getCurrentUser(userId);
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
      final user = await _hiveService.login(email, password);
      // user ko details lai shared prefs ma savw garne
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: email,
          username: user.username,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profileImage: user.profilePicture ?? '',
        );
      }
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      await _userSessionService.clearUserSession();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel> getUserById(String authId) {
    final user = _hiveService.getCurrentUser(authId);
    if (user == null) {
      throw Exception('User not found for id: $authId');
    }
    return Future.value(user);
  }
}
