import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';

class AdminExportJobsPage extends ConsumerStatefulWidget {
  const AdminExportJobsPage({super.key});

  @override
  ConsumerState<AdminExportJobsPage> createState() =>
      _AdminExportJobsPageState();
}

class _AdminExportJobsPageState extends ConsumerState<AdminExportJobsPage> {
  Timer? _pollTimer;
  String? _activeJobId;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final notifier = ref.read(adminOperationsNotifierProvider.notifier);

    final job = _activeJobId == null
        ? null
        : state.exportJobsById[_activeJobId!];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Export Jobs')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ElevatedButton(
            onPressed: () async {
              final id = await notifier.createExportJob(const <String, dynamic>{
                'scope': 'full',
              });
              if (id == null) {
                return;
              }

              setState(() {
                _activeJobId = id;
              });
              _startPolling(id);
            },
            child: const Text('Create Export Job'),
          ),
          const SizedBox(height: 12),
          if (_activeJobId == null) const Text('No export job created yet.'),
          if (_activeJobId != null) ...[
            Text('Active Job: $_activeJobId'),
            const SizedBox(height: 8),
            Text('Status: ${job?['status']?.toString() ?? 'pending'}'),
            const SizedBox(height: 8),
            Text('Progress: ${job?['progress']?.toString() ?? '-'}'),
            const SizedBox(height: 8),
            Text('Download: ${job?['downloadUrl']?.toString() ?? '-'}'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                if (_activeJobId != null) {
                  notifier.refreshExportJob(_activeJobId!);
                }
              },
              child: const Text('Refresh Status'),
            ),
          ],
        ],
      ),
    );
  }

  void _startPolling(String jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await ref
          .read(adminOperationsNotifierProvider.notifier)
          .refreshExportJob(jobId);
      final state = ref.read(adminOperationsNotifierProvider);
      final status = state.exportJobsById[jobId]?['status']
          ?.toString()
          .toLowerCase();
      if (status == 'completed' || status == 'failed') {
        _pollTimer?.cancel();
      }
    });
  }
}
