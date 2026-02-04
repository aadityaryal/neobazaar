import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/utils/form_validators.dart';

class LoginFormState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
    );
  }
}

final loginFormStateProvider =
    NotifierProvider<LoginFormStateNotifier, LoginFormState>(
      LoginFormStateNotifier.new,
    );

class LoginFormStateNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: FormValidators.email(email),
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: FormValidators.password(password),
    );
  }

  void reset() {
    state = const LoginFormState();
  }
}
