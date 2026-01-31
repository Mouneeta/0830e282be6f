class DeviceResponse {
  final int count;
  final List<DeviceData> data;

  DeviceResponse({
    required this.count,
    required this.data,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing DeviceResponse from: $json'); // Debug log
    
    return DeviceResponse(
      count: json['count'] ?? 0,
      data: json['data'] != null && json['data'] is List
          ? List<DeviceData>.from(
              (json['data'] as List).map((x) => DeviceData.fromJson(x as Map<String, dynamic>)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'data': data.map((x) => x.toJson()).toList(),
  };
}

class DeviceData {
  final String deviceId;
  final DateTime timestamp;
  final int thermalValue;
  final int batteryLevel;
  final int memoryUsage;

  DeviceData({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    print('Parsing DeviceData from: $json'); // Debug log
    
    return DeviceData(
      deviceId: json['device_id']?.toString() ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      thermalValue: json['thermal_value'] ?? 0,
      batteryLevel: json['battery_level'] ?? 0,
      memoryUsage: json['memory_usage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'thermal_value': thermalValue,
    'battery_level': batteryLevel,
    'memory_usage': memoryUsage,
  };
}
