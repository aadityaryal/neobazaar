import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/risk/presentation/view_model/risk_score_notifier.dart';

class RiskScorePage extends ConsumerStatefulWidget {
  const RiskScorePage({super.key});

  @override
  ConsumerState<RiskScorePage> createState() => _RiskScorePageState();
}

class _RiskScorePageState extends ConsumerState<RiskScorePage> {
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(riskScoreNotifierProvider);
    final notifier = ref.read(riskScoreNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Risk Score')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (!state.isAuthorized)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('You are not authorized to view risk score data.'),
              ),
            )
          else ...[
            const Text('Authorized Risk Panel'),
            const SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                notifier.fetchRiskScore(_userIdController.text);
              },
              child: const Text('Fetch Score'),
            ),
          ],
          const SizedBox(height: 12),
          if (state.status == AsyncStatus.loading)
            const Center(child: CircularProgressIndicator()),
          if (state.error != null)
            Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (state.score != null) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score: ${state.score!['score']?.toString() ?? '-'}'),
                    const SizedBox(height: 4),
                    Text('Level: ${state.score!['level']?.toString() ?? '-'}'),
                    const SizedBox(height: 4),
                    Text(
                      'Reasons: ${state.score!['reasons']?.toString() ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
