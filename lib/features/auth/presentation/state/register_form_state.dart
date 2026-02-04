import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/utils/form_validators.dart';

class RegisterFormState {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String location;
  final String? fullNameError;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;

  const RegisterFormState({
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.location = '',
    this.fullNameError,
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
  });

  RegisterFormState copyWith({
    String? fullName,
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
    String? location,
    String? fullNameError,
    String? usernameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
  }) {
    return RegisterFormState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      location: location ?? this.location,
      fullNameError: fullNameError,
      usernameError: usernameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
    );
  }
}

final registerFormStateProvider =
    NotifierProvider<RegisterFormStateNotifier, RegisterFormState>(
      RegisterFormStateNotifier.new,
    );

class RegisterFormStateNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void setFullName(String value) {
    state = state.copyWith(
      fullName: value,
      fullNameError: FormValidators.requiredField(
        value,
        fieldName: 'Full name',
      ),
    );
  }

  void setUsername(String value) {
    state = state.copyWith(
      username: value,
      usernameError: FormValidators.requiredField(value, fieldName: 'Username'),
    );
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      emailError: FormValidators.email(value),
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: FormValidators.password(value),
      confirmPasswordError: state.confirmPassword.isEmpty
          ? null
          : _confirmPasswordError(value, state.confirmPassword),
    );
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: _confirmPasswordError(state.password, value),
    );
  }

  void setLocation(String value) {
    state = state.copyWith(location: value);
  }

  void reset() {
    state = const RegisterFormState();
  }

  String? _confirmPasswordError(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirmation required';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    const String? noError = null;
    return noError;
  }
}
