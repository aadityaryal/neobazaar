import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/leaderboard/presentation/view_model/leaderboard_notifier.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardNotifierProvider);

    return DefaultTabController(
      length: LeaderboardNotifier.tabs.length,
      initialIndex: LeaderboardNotifier.tabs.indexOf(state.tab),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: TabBar(
            onTap: (index) {
              final tab = LeaderboardNotifier.tabs[index];
              ref.read(leaderboardNotifierProvider.notifier).loadTab(tab);
            },
            tabs: const [
              Tab(text: 'Global'),
              Tab(text: 'Local'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            if (state.status == AsyncStatus.loading && state.entries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AsyncStatus.error && state.entries.isEmpty) {
              return Center(
                child: Text(state.error ?? 'Unable to load leaderboard.'),
              );
            }

            if (state.entries.isEmpty) {
              return const Center(child: Text('No leaderboard entries.'));
            }

            return RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(leaderboardNotifierProvider.notifier)
                    .loadTab(state.tab);
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.entries.length,
                itemBuilder: (context, index) {
                  final row = state.entries[index];
                  final name =
                      row['name']?.toString() ??
                      row['username']?.toString() ??
                      '-';
                  final score =
                      row['score']?.toString() ?? row['xp']?.toString() ?? '-';
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(name),
                    trailing: Text(score),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
