import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:neobazaar/core/constants/app_constants.dart';
import 'package:neobazaar/core/services/sensors/device_sensor_models.dart';
import 'package:neobazaar/core/services/sensors/device_sensor_service.dart';

enum DeviceSensorStatus { disabled, loading, active, unavailable }

class DeviceSensorState {
  final DeviceSensorStatus status;
  final DeviceSensorSnapshot? snapshot;
  final String? message;

  const DeviceSensorState({required this.status, this.snapshot, this.message});

  const DeviceSensorState.disabled()
    : status = DeviceSensorStatus.disabled,
      snapshot = null,
      message = 'Disabled by feature flag';

  const DeviceSensorState.loading()
    : status = DeviceSensorStatus.loading,
      snapshot = null,
      message = 'Waiting for sensor data';

  const DeviceSensorState.unavailable(String this.message)
    : status = DeviceSensorStatus.unavailable,
      snapshot = null;

  const DeviceSensorState.active(DeviceSensorSnapshot this.snapshot)
    : status = DeviceSensorStatus.active,
      message = null;
}

final deviceSensorServiceProvider = Provider<IDeviceSensorService>((ref) {
  return DeviceSensorService();
});

final deviceSensorStateProvider = StreamProvider<DeviceSensorState>((
  ref,
) async* {
  if (!AppConstants.isFeatureEnabled('device_sensors')) {
    yield const DeviceSensorState.disabled();
    return;
  }

  yield const DeviceSensorState.loading();

  try {
    final service = ref.watch(deviceSensorServiceProvider);
    await for (final snapshot in service.watchSnapshots()) {
      yield DeviceSensorState.active(snapshot);
    }
  } catch (error) {
    yield DeviceSensorState.unavailable(error.toString());
  }
});
