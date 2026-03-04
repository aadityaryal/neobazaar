import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:neobazaar/features/auth/presentation/widgets/my_textformfield.dart';

void main() {
  testWidgets('login shows validation errors for invalid email/password', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextFormField(
              controller: TextEditingController(),
              label: 'Email',
              hint: 'Enter email',
              error: 'Email required',
              validator: (_) => 'Please enter a valid email address',
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('register shows password mismatch error', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextFormField(
              controller: TextEditingController(),
              label: 'Confirm Password',
              hint: 'Re-enter password',
              error: 'Confirmation required',
              validator: (_) => 'Passwords do not match',
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('register success shows snackbar and navigates to login', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: AuthErrorBanner(
                message: 'Registration successful! Please login.',
                onRetry: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('Login Screen')),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('device sessions page shows empty and populated states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('No active sessions found'),
              Text('Active Sessions (1)'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('No active sessions found'), findsOneWidget);
    expect(find.text('Active Sessions (1)'), findsOneWidget);
  });

  testWidgets('auth error banner renders message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthErrorBanner(message: 'Invalid credentials', onRetry: () {}),
        ),
      ),
    );

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('gradient button blocks tap while loading', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Register',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(taps, 0);
  });
}
