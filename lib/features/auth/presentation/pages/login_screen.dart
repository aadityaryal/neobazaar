// filepath: lib/features/auth/presentation/pages/login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:neobazaar/features/auth/presentation/pages/register_screen.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';
import 'package:neobazaar/features/auth/presentation/state/login_form_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:neobazaar/features/auth/presentation/widgets/auth_form_skeleton.dart';
import 'package:neobazaar/features/auth/presentation/widgets/my_textformfield.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _messageShown = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final loginFormState = ref.watch(loginFormStateProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && !_messageShown) {
        SnackbarUtils.showSuccess(context, 'Login successful!');
        _messageShown = true;
        final isAdmin = _isCurrentUserAdmin();
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                isAdmin
              ? const AdminDashboardPage()
                : const DashboardScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
          (route) => false,
        );
      } else if (next.status == AuthStatus.error && !_messageShown) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Login failed');
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
                  if (authState.status == AuthStatus.loading)
                    const AuthFormSkeleton(),
                  if (authState.status != AuthStatus.loading) ...[
                    if (authState.status == AuthStatus.error &&
                        (authState.errorMessage?.isNotEmpty ?? false))
                      AuthErrorBanner(
                        message: authState.errorMessage!,
                        onRetry: () {
                          if (_formKey.currentState!.validate()) {
                            _messageShown = false;
                            ref
                                .read(authViewModelProvider.notifier)
                                .login(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                          }
                        },
                      ),
                  ],
                  Image.asset(
                    'assets/images/onboarding/NeoBazaar_Logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Login to NeoBazaar',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  MyTextFormField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'Enter email (e.g., user@neobazaar.np)',
                    error: 'Email required',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      ref.read(loginFormStateProvider.notifier).setEmail(value);
                    },
                    validator: (_) => loginFormState.emailError,
                    semanticLabel: 'Login email input',
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Enter secure password',
                    error: 'Password required',
                    obscureText: true,
                    onChanged: (value) {
                      ref
                          .read(loginFormStateProvider.notifier)
                          .setPassword(value);
                    },
                    validator: (_) => loginFormState.passwordError,
                    semanticLabel: 'Login password input',
                  ),
                  const SizedBox(height: 48),
                  GradientButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _messageShown = false; // Reset for new attempt
                        // Removed manual snackbar here to prevent duplicates
                        ref
                            .read(authViewModelProvider.notifier)
                            .login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                      }
                    },
                    text: 'Login',
                    isLoading:
                        authState.status ==
                        AuthStatus.loading, // Add loading state
                    semanticLabel: 'Submit login form',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No Account? ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        autofocus: false,
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const RegisterScreen(),
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
                          foregroundColor: const Color(0xFFFFFFFF),
                        ),
                        child: const Text(
                          'Register',
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

  bool _isCurrentUserAdmin() {
    final token = ref.read(userSessionServiceProvider).getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length < 2) {
          return _isAdminFromCapabilities();
        }

        final payload = utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        );
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) {
          return _isAdminFromCapabilities();
        }

        final directRole = decoded['role']?.toString().toLowerCase();
        if (directRole == 'admin') {
          return true;
        }

        final nestedUser = decoded['user'];
        if (nestedUser is Map) {
          final nestedRole = nestedUser['role']?.toString().toLowerCase();
          if (nestedRole == 'admin') {
            return true;
          }
        }

        final roles = decoded['roles'];
        if (roles is List &&
            roles.any((item) => item?.toString().toLowerCase() == 'admin')) {
          return true;
        }

        return false;
      } catch (_) {
        return _isAdminFromCapabilities();
      }
    }

    return _isAdminFromCapabilities();
  }

  bool _isAdminFromCapabilities() {
    final cache = ref.read(capabilityCacheProvider);
    return cache.has('role:admin') ||
        cache.has('admin:access') ||
        cache.has('admin:all') ||
        cache.has('admin:*');
  }
}
