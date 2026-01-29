import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/error/failures.dart';
import 'package:neobazaar/core/providers/shared_prefs_provider.dart';
import 'package:neobazaar/core/services/storage/storage_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/usecases/get_current_usecase.dart';

class AppBootstrapData {
  final bool sessionChecked;
  final bool isAuthenticated;
  final AuthEntity? user;
  final String themeMode;
  final String languageCode;
  final String uiMode;
  final String? errorMessage;

  const AppBootstrapData({
    required this.sessionChecked,
    required this.isAuthenticated,
    required this.user,
    required this.themeMode,
    required this.languageCode,
    required this.uiMode,
    this.errorMessage,
  });
}

final appBootstrapUsecaseProvider = Provider<AppBootstrapUsecase>((ref) {
  return AppBootstrapUsecase(
    getCurrentUsecase: ref.read(getCurrentUsecaseProvider),
    storageService: ref.read(storageServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AppBootstrapUsecase {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _languageCodeKey = 'app_language_code';
  static const String _uiModeKey = 'app_ui_mode';

  final GetCurrentUsecase _getCurrentUsecase;
  final StorageService _storageService;
  final UserSessionService _userSessionService;

  AppBootstrapUsecase({
    required GetCurrentUsecase getCurrentUsecase,
    required StorageService storageService,
    required UserSessionService userSessionService,
  }) : _getCurrentUsecase = getCurrentUsecase,
       _storageService = storageService,
       _userSessionService = userSessionService;

  Future<AppBootstrapData> call() async {
    final themeMode = _storageService.getString(_themeModeKey) ?? 'system';
    final languageCode = _storageService.getString(_languageCodeKey) ?? 'en';
    final uiMode = _storageService.getString(_uiModeKey) ?? 'buyer';

    final locallyLoggedIn = _userSessionService.isLoggedIn();
    final hasAuthToken =
        (_userSessionService.getAuthToken()?.isNotEmpty ?? false);
    if (!locallyLoggedIn || !hasAuthToken) {
      if (locallyLoggedIn && !hasAuthToken) {
        await _userSessionService.clearUserSession();
      }
      return AppBootstrapData(
        sessionChecked: true,
        isAuthenticated: false,
        user: null,
        themeMode: themeMode,
        languageCode: languageCode,
        uiMode: uiMode,
      );
    }

    final result = await _getCurrentUsecase();
    if (result.isRight()) {
      final user = result.getOrElse(
        () => _localFallbackUser(),
      );
      return AppBootstrapData(
        sessionChecked: true,
        isAuthenticated: true,
        user: user,
        themeMode: themeMode,
        languageCode: languageCode,
        uiMode: uiMode,
      );
    }

    final failure = result.swap().getOrElse(
      () => throw StateError('Expected failure for left Either'),
    );

    if (_isBackendUnreachable(failure)) {
      return AppBootstrapData(
        sessionChecked: true,
        isAuthenticated: true,
        user: _localFallbackUser(),
        themeMode: themeMode,
        languageCode: languageCode,
        uiMode: uiMode,
        errorMessage: failure.message,
      );
    }

    if (_isAuthCheckFailure(failure)) {
      await _userSessionService.clearUserSession();
    }

    return AppBootstrapData(
      sessionChecked: true,
      isAuthenticated: false,
      user: null,
      themeMode: themeMode,
      languageCode: languageCode,
      uiMode: uiMode,
      errorMessage: failure.message,
    );
  }

  bool _isBackendUnreachable(Failure failure) {
    if (failure is ApiFailure && failure.statusCode != null) {
      return false;
    }

    final normalized = failure.message.toLowerCase();
    return normalized.contains('connection') ||
        normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('host lookup') ||
        normalized.contains('connection reset') ||
        normalized.contains('interrupted') ||
        normalized.contains('connection closed');
  }

  bool _isAuthCheckFailure(Failure failure) {
    if (failure is ApiFailure && failure.statusCode == 401) {
      return true;
    }

    if (_isBackendUnreachable(failure)) {
      return false;
    }

    final normalized = failure.message.toLowerCase();
    return normalized.contains('unauthorized') ||
        normalized.contains('session expired') ||
        normalized.contains('invalid token');
  }

  AuthEntity _localFallbackUser() {
    return AuthEntity(
      authId: _userSessionService.getUserId(),
      fullName: _userSessionService.getUserFullName() ?? '',
      email: _userSessionService.getUserEmail() ?? '',
      phoneNumber: _userSessionService.getUserPhoneNumber(),
      username: _userSessionService.getUsername() ?? '',
      profilePicture: _userSessionService.getUserProfileImage(),
      neoTokens: _userSessionService.getNeoTokens(),
      xp: _userSessionService.getXp(),
    );
  }
}
