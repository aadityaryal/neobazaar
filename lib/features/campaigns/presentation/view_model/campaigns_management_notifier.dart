import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/campaigns/data/datasources/remote/campaigns_remote_datasource.dart';
import 'package:neobazaar/features/campaigns/presentation/state/campaigns_management_state.dart';

final campaignsManagementNotifierProvider =
    NotifierProvider<CampaignsManagementNotifier, CampaignsManagementState>(
      CampaignsManagementNotifier.new,
    );

class CampaignsManagementNotifier extends Notifier<CampaignsManagementState> {
  @override
  CampaignsManagementState build() {
    Future<void>.microtask(loadCampaigns);
    return const CampaignsManagementState();
  }

  Future<void> loadCampaigns() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(campaignsRemoteDatasourceProvider);
      final campaigns = await datasource.listCampaigns(
        query: const <String, dynamic>{'limit': 50},
      );

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        status: AsyncStatus.success,
        campaigns: campaigns,
        clearError: true,
      );
    } catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> createCampaign(Map<String, dynamic> payload) async {
    try {
      final datasource = ref.read(campaignsRemoteDatasourceProvider);
      final created = await datasource.createCampaign(payload);
      state = state.copyWith(
        campaigns: <Map<String, dynamic>>[created, ...state.campaigns],
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> updateStatus(String campaignId, String statusValue) async {
    try {
      final datasource = ref.read(campaignsRemoteDatasourceProvider);
      final updated = await datasource.updateCampaignStatus(
        campaignId,
        <String, dynamic>{'status': statusValue},
      );

      final next = state.campaigns
          .map((campaign) {
            final id =
                campaign['campaignId']?.toString() ??
                campaign['id']?.toString();
            if (id != campaignId) {
              return campaign;
            }
            return <String, dynamic>{...campaign, ...updated};
          })
          .toList(growable: false);

      state = state.copyWith(campaigns: next, clearError: true);
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }
}
