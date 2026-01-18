import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';

class AdminAuditLogsPage extends ConsumerStatefulWidget {
  const AdminAuditLogsPage({super.key});

  @override
  ConsumerState<AdminAuditLogsPage> createState() => _AdminAuditLogsPageState();
}

class _AdminAuditLogsPageState extends ConsumerState<AdminAuditLogsPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(adminOperationsNotifierProvider.notifier).loadAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Audit Logs')),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadAuditLogs(),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.auditLogs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final log = state.auditLogs[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(log['action']?.toString() ?? 'Audit event'),
              subtitle: Text(
                '${log['actor']?.toString() ?? '-'} • '
                '${log['createdAt']?.toString() ?? ''}',
              ),
            );
          },
        ),
      ),
    );
  }
}
