import 'package:neobazaar/core/state/async_status.dart';

class CampaignsManagementState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> campaigns;
  final String? error;

  const CampaignsManagementState({
    this.status = AsyncStatus.initial,
    this.campaigns = const <Map<String, dynamic>>[],
    this.error,
  });

  CampaignsManagementState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? campaigns,
    String? error,
    bool clearError = false,
  }) {
    return CampaignsManagementState(
      status: status ?? this.status,
      campaigns: campaigns ?? this.campaigns,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
