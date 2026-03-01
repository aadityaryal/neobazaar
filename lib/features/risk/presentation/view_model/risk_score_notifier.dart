import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/capability_cache_provider.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/risk/data/datasources/remote/risk_remote_datasource.dart';
import 'package:neobazaar/features/risk/presentation/state/risk_score_state.dart';

final riskScoreNotifierProvider =
    NotifierProvider<RiskScoreNotifier, RiskScoreState>(RiskScoreNotifier.new);

class RiskScoreNotifier extends Notifier<RiskScoreState> {
  static const Set<String> _allowedCapabilities = <String>{
    'risk:view',
    'admin:risk:view',
    'admin:all',
  };

  @override
  RiskScoreState build() {
    final capabilities = ref.watch(capabilityCacheProvider);
    final isAuthorized = capabilities.hasAny(_allowedCapabilities);
    return RiskScoreState(isAuthorized: isAuthorized);
  }

  Future<void> fetchRiskScore(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: 'User id is required.',
      );
      return;
    }

    if (!state.isAuthorized) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: 'You are not authorized to view risk scores.',
      );
      return;
    }

    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(riskRemoteDatasourceProvider);
      final score = await datasource.getUserRiskScore(trimmedUserId);
      state = state.copyWith(
        status: AsyncStatus.success,
        score: score,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }
}
