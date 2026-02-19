import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/notifications/data/datasources/notifications_datasource.dart';

final notificationsRemoteDatasourceProvider =
    Provider<INotificationsRemoteDatasource>((ref) {
      return NotificationsRemoteDatasource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class NotificationsRemoteDatasource implements INotificationsRemoteDatasource {
  final ApiClient _apiClient;

  NotificationsRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> listNotifications({
    Map<String, dynamic>? query,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: query,
    );

    return _apiClient.parseDataEnvelope<List<Map<String, dynamic>>>(
      response,
      _asListOfMaps,
    );
  }

  @override
  Future<Map<String, dynamic>> createNotification(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.notifications,
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  @override
  Future<Map<String, dynamic>> markNotificationRead(
    String notificationId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.notificationRead(notificationId),
      data: payload,
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(response, _asMap);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{'value': value};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    final list = value is List ? value : <dynamic>[];
    return list.whereType<Map>().map((item) => _asMap(item)).toList();
  }
}
