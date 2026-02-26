import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/services/analytics/analytics_service.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:neobazaar/features/auth/presentation/view_model/profile_view_model.dart';
import 'package:neobazaar/features/dashboard/presentation/view_model/dashboard_token_notifier.dart';
import 'package:neobazaar/features/quests/data/datasources/remote/quests_remote_datasource.dart';
import 'package:neobazaar/features/quests/presentation/state/quests_state.dart';

final questsNotifierProvider = NotifierProvider<QuestsNotifier, QuestsState>(
  QuestsNotifier.new,
);

class QuestsNotifier extends Notifier<QuestsState> {
  late final AnalyticsService _analyticsService;

  @override
  QuestsState build() {
    _analyticsService = ref.read(analyticsServiceProvider);
    Future<void>.microtask(loadQuests);
    return const QuestsState();
  }

  Future<void> loadQuests() async {
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);
    _analyticsService.track('quests_load_started');

    try {
      final datasource = ref.read(questsRemoteDatasourceProvider);
      final quests = await datasource.listQuests(
        query: const <String, dynamic>{'limit': 50},
      );
      state = state.copyWith(
        status: AsyncStatus.success,
        quests: quests,
        clearError: true,
      );
      _analyticsService.track(
        'quests_load_success',
        properties: {'count': quests.length},
      );
    } catch (error) {
      _analyticsService.track(
        'quests_load_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> createQuest(Map<String, dynamic> payload) async {
    try {
      _analyticsService.track('quest_create_started');
      final datasource = ref.read(questsRemoteDatasourceProvider);
      final created = await datasource.createQuest(payload);
      state = state.copyWith(
        quests: <Map<String, dynamic>>[created, ...state.quests],
        clearError: true,
      );
      _analyticsService.track('quest_create_success');
    } catch (error) {
      _analyticsService.track(
        'quest_create_error',
        properties: {'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> completeQuest(String questId) async {
    try {
      _analyticsService.track(
        'quest_complete_started',
        properties: {'questId': questId},
      );
      final datasource = ref.read(questsRemoteDatasourceProvider);
      final updated = await datasource.completeQuest(
        questId,
        const <String, dynamic>{},
      );
      final rewardTokens = _readInt(updated, <String>[
        'neoTokens',
        'tokenBalance',
        'balance',
      ]);
      final rewardXp = _readInt(updated, <String>['xp', 'experience']);

      final next = state.quests
          .map((quest) {
            final id = quest['questId']?.toString() ?? quest['id']?.toString();
            if (id != questId) {
              return quest;
            }
            return <String, dynamic>{...quest, ...updated, 'completed': true};
          })
          .toList(growable: false);

      state = state.copyWith(
        quests: next,
        showCompletionConfetti: true,
        clearError: true,
      );
      _analyticsService.track(
        'quest_complete_success',
        properties: {
          'questId': questId,
          'tokens': rewardTokens,
          'xp': rewardXp,
        },
      );

      _syncRewardProgress(neoTokens: rewardTokens, xp: rewardXp);
    } catch (error) {
      _analyticsService.track(
        'quest_complete_error',
        properties: {'questId': questId, 'message': error.toString()},
      );
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  void consumeConfetti() {
    if (!state.showCompletionConfetti) {
      return;
    }
    state = state.copyWith(showCompletionConfetti: false);
  }

  void _syncRewardProgress({int? neoTokens, int? xp}) {
    if (neoTokens == null && xp == null) {
      return;
    }

    final session = ref.read(appSessionProvider);
    final currentUser = session.user;
    if (currentUser != null) {
      final updatedUser = AuthEntity(
        authId: currentUser.authId,
        fullName: currentUser.fullName,
        email: currentUser.email,
        phoneNumber: currentUser.phoneNumber,
        username: currentUser.username,
        password: currentUser.password,
        neoTokens: neoTokens ?? currentUser.neoTokens,
        xp: xp ?? currentUser.xp,
        reputationScore: currentUser.reputationScore,
        kycVerified: currentUser.kycVerified,
        badges: currentUser.badges,
        campus: currentUser.campus,
        location: currentUser.location,
        profilePicture: currentUser.profilePicture,
      );

      ref.read(appSessionProvider.notifier).syncUser(updatedUser);
      ref.read(authViewModelProvider.notifier).syncProfile(updatedUser);
      ref
          .read(profileViewModelProvider.notifier)
          .syncProgress(neoTokens: neoTokens, xp: xp);
    }

    if (neoTokens != null) {
      ref
          .read(dashboardTokenNotifierProvider.notifier)
          .syncTokenBalance(neoTokens);
    }
  }

  int? _readInt(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final parsed = int.tryParse(source[key]?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }
}
