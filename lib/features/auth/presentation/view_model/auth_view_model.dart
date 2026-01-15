import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/features/auth/domain/usecases/login_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/register_usecase.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';

// providier
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final UserSessionService _userSessionService;
  bool _isProcessing = false; // Add flag

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _userSessionService = ref.read(userSessionServiceProvider);
    return AuthState(); // Changed to return an instance
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (_isProcessing) return; // Prevent duplicate calls
    _isProcessing = true;
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
    _isProcessing = false; // Reset after
  }

  // login
  Future<void> login({required String email, required String password}) async {
    if (_isProcessing) return; // Prevent duplicate calls
    _isProcessing = true;
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
    _isProcessing = false; // Reset after
  }

  // logout
  Future<void> logout() async {
    await _userSessionService.clearUserSession();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
