import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/providers/app_settings_provider.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/core/usecases/app_bootstrap_usecase.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/usecases/list_sessions_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/login_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/register_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/request_verification_challenge_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/revoke_all_sessions_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/revoke_session_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/submit_verification_code_usecase.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';
import 'package:neobazaar/features/trade/presentation/view_model/transaction_notifier.dart';
import 'package:uuid/uuid.dart';

// providier
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  RegisterUsecase get _registerUsecase => ref.read(registerUsecaseProvider);
  LoginUsecase get _loginUsecase => ref.read(loginUsecaseProvider);
  AppBootstrapUsecase get _appBootstrapUsecase =>
      ref.read(appBootstrapUsecaseProvider);
  ListSessionsUsecase get _listSessionsUsecase =>
      ref.read(listSessionsUsecaseProvider);
  RevokeSessionUsecase get _revokeSessionUsecase =>
      ref.read(revokeSessionUsecaseProvider);
  RevokeAllSessionsUsecase get _revokeAllSessionsUsecase =>
      ref.read(revokeAllSessionsUsecaseProvider);
  RequestVerificationChallengeUsecase
  get _requestVerificationChallengeUsecase =>
      ref.read(requestVerificationChallengeUsecaseProvider);
  SubmitVerificationCodeUsecase get _submitVerificationCodeUsecase =>
      ref.read(submitVerificationCodeUsecaseProvider);
  UserSessionService get _userSessionService =>
      ref.read(userSessionServiceProvider);
  AnalyticsService get _analyticsService => ref.read(analyticsServiceProvider);
  final Uuid _uuid = const Uuid();
  bool _isProcessing = false; // Add flag

  @override
  AuthState build() {
    return const AuthState(); // Changed to return an instance
  }

  Future<void> bootstrapSession() async {
    final bootstrap = await _appBootstrapUsecase();

    state = state.copyWith(
      sessionChecked: true,
      status: bootstrap.isAuthenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
      authEntity: bootstrap.user,
      errorMessage: bootstrap.errorMessage,
      clearVerificationChallenge: !bootstrap.isAuthenticated,
    );

    if (bootstrap.isAuthenticated) {
      _syncCapabilitiesFromToken();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    String? campus,
    String? location,
  }) async {
    if (_isProcessing) return; // Prevent duplicate calls
    _isProcessing = true;
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      location: location,
      idempotencyKey: _uuid.v4(),
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        _analyticsService.track(
          'auth_register_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          status: AuthStatus.error,
          sessionChecked: true,
          errorMessage: _mapRegisterError(failure.message),
        );
      },
      (isRegistered) {
        _analyticsService.track('auth_register_success');
        state = state.copyWith(
          status: AuthStatus.registered,
          sessionChecked: true,
          clearError: true,
        );
      },
    );
    _isProcessing = false; // Reset after
  }

  // login
  Future<void> login({required String email, required String password}) async {
    if (_isProcessing) return; // Prevent duplicate calls
    _isProcessing = true;
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(
      email: email,
      password: password,
      idempotencyKey: _uuid.v4(),
    );
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        _analyticsService.track(
          'auth_login_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          status: AuthStatus.error,
          sessionChecked: true,
          errorMessage: _mapLoginError(failure.message),
        );
      },
      (authEntity) {
        _analyticsService.track(
          'auth_login_success',
          properties: {'userId': authEntity.authId},
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          sessionChecked: true,
          authEntity: authEntity,
          clearError: true,
        );
        ref.read(appSessionProvider.notifier).setAuthenticated(authEntity);
        _syncCapabilitiesFromToken();
        ref.read(transactionNotifierProvider.notifier).resetState();
      },
    );
    _isProcessing = false; // Reset after
  }

  // logout
  Future<void> logout() async {
    await _userSessionService.clearUserSession();
    await ref.read(appSettingsProvider.notifier).resetUiMode();
    ref.read(appSessionProvider.notifier).clearSession();
    ref.read(capabilityCacheProvider.notifier).clear();
    ref.read(transactionNotifierProvider.notifier).resetState();
    _analyticsService.track('auth_logout');
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      sessionChecked: true,
      authEntity: null,
      activeSessions: const [],
      clearVerificationChallenge: true,
      clearError: true,
    );
  }

  Future<void> fetchSessions() async {
    final result = await _listSessionsUsecase();
    result.fold(
      (failure) {
        _analyticsService.track(
          'verification_challenge_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
          clearVerificationChallenge: true,
        );
      },
      (sessions) {
        state = state.copyWith(activeSessions: sessions, clearError: true);
      },
    );
  }

  Future<void> revokeSession(String sessionId) async {
    final result = await _revokeSessionUsecase(
      RevokeSessionUsecaseParams(sessionId: sessionId),
    );

    if (result.isLeft()) {
      result.fold((failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      }, (_) {});
      return;
    }

    await fetchSessions();
  }

  Future<void> revokeAllSessions() async {
    final result = await _revokeAllSessionsUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(activeSessions: const []);
      },
    );
  }

  Future<void> requestVerification({
    required String channel,
    required String target,
  }) async {
    final result = await _requestVerificationChallengeUsecase(
      RequestVerificationChallengeParams(channel: channel, target: target),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          verificationStatus: VerificationStatus.failed,
          errorMessage: failure.message,
        );
      },
      (challenge) {
        final challengeId = challenge['challengeId']?.toString();
        final devCode = challenge['devCode']?.toString();
        _analyticsService.track(
          'verification_challenge_requested',
          properties: {'channel': channel},
        );
        state = state.copyWith(
          verificationStatus: VerificationStatus.challengeRequested,
          verificationChallengeId: challengeId,
          verificationDevCode: devCode,
          clearError: true,
        );
      },
    );
  }

  Future<void> submitVerification({
    required String challengeId,
    required String code,
  }) async {
    final result = await _submitVerificationCodeUsecase(
      SubmitVerificationCodeParams(challengeId: challengeId, code: code),
    );

    result.fold(
      (failure) {
        _analyticsService.track(
          'verification_submit_error',
          properties: {'message': failure.message},
        );
        state = state.copyWith(
          verificationStatus: VerificationStatus.failed,
          errorMessage: failure.message,
        );
      },
      (_) {
        _analyticsService.track('verification_submit_success');
        state = state.copyWith(
          verificationStatus: VerificationStatus.verified,
          clearError: true,
        );
      },
    );
  }

  void syncProfile(AuthEntity authEntity) {
    state = state.copyWith(authEntity: authEntity);
  }

  Future<void> resetState() async {
    await ref.read(appSettingsProvider.notifier).resetUiMode();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      sessionChecked: true,
    );
  }

  String _mapRegisterError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('email') &&
        (normalized.contains('exists') || normalized.contains('already'))) {
      return 'This email is already registered. Please use a different email or log in.';
    }
    return message;
  }

  String _mapLoginError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('401') ||
        normalized.contains('unauthorized') ||
        normalized.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    return message;
  }

  void _syncCapabilitiesFromToken() {
    final token = _userSessionService.getAuthToken();
    if (token == null || token.isEmpty) {
      ref.read(capabilityCacheProvider.notifier).clear();
      return;
    }

    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        ref.read(capabilityCacheProvider.notifier).clear();
        return;
      }

      final payloadPart = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(payloadPart));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

      final capabilities = <String>{};
      final role = payload['role']?.toString();
      if (role != null && role.isNotEmpty) {
        capabilities.add('role:$role');
        if (role == 'admin') {
          capabilities.add('admin:access');
        }
      }

      final scopes = payload['scopes'];
      if (scopes is List) {
        for (final scope in scopes) {
          final text = scope?.toString();
          if (text != null && text.isNotEmpty) {
            capabilities.add(text);
          }
        }
      }

      ref.read(capabilityCacheProvider.notifier).replaceAll(capabilities);
    } catch (_) {
      ref.read(capabilityCacheProvider.notifier).clear();
    }
  }
}
