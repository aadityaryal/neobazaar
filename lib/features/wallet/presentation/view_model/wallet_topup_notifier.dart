import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/services/storage/user_session_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:neobazaar/features/dashboard/presentation/view_model/dashboard_token_notifier.dart';
import 'package:neobazaar/features/wallet/data/datasources/remote/wallet_remote_datasource.dart';
import 'package:neobazaar/features/wallet/presentation/state/wallet_topup_state.dart';

final walletTopupNotifierProvider =
    NotifierProvider<WalletTopupNotifier, WalletTopupState>(
      WalletTopupNotifier.new,
    );

class WalletTopupNotifier extends Notifier<WalletTopupState> {
  static const List<String> providers = <String>['esewa', 'khalti', 'imepay'];
  AnalyticsService get _analyticsService => ref.read(analyticsServiceProvider);

  @override
  WalletTopupState build() {
    final tokens = ref.watch(appSessionProvider).user?.neoTokens ?? 0;
    return WalletTopupState(currentTokenBalance: tokens);
  }

  void setAmount(int amount) {
    state = state.copyWith(amount: amount, clearError: true);
  }

  void setProvider(String provider) {
    if (!providers.contains(provider)) {
      return;
    }
    state = state.copyWith(provider: provider, clearError: true);
  }

  Future<void> topUp() async {
    if (state.amount <= 0) {
      _analyticsService.track(
        'wallet_topup_validation_error',
        properties: {'amount': state.amount},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: 'Enter a valid top-up amount.',
      );
      return;
    }

    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track(
      'wallet_topup_started',
      properties: {'amount': state.amount, 'provider': state.provider},
    );

    final payload = <String, dynamic>{
      'amount': state.amount,
      'provider': state.provider,
    };

    try {
      final datasource = ref.read(walletRemoteDatasourceProvider);
      Map<String, dynamic> result;
      try {
        result = await datasource.topup(payload);
      } catch (_) {
        _analyticsService.track('wallet_topup_alias_fallback');
        result = await datasource.topupViaUserAlias(payload);
      }

      final nextBalance =
          _extractTokenBalance(result) ?? state.currentTokenBalance;
      _syncTokenBalance(nextBalance);

      state = state.copyWith(
        status: AsyncStatus.success,
        currentTokenBalance: nextBalance,
        clearError: true,
      );
      _analyticsService.track(
        'wallet_topup_success',
        properties: {'nextBalance': nextBalance},
      );
    } catch (error) {
      _analyticsService.track(
        'wallet_topup_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  void _syncTokenBalance(int balance) {
    final session = ref.read(appSessionProvider);
    final currentUser = session.user;
    if (currentUser != null) {
      final updatedUser = _withUpdatedTokens(currentUser, balance);
      ref.read(appSessionProvider.notifier).syncUser(updatedUser);
      ref.read(authViewModelProvider.notifier).syncProfile(updatedUser);
      ref.read(profileViewModelProvider.notifier).syncTokenBalance(balance);
    }

    // Keep local session fallback in sync with latest backend wallet state.
    ref.read(userSessionServiceProvider).saveNeoTokens(balance);

    ref.read(dashboardTokenNotifierProvider.notifier).syncTokenBalance(balance);
  }

  AuthEntity _withUpdatedTokens(AuthEntity user, int balance) {
    return AuthEntity(
      authId: user.authId,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      username: user.username,
      password: user.password,
      neoTokens: balance,
      xp: user.xp,
      reputationScore: user.reputationScore,
      kycVerified: user.kycVerified,
      badges: user.badges,
      campus: user.campus,
      location: user.location,
      profilePicture: user.profilePicture,
    );
  }

  int? _extractTokenBalance(Map<String, dynamic> response) {
    final candidates = <dynamic>[
      response['neoTokens'],
      response['tokenBalance'],
      response['balance'],
      response['tokens'],
      (response['wallet'] is Map
          ? (response['wallet'] as Map)['balance']
          : null),
    ];

    for (final candidate in candidates) {
      final asInt = int.tryParse(candidate?.toString() ?? '');
      if (asInt != null) {
        return asInt;
      }
    }

    return null;
  }
}
