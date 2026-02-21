import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/campaigns/presentation/state/campaigns_management_state.dart';
import 'package:neobazaar/features/campaigns/presentation/view_model/campaigns_management_notifier.dart';

class CampaignsManagementPage extends ConsumerWidget {
  const CampaignsManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(campaignsManagementNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaigns')),
      body: _buildBody(context, ref, state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(campaignsManagementNotifierProvider.notifier).createCampaign(
            const <String, dynamic>{'name': 'New Campaign', 'status': 'draft'},
          );
        },
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CampaignsManagementState state,
  ) {
    if (state.status == AsyncStatus.loading && state.campaigns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AsyncStatus.error && state.campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? 'Unable to load campaigns.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(campaignsManagementNotifierProvider.notifier)
                    .loadCampaigns();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.campaigns.isEmpty) {
      return const Center(child: Text('No campaigns found.'));
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(campaignsManagementNotifierProvider.notifier)
            .loadCampaigns();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.campaigns.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final campaign = state.campaigns[index];
          final campaignId =
              campaign['campaignId']?.toString() ??
              campaign['id']?.toString() ??
              '';
          final name = campaign['name']?.toString() ?? 'Campaign ${index + 1}';
          final status = campaign['status']?.toString() ?? 'unknown';

          return ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: Text(name),
            subtitle: Text('Status: $status'),
            trailing: PopupMenuButton<String>(
              onSelected: campaignId.isEmpty
                  ? null
                  : (value) {
                      ref
                          .read(campaignsManagementNotifierProvider.notifier)
                          .updateStatus(campaignId, value);
                    },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'draft', child: Text('Set Draft')),
                PopupMenuItem(value: 'active', child: Text('Set Active')),
                PopupMenuItem(value: 'paused', child: Text('Set Paused')),
                PopupMenuItem(value: 'closed', child: Text('Set Closed')),
              ],
            ),
          );
        },
      ),
    );
  }
}
