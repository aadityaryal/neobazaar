import 'dart:math' as math;

class SensorVector {
  final double x;
  final double y;
  final double z;

  const SensorVector({required this.x, required this.y, required this.z});

  double get magnitude => math.sqrt(x * x + y * y + z * z);
}

class DeviceSensorSnapshot {
  final SensorVector accelerometer;
  final SensorVector gyroscope;
  final SensorVector magnetometer;
  final DateTime sampledAt;

  const DeviceSensorSnapshot({
    required this.accelerometer,
    required this.gyroscope,
    required this.magnetometer,
    required this.sampledAt,
  });
}
