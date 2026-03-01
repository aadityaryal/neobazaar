import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/wallet/presentation/view_model/wallet_topup_notifier.dart';

class WalletTopupPage extends ConsumerStatefulWidget {
  const WalletTopupPage({super.key});

  @override
  ConsumerState<WalletTopupPage> createState() => _WalletTopupPageState();
}

class _WalletTopupPageState extends ConsumerState<WalletTopupPage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletTopupNotifierProvider);
    final notifier = ref.read(walletTopupNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Top-up')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: const Text('Current NeoTokens'),
              trailing: Text('${state.currentTokenBalance}'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Top-up Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              notifier.setAmount(int.tryParse(value) ?? 0);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: state.provider,
            items: WalletTopupNotifier.providers
                .map(
                  (provider) => DropdownMenuItem<String>(
                    value: provider,
                    child: Text(provider.toUpperCase()),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                notifier.setProvider(value);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Payment Provider',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: state.status == AsyncStatus.loading
                ? null
                : () => notifier.topUp(),
            child: state.status == AsyncStatus.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Top-up Wallet'),
          ),
          if (state.status == AsyncStatus.success)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Top-up completed successfully.'),
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
