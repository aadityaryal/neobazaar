import 'dart:async';

import 'package:neobazaar/core/services/sensors/device_sensor_models.dart';
import 'package:sensors_plus/sensors_plus.dart';

abstract interface class IDeviceSensorService {
  Stream<DeviceSensorSnapshot> watchSnapshots();
}

class DeviceSensorService implements IDeviceSensorService {
  final Stream<AccelerometerEvent> Function() _accelerometerFactory;
  final Stream<GyroscopeEvent> Function() _gyroscopeFactory;
  final Stream<MagnetometerEvent> Function() _magnetometerFactory;

  DeviceSensorService({
    Stream<AccelerometerEvent> Function()? accelerometerFactory,
    Stream<GyroscopeEvent> Function()? gyroscopeFactory,
    Stream<MagnetometerEvent> Function()? magnetometerFactory,
  }) : _accelerometerFactory =
           accelerometerFactory ?? (() => accelerometerEventStream()),
       _gyroscopeFactory = gyroscopeFactory ?? (() => gyroscopeEventStream()),
       _magnetometerFactory =
           magnetometerFactory ?? (() => magnetometerEventStream());

  @override
  Stream<DeviceSensorSnapshot> watchSnapshots() {
    final accelerometer = _accelerometerFactory().map(
      (event) => SensorVector(x: event.x, y: event.y, z: event.z),
    );
    final gyroscope = _gyroscopeFactory().map(
      (event) => SensorVector(x: event.x, y: event.y, z: event.z),
    );
    final magnetometer = _magnetometerFactory().map(
      (event) => SensorVector(x: event.x, y: event.y, z: event.z),
    );

    return combineSensorStreams(
      accelerometer: accelerometer,
      gyroscope: gyroscope,
      magnetometer: magnetometer,
    );
  }
}

Stream<DeviceSensorSnapshot> combineSensorStreams({
  required Stream<SensorVector> accelerometer,
  required Stream<SensorVector> gyroscope,
  required Stream<SensorVector> magnetometer,
}) {
  return Stream<DeviceSensorSnapshot>.multi((controller) {
    StreamSubscription<SensorVector>? accelerometerSub;
    StreamSubscription<SensorVector>? gyroscopeSub;
    StreamSubscription<SensorVector>? magnetometerSub;

    SensorVector? latestAccelerometer;
    SensorVector? latestGyroscope;
    SensorVector? latestMagnetometer;

    void emitSnapshot() {
      final accelerometer = latestAccelerometer;
      final gyroscope = latestGyroscope;
      final magnetometer = latestMagnetometer;

      if (accelerometer == null || gyroscope == null || magnetometer == null) {
        return;
      }

      controller.add(
        DeviceSensorSnapshot(
          accelerometer: accelerometer,
          gyroscope: gyroscope,
          magnetometer: magnetometer,
          sampledAt: DateTime.now(),
        ),
      );
    }

    try {
      accelerometerSub = accelerometer.listen((vector) {
        latestAccelerometer = vector;
        emitSnapshot();
      }, onError: controller.addError);

      gyroscopeSub = gyroscope.listen((vector) {
        latestGyroscope = vector;
        emitSnapshot();
      }, onError: controller.addError);

      magnetometerSub = magnetometer.listen((vector) {
        latestMagnetometer = vector;
        emitSnapshot();
      }, onError: controller.addError);
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }

    controller.onCancel = () async {
      await Future.wait<void>([
        if (accelerometerSub != null) accelerometerSub.cancel(),
        if (gyroscopeSub != null) gyroscopeSub.cancel(),
        if (magnetometerSub != null) magnetometerSub.cancel(),
      ]);
    };
  });
}
