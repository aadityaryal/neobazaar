import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/auth/presentation/pages/login_screen.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import '../widgets/my_textformfield.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _messageShown = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.loading) {
        _messageShown = false; // Reset for new attempt
      } else if (next.status == AuthStatus.registered && !_messageShown) {
        SnackbarUtils.showSuccess(
          context,
          'Registration successful! Please login.',
        );
        _messageShown = true;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      } else if (next.status == AuthStatus.error && !_messageShown) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration failed',
        );
        _messageShown = true;
      }
    });

    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Register for NeoBazaar',
                    style: TextStyle(
                      color: Color(0xFF6B46C1),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  MyTextFormField(
                    controller: userNameController,
                    label: "Full Name",
                    hint: "Enter your full name.",
                    error: "Name required",
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: usernameController,
                    label: "Username",
                    hint: "Enter your username.",
                    error: "Username required",
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'Enter email',
                    error: 'Email required',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter secure password',
                    error: 'Password required',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter password',
                    error: 'Confirmation required',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirmation required';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),
                  GradientButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref
                            .read(authViewModelProvider.notifier)
                            .register(
                              fullName: userNameController.text,
                              email: emailController.text,
                              username: usernameController.text,
                              password: passwordController.text,
                            );
                      }
                    },
                    text: 'Register',
                    isLoading: authState.status == AuthStatus.loading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6B46C1),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
