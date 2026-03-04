import 'package:flutter_test/flutter_test.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';

void main() {
  test('login state flow: idle -> loading -> authenticated', () {
    const initial = AuthState(status: AuthStatus.initial);
    final loading = initial.copyWith(status: AuthStatus.loading);
    final authenticated = loading.copyWith(status: AuthStatus.authenticated);

    expect(initial.status, AuthStatus.initial);
    expect(loading.status, AuthStatus.loading);
    expect(authenticated.status, AuthStatus.authenticated);
  });

  test('register failure sets error state and message', () {
    const initial = AuthState(status: AuthStatus.loading);
    final failed = initial.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Registration failed',
    );

    expect(failed.status, AuthStatus.error);
    expect(failed.errorMessage, 'Registration failed');
  });

  test('clearError removes previous message', () {
    const withError = AuthState(
      status: AuthStatus.error,
      errorMessage: 'Old error',
    );

    final cleared = withError.copyWith(clearError: true);

    expect(cleared.errorMessage, isNull);
  });
}
