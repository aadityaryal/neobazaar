import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';
import 'package:neobazaar/features/admin/presentation/widgets/admin_capability_gate.dart';

class AdminAuditRetentionPage extends ConsumerWidget {
  const AdminAuditRetentionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Audit Retention')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Run retention policy for audit logs.'),
          const SizedBox(height: 12),
          AdminCapabilityGate(
            requiredCapabilities: const <String>{
              'admin:all',
              'admin:audit:write',
            },
            child: ElevatedButton.icon(
              onPressed: () => notifier.runAuditRetention(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Retention'),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
