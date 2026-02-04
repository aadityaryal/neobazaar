import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_session_entity.dart';
import 'package:neobazaar/features/auth/presentation/state/auth_state.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';

class DeviceSessionsPage extends ConsumerStatefulWidget {
  const DeviceSessionsPage({super.key});

  @override
  ConsumerState<DeviceSessionsPage> createState() => _DeviceSessionsPageState();
}

class _DeviceSessionsPageState extends ConsumerState<DeviceSessionsPage> {
  final TextEditingController _verificationTargetController =
      TextEditingController();
  final TextEditingController _challengeIdController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  String _verificationChannel = 'email';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authViewModelProvider.notifier).fetchSessions();
    });
  }

  @override
  void dispose() {
    _verificationTargetController.dispose();
    _challengeIdController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    final challengeId = authState.verificationChallengeId;
    if (challengeId != null &&
        challengeId.isNotEmpty &&
        _challengeIdController.text != challengeId) {
      _challengeIdController.text = challengeId;
    }

    final devCode = authState.verificationDevCode;
    if (devCode != null &&
        devCode.isNotEmpty &&
        _verificationCodeController.text.isEmpty) {
      _verificationCodeController.text = devCode;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Device Sessions')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(authViewModelProvider.notifier).fetchSessions(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildVerificationPanel(context, authState),
            const SizedBox(height: 16),
            _buildHeader(context, authState.activeSessions),
            const SizedBox(height: 12),
            if (authState.errorMessage != null &&
                authState.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (authState.activeSessions.isEmpty)
              const Text(
                'No active sessions found. If you signed in with bearer token only, refresh after login to populate current device session.',
              )
            else
              ...authState.activeSessions.map((session) {
                return _SessionCard(
                  session: session,
                  onRevoke: () => _confirmRevokeSession(context, session),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<AuthSessionEntity> sessions) {
    return Row(
      children: [
        Text(
          'Active Sessions (${sessions.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        TextButton(
          onPressed: sessions.isEmpty ? null : () => _confirmRevokeAll(context),
          child: const Text('Revoke all'),
        ),
      ],
    );
  }

  Widget _buildVerificationPanel(BuildContext context, AuthState authState) {
    final verificationStatusText = switch (authState.verificationStatus) {
      VerificationStatus.challengeRequested =>
        'Challenge requested. Enter challenge id and code to verify.',
      VerificationStatus.verified => 'Verification completed.',
      VerificationStatus.failed => 'Verification failed. Try again.',
      _ => 'Request a verification challenge.',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verification',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(verificationStatusText),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _verificationChannel,
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'phone', child: Text('Phone')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _verificationChannel = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Channel'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _verificationTargetController,
              decoration: const InputDecoration(
                labelText: 'Target (email/phone)',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authViewModelProvider.notifier)
                    .requestVerification(
                      channel: _verificationChannel,
                      target: _verificationTargetController.text.trim(),
                    );
              },
              child: const Text('Request challenge'),
            ),
            const SizedBox(height: 12),
            if (authState.verificationChallengeId != null)
              Text(
                'Challenge ID: ${authState.verificationChallengeId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (authState.verificationDevCode != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Dev code (non-production): ${authState.verificationDevCode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _challengeIdController,
              decoration: const InputDecoration(labelText: 'Challenge ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _verificationCodeController,
              decoration: const InputDecoration(labelText: 'Verification code'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(authViewModelProvider.notifier)
                    .submitVerification(
                      challengeId: _challengeIdController.text.trim(),
                      code: _verificationCodeController.text.trim(),
                    );
              },
              child: const Text('Submit code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRevokeSession(
    BuildContext context,
    AuthSessionEntity session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Revoke Session'),
          content: Text(
            'Revoke session ${session.id}${session.current ? ' (current device)' : ''}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Revoke'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(authViewModelProvider.notifier).revokeSession(session.id);
    }
  }

  Future<void> _confirmRevokeAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Revoke All Sessions'),
          content: const Text('Revoke all active sessions on other devices?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Revoke all'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(authViewModelProvider.notifier).revokeAllSessions();
      await ref.read(authViewModelProvider.notifier).fetchSessions();
    }
  }
}

class _SessionCard extends StatelessWidget {
  final AuthSessionEntity session;
  final VoidCallback onRevoke;

  const _SessionCard({required this.session, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(session.userAgent ?? 'Unknown device'),
        subtitle: Text(session.ip ?? 'Unknown IP'),
        trailing: TextButton(onPressed: onRevoke, child: const Text('Revoke')),
      ),
    );
  }
}
