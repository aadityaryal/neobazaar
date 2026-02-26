import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/core/utils/route_guards.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/features/quests/presentation/view_model/quests_notifier.dart';

class QuestsPage extends ConsumerWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questsNotifierProvider);
    final canCreateQuest = adminGuard(ref).allowed;

    ref.listen(questsNotifierProvider, (previous, next) {
      if (next.showCompletionConfetti) {
        SnackbarUtils.showSuccess(context, 'Quest completed! Rewards synced.');
        ref.read(questsNotifierProvider.notifier).consumeConfetti();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quests')),
      floatingActionButton: canCreateQuest
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(questsNotifierProvider.notifier).createQuest(
                  <String, dynamic>{
                    'title': 'New Quest',
                    'description': 'Auto-created from app panel',
                    'rewardTokens': 25,
                    'rewardXP': 15,
                    'activeUntil': DateTime.now()
                        .add(const Duration(days: 14))
                        .toUtc()
                        .toIso8601String(),
                  },
                );
              },
              icon: const Icon(Icons.add_task),
              label: const Text('Create'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(questsNotifierProvider.notifier).loadQuests(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (state.status == AsyncStatus.loading && state.quests.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (state.status == AsyncStatus.error && state.quests.isEmpty)
              Center(child: Text(state.error ?? 'Unable to load quests.'))
            else if (state.quests.isEmpty)
              const Text('No quests available.')
            else
              ...state.quests.map((quest) {
                final questId =
                    quest['questId']?.toString() ??
                    quest['id']?.toString() ??
                    '';
                final title = quest['title']?.toString() ?? 'Quest';
                final description = quest['description']?.toString() ?? '';
                final isCompleted = (quest['completed'] as bool?) ?? false;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isCompleted ? Icons.verified : Icons.flag_outlined,
                    ),
                    title: Text(title),
                    subtitle: description.isEmpty ? null : Text(description),
                    trailing: TextButton(
                      onPressed: isCompleted || questId.isEmpty
                          ? null
                          : () {
                              ref
                                  .read(questsNotifierProvider.notifier)
                                  .completeQuest(questId);
                            },
                      child: Text(isCompleted ? 'Completed' : 'Complete'),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
