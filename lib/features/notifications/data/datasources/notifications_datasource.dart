abstract interface class INotificationsRemoteDatasource {
  Future<List<Map<String, dynamic>>> listNotifications({
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> markNotificationRead(
    String notificationId,
    Map<String, dynamic> payload,
  );
}
