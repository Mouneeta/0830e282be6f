class AnalyticsResponse {
  final num avgThermalValue;
  final num avgBatteryLevel;
  final num avgMemoryUsage;
  final num maxThermalValue;
  final num minBatteryLevel;
  final num maxMemoryUsage;

  AnalyticsResponse({
    required this.avgThermalValue,
    required this.avgBatteryLevel,
    required this.avgMemoryUsage,
    required this.maxThermalValue,
    required this.minBatteryLevel,
    required this.maxMemoryUsage,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final rollingAverage = json['rolling_average'] as Map<String, dynamic>? ?? {};
    final min = json['min'] as Map<String, dynamic>? ?? {};
    final max = json['max'] as Map<String, dynamic>? ?? {};
    
    return AnalyticsResponse(
      avgThermalValue: (rollingAverage['thermal'] ?? 0).toDouble(),
      avgBatteryLevel: (rollingAverage['battery'] ?? 0).toDouble(),
      avgMemoryUsage: (rollingAverage['memory'] ?? 0).toDouble(),
      maxThermalValue: (max['thermal'] ?? 0).toDouble(),
      minBatteryLevel: (min['battery'] ?? 0).toDouble(),
      maxMemoryUsage: (max['memory'] ?? 0).toDouble(),
    );
  }
}
