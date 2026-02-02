import 'package:hive/hive.dart';

part 'device_vitals_hive_model.g.dart';

@HiveType(typeId: 0)
class DeviceVitalsHiveModel extends HiveObject {
  @HiveField(0)
  String deviceId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  num thermalValue;

  @HiveField(3)
  num batteryLevel;

  @HiveField(4)
  num memoryUsage;

  DeviceVitalsHiveModel({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  // Convert from entity to Hive model
  factory DeviceVitalsHiveModel.fromEntity(dynamic entity) {
    return DeviceVitalsHiveModel(
      deviceId: entity.deviceId,
      timestamp: entity.timestamp,
      thermalValue: entity.thermalValue,
      batteryLevel: entity.batteryLevel,
      memoryUsage: entity.memoryUsage,
    );
  }

  // Convert to map for easy usage
  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'thermal_value': thermalValue,
      'battery_level': batteryLevel,
      'memory_usage': memoryUsage,
    };
  }
}
