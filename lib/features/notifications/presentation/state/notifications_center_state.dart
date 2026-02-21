import 'package:neobazaar/core/state/async_status.dart';

class NotificationsCenterState {
  final AsyncStatus status;
  final List<Map<String, dynamic>> notifications;
  final String? error;

  const NotificationsCenterState({
    this.status = AsyncStatus.initial,
    this.notifications = const <Map<String, dynamic>>[],
    this.error,
  });

  NotificationsCenterState copyWith({
    AsyncStatus? status,
    List<Map<String, dynamic>>? notifications,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsCenterState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
