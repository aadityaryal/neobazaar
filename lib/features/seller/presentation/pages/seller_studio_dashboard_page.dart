import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/dashboard/presentation/pages/post_screen.dart';
import 'package:neobazaar/features/seller/presentation/pages/seller_bulk_import_page.dart';
import 'package:neobazaar/features/seller/presentation/pages/seller_payout_ledger_page.dart';
import 'package:neobazaar/features/seller/presentation/view_model/seller_studio_notifier.dart';

class SellerStudioDashboardPage extends ConsumerWidget {
  const SellerStudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerStudioNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Studio')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(sellerStudioNotifierProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            FilledButton.icon(
              onPressed: () {
                AppRoutes.push(context, const PostScreen());
              },
              icon: const Icon(Icons.add_box_rounded),
              label: const Text('Create Listing'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      AppRoutes.push(context, const SellerBulkImportPage());
                    },
                    child: const Text('Bulk Import'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      AppRoutes.push(context, const SellerPayoutLedgerPage());
                    },
                    child: const Text('Payout Ledger'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.status == AsyncStatus.loading &&
                state.listingsAnalytics.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (state.status == AsyncStatus.error &&
                state.listingsAnalytics.isEmpty)
              Center(child: Text(state.error ?? 'Unable to load analytics.'))
            else if (state.listingsAnalytics.isEmpty)
              const Text('No listing analytics found.')
            else
              ...state.listingsAnalytics.map(
                (item) => ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(item['title']?.toString() ?? 'Listing'),
                  subtitle: Text(
                    'Views: ${item['views']?.toString() ?? '-'} • '
                    'Clicks: ${item['clicks']?.toString() ?? '-'}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
