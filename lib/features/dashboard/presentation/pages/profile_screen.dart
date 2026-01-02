import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/auth/presentation/pages/login_screen.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';

class ProfileScreens extends ConsumerWidget {
  const ProfileScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Name: ${user.fullName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Username: ${user.username}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
            ] else ...[
              const Text('No user data available'),
            ],
            const Spacer(),
            GradientButton(
              onPressed: () {
                ref.read(authViewModelProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              text:'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
