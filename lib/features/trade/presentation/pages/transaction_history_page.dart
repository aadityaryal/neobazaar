import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/features/trade/presentation/view_model/transaction_notifier.dart';

class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  String? _statusFilter;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transactionNotifierProvider.notifier).fetchHistory();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionNotifierProvider);
    final notifier = ref.read(transactionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by status',
              semanticCounterText: 'Transaction status filter',
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'escrow', child: Text('Escrow')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'disputed', child: Text('Disputed')),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value;
              });
              notifier.fetchHistory(status: value);
            },
          ),
          const SizedBox(height: 12),
          if (state.createStatus == AsyncStatus.loading)
            const Center(child: CircularProgressIndicator())
          else if (state.transactions.isEmpty)
            const Text('No transactions found.')
          else
            ...state.transactions.map(
              (transaction) => Card(
                child: ListTile(
                  title: Text('Txn ${transaction.id} • ${transaction.status}'),
                  subtitle: Text('Amount: ${transaction.amount}'),
                  trailing: TextButton(
                    autofocus: false,
                    onPressed: () {
                      notifier.selectTransactionForDispute(transaction);
                    },
                    child: const Text('Dispute'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (state.selectedTransactionId != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dispute Transaction: ${state.selectedTransactionId}'),
                    const SizedBox(height: 8),
                    Text(
                      state.canDispute
                          ? 'Dispute window active'
                          : 'Dispute action unavailable (window expired)',
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dispute reason',
                        hintText: 'Enter reason (min 10 chars)',
                        semanticCounterText: 'Dispute reason input',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: !state.canDispute
                          ? null
                          : () {
                              final reason = _reasonController.text.trim();
                              if (reason.length < 10) {
                                SnackbarUtils.showWarning(
                                  context,
                                  'Reason must be at least 10 characters',
                                );
                                return;
                              }
                              notifier.submitDispute(reason: reason);
                            },
                      child: const Text('Submit Dispute'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _evidenceController,
                      decoration: const InputDecoration(
                        labelText: 'Evidence note / file reference',
                        semanticCounterText: 'Dispute evidence input',
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        final note = _evidenceController.text.trim();
                        if (note.isEmpty) {
                          return;
                        }
                        notifier.appendDisputeEvidence(note: note);
                      },
                      child: const Text('Attach Evidence'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dispute Timeline',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    if (state.disputeTimeline.isEmpty)
                      const Text('No dispute events yet.')
                    else
                      ...state.disputeTimeline.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8),
                              const SizedBox(width: 8),
                              Expanded(child: Text(entry)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
