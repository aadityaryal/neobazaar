import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/notifications/presentation/services/notification_deep_link_resolver.dart';
import 'package:neobazaar/features/notifications/presentation/state/notifications_center_state.dart';
import 'package:neobazaar/features/notifications/presentation/view_model/notifications_center_notifier.dart';

class NotificationsCenterPage extends ConsumerWidget {
  const NotificationsCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsCenterNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NotificationsCenterState state,
  ) {
    if (state.status == AsyncStatus.loading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AsyncStatus.error && state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error ?? 'Unable to load notifications.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(notificationsCenterNotifierProvider.notifier)
                    .loadNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty) {
      return const Center(child: Text('No notifications yet.'));
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(notificationsCenterNotifierProvider.notifier)
            .loadNotifications();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          final id =
              notification['notificationId']?.toString() ??
              notification['id']?.toString() ??
              '';
          final title = notification['title']?.toString() ?? 'Notification';
          final description =
              notification['message']?.toString() ??
              notification['description']?.toString() ??
              '';
          final isRead =
              (notification['read'] as bool?) ??
              notification['status']?.toString().toLowerCase() == 'read';

          return ListTile(
            title: Text(title),
            subtitle: description.isEmpty
                ? null
                : Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
            onTap: () {
              final page = ref
                  .read(notificationDeepLinkResolverProvider)
                  .resolve(notification);
              if (page != null) {
                AppRoutes.push(context, page);
              }
            },
            trailing: isRead
                ? const Icon(Icons.done_all, size: 18)
                : TextButton(
                    onPressed: id.isEmpty
                        ? null
                        : () {
                            ref
                                .read(
                                  notificationsCenterNotifierProvider.notifier,
                                )
                                .markRead(id);
                          },
                    child: const Text('Mark read'),
                  ),
          );
        },
      ),
    );
  }
}
