import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:neobazaar/features/notifications/presentation/state/notifications_center_state.dart';

final notificationsCenterNotifierProvider =
    NotifierProvider<NotificationsCenterNotifier, NotificationsCenterState>(
      NotificationsCenterNotifier.new,
    );

class NotificationsCenterNotifier extends Notifier<NotificationsCenterState> {
  @override
  NotificationsCenterState build() {
    Future<void>.microtask(loadNotifications);
    return const NotificationsCenterState();
  }

  Future<void> loadNotifications() async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(status: AsyncStatus.loading, clearError: true);

    try {
      final datasource = ref.read(notificationsRemoteDatasourceProvider);
      final notifications = await datasource.listNotifications(
        query: const <String, dynamic>{'limit': 50},
      );

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        status: AsyncStatus.success,
        notifications: notifications,
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

  Future<void> markRead(String notificationId) async {
    try {
      final datasource = ref.read(notificationsRemoteDatasourceProvider);
      await datasource.markNotificationRead(
        notificationId,
        const <String, dynamic>{},
      );

      final next = state.notifications
          .map((entry) {
            final id =
                entry['notificationId']?.toString() ?? entry['id']?.toString();
            if (id != notificationId) {
              return entry;
            }
            return <String, dynamic>{...entry, 'read': true, 'status': 'read'};
          })
          .toList(growable: false);

      state = state.copyWith(notifications: next, clearError: true);
    } catch (error) {
      state = state.copyWith(
        status: AsyncStatus.error,
        error: error.toString(),
      );
    }
  }

  Future<void> createNotification(Map<String, dynamic> payload) async {
    try {
      final datasource = ref.read(notificationsRemoteDatasourceProvider);
      final created = await datasource.createNotification(payload);
      state = state.copyWith(
        notifications: <Map<String, dynamic>>[created, ...state.notifications],
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
