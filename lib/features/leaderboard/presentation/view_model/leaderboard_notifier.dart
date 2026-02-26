import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/leaderboard/data/datasources/remote/leaderboard_remote_datasource.dart';
import 'package:neobazaar/features/leaderboard/presentation/state/leaderboard_state.dart';

final leaderboardNotifierProvider =
    NotifierProvider<LeaderboardNotifier, LeaderboardState>(
      LeaderboardNotifier.new,
    );

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  static const List<String> tabs = <String>['global', 'local'];
  late final AnalyticsService _analyticsService;

  @override
  LeaderboardState build() {
    _analyticsService = ref.read(analyticsServiceProvider);
    Future<void>.microtask(() => loadTab('global'));
    return const LeaderboardState();
  }

  Future<void> loadTab(String tab) async {
    if (!tabs.contains(tab)) {
      return;
    }

    state = state.copyWith(
      status: AsyncStatus.loading,
      tab: tab,
      clearError: true,
    );
    _analyticsService.track(
      'leaderboard_tab_load_started',
      properties: {'tab': tab},
    );

    try {
      final datasource = ref.read(leaderboardRemoteDatasourceProvider);
      final entries = await datasource.listLeaderboard(tab: tab);
      state = state.copyWith(
        status: AsyncStatus.success,
        tab: tab,
        entries: entries,
        clearError: true,
      );
      _analyticsService.track(
        'leaderboard_tab_load_success',
        properties: {'tab': tab, 'count': entries.length},
      );
    } catch (error) {
      _analyticsService.track(
        'leaderboard_tab_load_error',
        properties: {'tab': tab, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }
}
