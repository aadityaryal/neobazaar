import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/auth/domain/usecases/login_usecase.dart';
import 'package:neobazaar/features/auth/domain/usecases/register_usecase.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState();  // Changed to return an instance
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
  }) async {
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
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: "Registration failed",
          );
        }
      },
    );
  }
}