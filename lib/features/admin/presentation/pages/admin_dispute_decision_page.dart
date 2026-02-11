import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';
import 'package:neobazaar/features/admin/presentation/widgets/admin_capability_gate.dart';

class AdminDisputeDecisionPage extends ConsumerStatefulWidget {
  const AdminDisputeDecisionPage({super.key});

  @override
  ConsumerState<AdminDisputeDecisionPage> createState() =>
      _AdminDisputeDecisionPageState();
}

class _AdminDisputeDecisionPageState
    extends ConsumerState<AdminDisputeDecisionPage> {
  final TextEditingController _disputeIdController = TextEditingController();
  String? _selectedDisputeId;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(adminOperationsNotifierProvider.notifier).loadDisputes();
    });
  }

  @override
  void dispose() {
    _disputeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);
    final disputes = state.disputes
        .where((item) {
          final status = item['status']?.toString();
          return status == 'open' || status == 'under_review';
        })
        .toList(growable: false);

    final effectiveId = _selectedDisputeId ?? _disputeIdController.text.trim();
    final canSubmit = effectiveId.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dispute Decision')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (disputes.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _selectedDisputeId,
              decoration: const InputDecoration(
                labelText: 'Open Dispute',
                border: OutlineInputBorder(),
              ),
              items: disputes
                  .map(
                    (dispute) {
                      final disputeId =
                          dispute['disputeId']?.toString() ??
                          dispute['id']?.toString() ??
                          '';
                      final transactionId =
                          dispute['transactionId']?.toString() ?? '-';
                      final label =
                          '$disputeId • txn: $transactionId • ${dispute['status'] ?? 'open'}';
                      return DropdownMenuItem<String>(
                        value: disputeId,
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    },
                  )
                  .where((item) => item.value != null && item.value!.isNotEmpty)
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _selectedDisputeId = value;
                  if (value != null) {
                    _disputeIdController.text = value;
                  }
                });
              },
            ),
          if (disputes.isNotEmpty) const SizedBox(height: 12),
          TextField(
            controller: _disputeIdController,
            decoration: const InputDecoration(
              labelText: 'Dispute ID',
              semanticCounterText: 'Dispute identifier input',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {
                _selectedDisputeId = null;
              });
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => notifier.loadDisputes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh open disputes'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AdminCapabilityGate(
                  requiredCapabilities: const <String>{
                    'admin:all',
                    'admin:disputes:write',
                  },
                  child: ElevatedButton(
                    autofocus: false,
                    onPressed: !canSubmit
                        ? null
                        : () {
                      notifier.decideDispute(
                        effectiveId,
                        'refund_buyer',
                      );
                    },
                    child: const Text('Decide Buyer'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AdminCapabilityGate(
                  requiredCapabilities: const <String>{
                    'admin:all',
                    'admin:disputes:write',
                  },
                  child: ElevatedButton(
                    autofocus: false,
                    onPressed: !canSubmit
                        ? null
                        : () {
                      notifier.decideDispute(
                        effectiveId,
                        'release_seller',
                      );
                    },
                    child: const Text('Decide Seller'),
                  ),
                ),
              ),
            ],
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
