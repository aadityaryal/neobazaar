import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/features/auth/data/models/local_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

//provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  //Keys for storing data
  static const String _keysIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUsername = 'username';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserProfileImage = 'user_profile_image';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyNeoTokens = 'neo_tokens';
  static const String _keyXp = 'xp';

  //Store user session data
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
    required String fullName,
    required String? phoneNumber,
    String? profileImage,
    String? authToken,
    int? neoTokens,
    int? xp,
  }) async {
    await _prefs.setBool(_keysIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyUserFullName, fullName);
    if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (profileImage != null) {
      await _prefs.setString(_keyUserProfileImage, profileImage);
    }
    if (authToken != null && authToken.isNotEmpty) {
      await _prefs.setString(_keyAuthToken, authToken);
    }
    if (neoTokens != null) {
      await _prefs.setInt(_keyNeoTokens, neoTokens);
    }
    if (xp != null) {
      await _prefs.setInt(_keyXp, xp);
    }
  }

  //Clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keysIsLoggedIn);
    await _prefs.remove(_keyUserProfileImage);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyNeoTokens);
    await _prefs.remove(_keyXp);
  }

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keysIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUsername() {
    return _prefs.getString(_keyUsername);
  }

  String? getUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  String? getUserProfileImage() {
    return _prefs.getString(_keyUserProfileImage);
  }

  String? getCurrentUserId() {
    return getUserId();
  }

  int? getNeoTokens() {
    return _prefs.getInt(_keyNeoTokens);
  }

  int? getXp() {
    return _prefs.getInt(_keyXp);
  }

  Future<void> saveNeoTokens(int neoTokens) async {
    await _prefs.setInt(_keyNeoTokens, neoTokens);
  }

  Future<void> saveXp(int xp) async {
    await _prefs.setInt(_keyXp, xp);
  }

  LocalSessionModel getLocalSession() {
    return LocalSessionModel(
      isLoggedIn: isLoggedIn(),
      userId: getUserId(),
      email: getUserEmail(),
      username: getUsername(),
    );
  }
}
