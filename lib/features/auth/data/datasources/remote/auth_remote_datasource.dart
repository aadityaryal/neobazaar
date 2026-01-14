// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lost_and_found_mobile/core/api/api_client.dart';
// import 'package:lost_and_found_mobile/core/api/api_endpoints.dart';
// import 'package:lost_and_found_mobile/core/services/storage/user_session_service.dart';
// import 'package:lost_and_found_mobile/features/auth/data/datasources/auth_datasource.dart';
// import 'package:lost_and_found_mobile/features/auth/data/models/auth_api_model.dart';
// import 'package:lost_and_found_mobile/features/auth/data/models/auth_hive_model.dart';

// //provider
// final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
//   return AuthRemoteDatasource(
//     apiClient: ref.read(apiClientProvider),
//     userSessionService: ref.read(userSessionServiceProvider),
//   );
// });

// class AuthRemoteDatasource implements IAuthRemoteDataSource {
//   final ApiClient _apiClient;
//   final UserSessionService _userSessionService;

//   AuthRemoteDatasource({
//     required ApiClient apiClient,
//     required UserSessionService userSessionService,
//   }) : _apiClient = apiClient,
//        _userSessionService = userSessionService;

//   @override
//   Future<AuthApiModel> getUserById(String authId) {
//     // TODO: implement getUserById
//     throw UnimplementedError();
//   }

//   @override
//   Future<AuthApiModel?> login(String email, String password) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.studentLogin,
//       data: {'email': email, 'password': password},
//     );

//     if (response.data['success'] == true) {
//       final data = response.data['data'] as Map<String, dynamic>;
//       final user = AuthApiModel.fromJson(data);

//       //Save user session
//       await _userSessionService.saveUserSession(
//         userId: user.id!,
//         email: user.email,
//         username: user.username,
//         fullName: user.fullName,
//         phoneNumber: user.phoneNumber,
//         batchId: user.batchId,
//       );
//       return user;
//     }
//     return null;
//   }

//   @override
//   Future<AuthApiModel> register(AuthApiModel user) async {
//     final response = await _apiClient.post(
//       ApiEndpoints.students,
//       data: user.toJson(),
//     );

//     if (response.data['success'] == true) {
//       final data = response.data['data'] as Map<String, dynamic>;
//       final registeredUser = AuthApiModel.fromJson(data);
//       return registeredUser;
//     }

//     return user;
//   }
// }

// that to be implemented for my app.

import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';

//provider
final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final user = AuthApiModel.fromJson(data);
    return user;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      data: user.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final registeredUser = AuthApiModel.fromJson(data);
    return registeredUser;
  }

  @override
  Future<AuthApiModel> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}
