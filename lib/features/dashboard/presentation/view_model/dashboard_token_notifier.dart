import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/features/dashboard/presentation/state/dashboard_token_state.dart';

final dashboardTokenNotifierProvider =
    NotifierProvider<DashboardTokenNotifier, DashboardTokenState>(
      DashboardTokenNotifier.new,
    );

class DashboardTokenNotifier extends Notifier<DashboardTokenState> {
  @override
  DashboardTokenState build() {
    final session = ref.watch(appSessionProvider);
    final tokens = session.user?.neoTokens ?? 0;
    return DashboardTokenState(tokenBalance: tokens);
  }

  void syncTokenBalance(int tokenBalance) {
    state = state.copyWith(tokenBalance: tokenBalance);
  }
}
