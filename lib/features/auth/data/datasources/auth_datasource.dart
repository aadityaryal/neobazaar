import 'package:neobazaar/features/auth/data/models/auth_api_model.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
import 'package:neobazaar/features/auth/data/models/kyc_models.dart';
import 'package:neobazaar/features/auth/data/models/profile_patch_request_model.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';

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
  Future<AuthApiModel> register(AuthApiModel user, {String? idempotencyKey});
  Future<AuthApiModel> login(
    String email,
    String password, {
    String? idempotencyKey,
  });
  Future<AuthApiModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthApiModel> getUserById(String authId);
  Future<List<AuthSessionEntity>> listSessions();
  Future<bool> revokeSession(String sessionId);
  Future<bool> revokeAllSessions();
  Future<Map<String, dynamic>> requestVerificationChallenge({
    required String channel,
    required String target,
  });
  Future<bool> submitVerificationCode({
    required String challengeId,
    required String code,
  });
  Future<bool> submitKyc({
    required String userId,
    required KycSubmitRequestModel request,
  });
  Future<bool> reviewKyc({
    required String userId,
    required KycReviewRequestModel request,
  });
  Future<AuthApiModel> patchUserProfile({
    required String userId,
    required ProfilePatchRequestModel request,
  });
}
