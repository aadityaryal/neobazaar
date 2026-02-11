import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';
import 'package:neobazaar/features/admin/presentation/widgets/admin_capability_gate.dart';

class AdminFlagsTriagePage extends ConsumerStatefulWidget {
  const AdminFlagsTriagePage({super.key});

  @override
  ConsumerState<AdminFlagsTriagePage> createState() =>
      _AdminFlagsTriagePageState();
}

class _AdminFlagsTriagePageState extends ConsumerState<AdminFlagsTriagePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(adminOperationsNotifierProvider.notifier).loadFlags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Flags Triage')),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadFlags(),
        child: state.flags.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No unresolved flags right now. Pull to refresh.'),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.flags.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final flag = state.flags[index];
                  final id =
                      flag['flagId']?.toString() ?? flag['id']?.toString() ?? '';
                  final subject =
                      flag['subject']?.toString() ?? 'Flag ${index + 1}';
                  final status = flag['status']?.toString() ?? 'pending';
                  final sellerId = flag['sellerId']?.toString() ?? '-';
                  final reason = flag['reason']?.toString() ?? '-';

                  return ListTile(
                    title: Text(subject),
                    subtitle: Text(
                      'Flag ID: ${id.isEmpty ? '-' : id}\n'
                      'Seller: $sellerId\n'
                      'Reason: $reason\n'
                      'Status: $status',
                    ),
                    isThreeLine: true,
                    trailing: AdminCapabilityGate(
                      requiredCapabilities: const <String>{
                        'admin:all',
                        'admin:flags:write',
                      },
                      fallback: const Text('Read-only'),
                      child: PopupMenuButton<String>(
                        tooltip: 'Update moderation status for $subject',
                        onSelected: id.isEmpty
                            ? null
                            : (value) => notifier.updateFlag(id, value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'approved',
                            child: Text('Approve'),
                          ),
                          PopupMenuItem(
                            value: 'rejected',
                            child: Text('Reject'),
                          ),
                          PopupMenuItem(
                            value: 'escalated',
                            child: Text('Escalate'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
