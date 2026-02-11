import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';
import 'package:neobazaar/features/admin/presentation/widgets/admin_capability_gate.dart';

class AdminModerationUndoPage extends ConsumerStatefulWidget {
  const AdminModerationUndoPage({super.key});

  @override
  ConsumerState<AdminModerationUndoPage> createState() =>
      _AdminModerationUndoPageState();
}

class _AdminModerationUndoPageState
    extends ConsumerState<AdminModerationUndoPage> {
  final TextEditingController _actionIdController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedActionId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(adminOperationsNotifierProvider.notifier).loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _actionIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);
    final actionIds = state.auditLogs
        .map((log) => log['payload'])
        .whereType<Map>()
        .map((payload) {
          final raw =
              payload['moderationActionId']?.toString() ??
              payload['actionId']?.toString();
          return raw?.trim() ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final effectiveActionId = _selectedActionId ?? _actionIdController.text.trim();
    final canSubmit =
        effectiveActionId.isNotEmpty && _reasonController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Moderation Undo')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (actionIds.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedActionId,
              decoration: const InputDecoration(
                labelText: 'Recent Moderation Action',
                border: OutlineInputBorder(),
              ),
              items: actionIds
                  .map(
                    (id) => DropdownMenuItem<String>(
                      value: id,
                      child: Text(id, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _selectedActionId = value;
                  if (value != null) {
                    _actionIdController.text = value;
                  }
                });
              },
            ),
          if (actionIds.isNotEmpty) const SizedBox(height: 8),
          TextField(
            controller: _actionIdController,
            decoration: const InputDecoration(
              labelText: 'Action ID',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {
                _selectedActionId = null;
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Undo Reason',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => notifier.loadAuditLogs(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh action IDs from audit logs'),
          ),
          const SizedBox(height: 8),
          AdminCapabilityGate(
            requiredCapabilities: const <String>{
              'admin:all',
              'admin:moderation:write',
            },
            child: ElevatedButton(
              onPressed: !canSubmit
                  ? null
                  : () {
                notifier.undoModerationAction(
                  effectiveActionId,
                  _reasonController.text.trim(),
                );
              },
              child: const Text('Undo Moderation Action'),
            ),
          ),
          if (state.error != null && state.error!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
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
