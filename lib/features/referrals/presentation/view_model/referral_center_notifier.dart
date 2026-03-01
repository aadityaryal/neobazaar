import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/referrals/data/datasources/remote/referrals_remote_datasource.dart';
import 'package:neobazaar/features/referrals/presentation/state/referral_center_state.dart';

final referralCenterNotifierProvider =
    NotifierProvider<ReferralCenterNotifier, ReferralCenterState>(
      ReferralCenterNotifier.new,
    );

class ReferralCenterNotifier extends Notifier<ReferralCenterState> {
  @override
  ReferralCenterState build() {
    Future<void>.microtask(loadReferrals);
    return const ReferralCenterState();
  }

  Future<void> loadReferrals() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(referralsRemoteDatasourceProvider);
      final referrals = await datasource.listReferrals(
        query: const <String, dynamic>{'limit': 50},
      );

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        status: AsyncStatus.success,
        referrals: referrals,
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

  Future<void> createReferral(Map<String, dynamic> payload) async {
    try {
      final datasource = ref.read(referralsRemoteDatasourceProvider);
      final created = await datasource.createReferral(payload);

      state = state.copyWith(
        referrals: <Map<String, dynamic>>[created, ...state.referrals],
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> qualifyReferral(String referralId) async {
    try {
      final datasource = ref.read(referralsRemoteDatasourceProvider);
      final updated = await datasource.qualifyReferral(
        referralId,
        const <String, dynamic>{},
      );

      final next = state.referrals
          .map((referral) {
            final id =
                referral['referralId']?.toString() ??
                referral['id']?.toString();
            if (id != referralId) {
              return referral;
            }
            return <String, dynamic>{...referral, ...updated};
          })
          .toList(growable: false);

      state = state.copyWith(referrals: next, clearError: true);
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }
}
