import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/features/auth/data/datasources/auth_datasource.dart';
import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';
import 'package:neobazaar/features/auth/data/models/auth_remote_dtos.dart';
import 'package:neobazaar/features/auth/data/models/kyc_models.dart';
import 'package:neobazaar/features/auth/data/models/profile_patch_request_model.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';

final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final AnalyticsService _analyticsService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required AnalyticsService analyticsService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _analyticsService = analyticsService;

  dynamic _shapeOf(dynamic value) {
    if (value is Map) {
      final map = <String, dynamic>{};
      value.forEach((key, item) {
        map[key.toString()] = _shapeOf(item);
      });
      return map;
    }

    if (value is List) {
      return <String, dynamic>{'type': 'list', 'length': value.length};
    }

    return <String, dynamic>{'type': value.runtimeType.toString()};
  }

  void _trackAuthHttpError({
    required String eventName,
    required String endpoint,
    required Map<String, dynamic> requestBody,
    required DioException error,
  }) {
    _analyticsService.track(
      eventName,
      properties: <String, dynamic>{
        'url': '${ApiEndpoints.baseUrlV1}$endpoint',
        'path': endpoint,
        'method': error.requestOptions.method,
        'statusCode': error.response?.statusCode,
        'dioType': error.type.name,
        'dioMessage': error.message,
        'requestBodyShape': _shapeOf(requestBody),
        'responseBody': error.response?.data,
      },
    );
  }

  String? _extractTokenFromResponse(dynamic responseBody) {
    if (responseBody is! Map<String, dynamic>) {
      return null;
    }

    final topLevelToken = responseBody['token']?.toString();
    if (topLevelToken != null && topLevelToken.isNotEmpty) {
      return topLevelToken;
    }

    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      final dataToken = data['token']?.toString();
      if (dataToken != null && dataToken.isNotEmpty) {
        return dataToken;
      }
    }

    return null;
  }

  @override
  Future<AuthApiModel> login(
    String email,
    String password, {
    String? idempotencyKey,
  }) async {
    final payload = LoginRequestDto(email: email, password: password);
    final requestJson = payload.toJson();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: requestJson,
        options: idempotencyKey == null
            ? null
            : Options(
                headers: <String, dynamic>{
                  AppConstants.headerIdempotencyKey: idempotencyKey,
                },
              ),
      );

      final user = _apiClient.parseDataEnvelope<AuthApiModel>(
        response,
        (data) => AuthApiModel.fromJson(data as Map<String, dynamic>),
      );

      final token = _extractTokenFromResponse(response.data);
      if (token != null && token.isNotEmpty) {
        await _userSessionService.saveAuthToken(token);
      }

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        username: user.username,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        profileImage: user.profilePicture,
        neoTokens: user.neoTokens,
        xp: user.xp,
      );

      return user;
    } on DioException catch (error) {
      _trackAuthHttpError(
        eventName: 'auth_login_http_error',
        endpoint: ApiEndpoints.authLogin,
        requestBody: requestJson,
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<AuthApiModel> register(
    AuthApiModel user, {
    String? idempotencyKey,
  }) async {
    final payload = RegisterRequestDto(
      fullName: user.fullName,
      email: user.email,
      username: user.username,
      password: user.password ?? '',
      campus: user.campus,
      location: user.location,
    );
    final requestJson = payload.toJson();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: requestJson,
        options: idempotencyKey == null
            ? null
            : Options(
                headers: <String, dynamic>{
                  AppConstants.headerIdempotencyKey: idempotencyKey,
                },
              ),
      );

      final registeredUser = _apiClient.parseDataEnvelope<AuthApiModel>(
        response,
        (data) => AuthApiModel.fromJson(data as Map<String, dynamic>),
      );

      final token = _extractTokenFromResponse(response.data);
      if (token != null && token.isNotEmpty) {
        await _userSessionService.saveAuthToken(token);
      }

      return registeredUser;
    } on DioException catch (error) {
      _trackAuthHttpError(
        eventName: 'auth_register_http_error',
        endpoint: ApiEndpoints.authRegister,
        requestBody: requestJson,
        error: error,
      );
      rethrow;
    }
  }

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final response = await _apiClient.get(
      ApiEndpoints.authMe,
      options: Options(
        extra: <String, dynamic>{'suppressUnauthorizedLogout': true},
      ),
    );

    final user = _apiClient.parseDataEnvelope<AuthApiModel>(
      response,
      (data) => AuthApiModel.fromJson(data as Map<String, dynamic>),
    );

    await _userSessionService.saveUserSession(
      userId: user.id ?? '',
      email: user.email,
      username: user.username,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      profileImage: user.profilePicture,
      neoTokens: user.neoTokens,
      xp: user.xp,
    );

    return user;
  }

  @override
  Future<bool> logout() async {
    await _apiClient.post(ApiEndpoints.authLogout);
    await _userSessionService.clearUserSession();
    return true;
  }

  @override
  Future<List<AuthSessionEntity>> listSessions() async {
    final response = await _apiClient.get(ApiEndpoints.authSessions);

    return _apiClient.parseDataEnvelope<List<AuthSessionEntity>>(response, (
      data,
    ) {
      final list = data is List ? data : <dynamic>[];
      final sessions = list
          .whereType<Map<String, dynamic>>()
          .map(AuthSessionDto.fromJson)
          .toList();
      return AuthSessionDto.toEntityList(sessions);
    });
  }

  @override
  Future<bool> revokeSession(String sessionId) async {
    final payload = SessionRevokeRequestDto(sessionId: sessionId);
    await _apiClient.post(
      ApiEndpoints.authSessionsRevoke,
      data: payload.toJson(),
    );
    return true;
  }

  @override
  Future<bool> revokeAllSessions() async {
    await _apiClient.post(ApiEndpoints.authSessionsRevokeAll);
    return true;
  }

  @override
  Future<Map<String, dynamic>> requestVerificationChallenge({
    required String channel,
    required String target,
  }) async {
    final payload = VerificationChallengeRequestDto(
      channel: channel,
      target: target,
    );
    final response = await _apiClient.post(
      ApiEndpoints.authVerificationChallenge,
      data: payload.toJson(),
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      (data) =>
          (data as Map).map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<bool> submitVerificationCode({
    required String challengeId,
    required String code,
  }) async {
    final payload = VerificationSubmitRequestDto(
      challengeId: challengeId,
      code: code,
    );
    await _apiClient.post(
      ApiEndpoints.authVerificationSubmit,
      data: payload.toJson(),
    );
    return true;
  }

  @override
  Future<AuthApiModel> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(authId));

    return _apiClient.parseDataEnvelope<AuthApiModel>(
      response,
      (data) => AuthApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<bool> submitKyc({
    required String userId,
    required KycSubmitRequestModel request,
  }) async {
    await _apiClient.post(
      ApiEndpoints.userKycSubmit(userId),
      data: request.toJson(),
    );
    _analyticsService.track('kyc_submit', properties: {'userId': userId});
    return true;
  }

  @override
  Future<bool> reviewKyc({
    required String userId,
    required KycReviewRequestModel request,
  }) async {
    await _apiClient.post(
      ApiEndpoints.userKycReview(userId),
      data: request.toJson(),
    );
    _analyticsService.track('kyc_review', properties: {'userId': userId});
    return true;
  }

  @override
  Future<AuthApiModel> patchUserProfile({
    required String userId,
    required ProfilePatchRequestModel request,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.userById(userId),
      data: request.toJson(),
    );

    final updated = _apiClient.parseDataEnvelope<AuthApiModel>(
      response,
      (data) => AuthApiModel.fromJson(data as Map<String, dynamic>),
    );

    await _userSessionService.saveUserSession(
      userId: updated.id ?? userId,
      email: updated.email,
      username: updated.username,
      fullName: updated.fullName,
      phoneNumber: updated.phoneNumber,
      profileImage: updated.profilePicture,
      neoTokens: updated.neoTokens,
      xp: updated.xp,
    );

    return updated;
  }
}
