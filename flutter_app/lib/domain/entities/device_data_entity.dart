import 'package:equatable/equatable.dart';

class DeviceDataEntity extends Equatable {
  final String deviceId;
  final DateTime timestamp;
  final int thermalValue;
  final int batteryLevel;
  final int memoryUsage;

  const DeviceDataEntity({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  @override
  List<Object> get props => [
    deviceId,
    timestamp,
    thermalValue,
    batteryLevel,
    memoryUsage,
  ];
}
