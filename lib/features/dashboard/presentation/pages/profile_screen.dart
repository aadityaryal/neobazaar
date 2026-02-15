import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/widgets/gradient_button.dart';
import 'package:neobazaar/features/auth/presentation/pages/device_sessions_page.dart';
import 'package:neobazaar/features/auth/presentation/pages/login_screen.dart';
import 'package:neobazaar/features/auth/presentation/state/profile_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/settings_page.dart';
import 'package:neobazaar/features/wallet/presentation/pages/wallet_topup_page.dart';

class ProfileScreens extends ConsumerWidget {
  const ProfileScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.authEntity != null) {
        ref.read(profileViewModelProvider.notifier).initialize(next.authEntity);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (user != null) ...[
              TextFormField(
                initialValue: profileState.fullName.isEmpty
                    ? user.fullName
                    : profileState.fullName,
                decoration: const InputDecoration(labelText: 'Full name'),
                onChanged: ref
                    .read(profileViewModelProvider.notifier)
                    .setFullName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: profileState.username.isEmpty
                    ? user.username
                    : profileState.username,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: ref
                    .read(profileViewModelProvider.notifier)
                    .setUsername,
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue:
                    profileState.phoneNumber ?? user.phoneNumber ?? '',
                decoration: const InputDecoration(labelText: 'Phone'),
                onChanged: ref
                    .read(profileViewModelProvider.notifier)
                    .setPhoneNumber,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: profileState.location ?? user.location ?? '',
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: ref
                    .read(profileViewModelProvider.notifier)
                    .setLocation,
              ),
              const SizedBox(height: 10),
              if (profileState.errorMessage != null)
                Text(
                  profileState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: profileState.saveStatus == ProfileSaveStatus.saving
                    ? null
                    : () => ref
                          .read(profileViewModelProvider.notifier)
                          .saveProfile(),
                child: Text(
                  profileState.saveStatus == ProfileSaveStatus.saving
                      ? 'Saving...'
                      : 'Save Profile',
                ),
              ),
            ] else ...[
              const Text('No user data available'),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WalletTopupPage()),
                );
              },
              child: const Text('Open Wallet'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceSessionsPage()),
                );
              },
              child: const Text('Manage Device Sessions'),
            ),
            const SizedBox(height: 24),
            GradientButton(
              onPressed: () {
                ref.read(authViewModelProvider.notifier).logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              text: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
