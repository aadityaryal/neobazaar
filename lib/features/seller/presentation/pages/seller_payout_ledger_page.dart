import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/seller/presentation/view_model/seller_studio_notifier.dart';

class SellerPayoutLedgerPage extends ConsumerStatefulWidget {
  const SellerPayoutLedgerPage({super.key});

  @override
  ConsumerState<SellerPayoutLedgerPage> createState() =>
      _SellerPayoutLedgerPageState();
}

class _SellerPayoutLedgerPageState
    extends ConsumerState<SellerPayoutLedgerPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(sellerStudioNotifierProvider.notifier).loadPayoutLedger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sellerStudioNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payout Ledger')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(sellerStudioNotifierProvider.notifier).loadPayoutLedger(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (state.payoutsLedger.isEmpty)
              const Text('No payout ledger entries yet.')
            else
              ...state.payoutsLedger.map(
                (entry) => ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(entry['amount']?.toString() ?? '-'),
                  subtitle: Text(
                    '${entry['status']?.toString() ?? 'unknown'} • '
                    '${entry['createdAt']?.toString() ?? ''}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
