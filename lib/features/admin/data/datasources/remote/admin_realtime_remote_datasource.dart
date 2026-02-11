import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/providers/websocket_event_dispatcher_provider.dart';
import 'package:neobazaar/features/admin/data/datasources/admin_realtime_datasource.dart';

final adminRealtimeDatasourceProvider = Provider<IAdminRealtimeDatasource>((
  ref,
) {
  return AdminRealtimeRemoteDatasource(
    eventDispatcher: ref.read(websocketEventDispatcherProvider),
  );
});

class AdminRealtimeRemoteDatasource implements IAdminRealtimeDatasource {
  final WebSocketEventDispatcher _eventDispatcher;

  AdminRealtimeRemoteDatasource({
    required WebSocketEventDispatcher eventDispatcher,
  }) : _eventDispatcher = eventDispatcher;

  @override
  Stream<Map<String, dynamic>> watchFlagUpdatedEvents() {
    return _watchByType('admin:flag.updated.v1');
  }

  @override
  Stream<Map<String, dynamic>> watchDisputeDecidedEvents() {
    return _watchByType('admin:dispute.decided.v1');
  }

  Stream<Map<String, dynamic>> _watchByType(String type) {
    return _eventDispatcher.watchAll().where((event) => event.type == type).map(
      (event) {
        final payload = _asMap(event.payload);
        return <String, dynamic>{
          'type': event.type,
          'scope': event.scope,
          'payload': payload,
          'receivedAt': event.receivedAt.toIso8601String(),
        };
      },
    );
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
}
