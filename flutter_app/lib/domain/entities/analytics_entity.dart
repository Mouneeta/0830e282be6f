class AnalyticsEntity {
  final num avgThermalValue;
  final num avgBatteryLevel;
  final num avgMemoryUsage;
  final num maxThermalValue;
  final num minBatteryLevel;
  final num maxMemoryUsage;

  AnalyticsEntity({
    required this.avgThermalValue,
    required this.avgBatteryLevel,
    required this.avgMemoryUsage,
    required this.maxThermalValue,
    required this.minBatteryLevel,
    required this.maxMemoryUsage,
  });
}
