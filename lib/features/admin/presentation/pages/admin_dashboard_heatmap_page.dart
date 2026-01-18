import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/admin/presentation/view_model/admin_operations_notifier.dart';

class AdminDashboardHeatmapPage extends ConsumerStatefulWidget {
  const AdminDashboardHeatmapPage({super.key});

  @override
  ConsumerState<AdminDashboardHeatmapPage> createState() =>
      _AdminDashboardHeatmapPageState();
}

class _AdminDashboardHeatmapPageState
    extends ConsumerState<AdminDashboardHeatmapPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(adminOperationsNotifierProvider.notifier).loadHeatmap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOperationsNotifierProvider);
    final heatmap = state.heatmap;
    final pointsRaw = heatmap?['points'];
    final points = pointsRaw is List
        ? pointsRaw.whereType<Map>().toList(growable: false)
        : const <Map>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Heatmap')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(adminOperationsNotifierProvider.notifier).loadHeatmap(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (state.status == AsyncStatus.loading && heatmap == null)
              const Center(child: CircularProgressIndicator())
            else if (heatmap == null)
              Text(state.error ?? 'No heatmap data available.')
            else ...[
              Text('Active users: ${heatmap['activeUsers'] ?? '-'}'),
              const SizedBox(height: 6),
              Text('Transactions: ${heatmap['transactions'] ?? '-'}'),
              const SizedBox(height: 6),
              Text('Flags: ${heatmap['flags'] ?? '-'}'),
              const SizedBox(height: 12),
              Text(
                'Heatmap points by location',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (points.isEmpty)
                const Text(
                  'No completed-transaction location data yet. Complete transactions to populate heatmap points.',
                )
              else
                ...points.map((point) {
                  final location = point['location']?.toString() ?? '-';
                  final count = point['count']?.toString() ?? '0';
                  final lat = point['lat']?.toString() ?? '0';
                  final lng = point['lng']?.toString() ?? '0';
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(location),
                    subtitle: Text('lat: $lat, lng: $lng'),
                    trailing: Text(count),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
