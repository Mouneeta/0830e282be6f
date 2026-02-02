import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/model/device_response.dart';

void main() {
  group('DeviceResponse', () {
    test('fromJson should parse valid JSON correctly', () {
      // Arrange
      final json = {
        'count': 2,
        'data': [
          {
            'device_id': 'device-001',
            'timestamp': '2024-01-15T10:30:00.000Z',
            'thermal_value': 45,
            'battery_level': 80,
            'memory_usage': 4096,
          },
          {
            'device_id': 'device-002',
            'timestamp': '2024-01-15T11:00:00.000Z',
            'thermal_value': 50,
            'battery_level': 75,
            'memory_usage': 5120,
          },
        ],
      };

      // Act
      final result = DeviceResponse.fromJson(json);

      // Assert
      expect(result.count, 2);
      expect(result.data.length, 2);
      expect(result.data[0].deviceId, 'device-001');
      expect(result.data[0].thermalValue, 45);
      expect(result.data[0].batteryLevel, 80);
      expect(result.data[0].memoryUsage, 4096);
      expect(result.data[1].deviceId, 'device-002');
    });

    test('fromJson should handle missing count field with default value', () {
      // Arrange
      final json = {
        'data': [],
      };

      // Act
      final result = DeviceResponse.fromJson(json);

      // Assert
      expect(result.count, 0);
      expect(result.data, isEmpty);
    });

    test('fromJson should handle null data field with empty list', () {
      // Arrange
      final json = {
        'count': 5,
        'data': null,
      };

      // Act
      final result = DeviceResponse.fromJson(json);

      // Assert
      expect(result.count, 5);
      expect(result.data, isEmpty);
    });

    test('toJson should convert DeviceResponse to JSON correctly', () {
      // Arrange
      final deviceResponse = DeviceResponse(
        count: 1,
        data: [
          DeviceData(
            deviceId: 'test-device',
            timestamp: DateTime.parse('2024-01-15T10:30:00.000Z'),
            thermalValue: 42,
            batteryLevel: 85,
            memoryUsage: 3072,
          ),
        ],
      );

      // Act
      final json = deviceResponse.toJson();

      // Assert
      expect(json['count'], 1);
      expect(json['data'], isA<List>());
      expect(json['data'].length, 1);
      expect(json['data'][0]['device_id'], 'test-device');
    });
  });

  group('DeviceData', () {
    test('fromJson should parse valid JSON correctly', () {
      // Arrange
      final json = {
        'device_id': 'device-123',
        'timestamp': '2024-01-15T10:30:00.000Z',
        'thermal_value': 48,
        'battery_level': 90,
        'memory_usage': 2048,
      };

      // Act
      final result = DeviceData.fromJson(json);

      // Assert
      expect(result.deviceId, 'device-123');
      expect(result.timestamp, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(result.thermalValue, 48);
      expect(result.batteryLevel, 90);
      expect(result.memoryUsage, 2048);
    });

    test('fromJson should handle missing fields with default values', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final result = DeviceData.fromJson(json);

      // Assert
      expect(result.deviceId, '');
      expect(result.timestamp, isA<DateTime>());
      expect(result.thermalValue, 0);
      expect(result.batteryLevel, 0);
      expect(result.memoryUsage, 0);
    });

    test('fromJson should handle null timestamp with current time', () {
      // Arrange
      final json = {
        'device_id': 'device-456',
        'timestamp': null,
        'thermal_value': 40,
        'battery_level': 70,
        'memory_usage': 1024,
      };

      // Act
      final before = DateTime.now();
      final result = DeviceData.fromJson(json);
      final after = DateTime.now();

      // Assert
      expect(result.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), true);
      expect(result.timestamp.isBefore(after.add(const Duration(seconds: 1))), true);
    });

    test('fromJson should parse timestamp string correctly', () {
      // Arrange
      final json = {
        'device_id': 'device-789',
        'timestamp': '2024-12-25T15:45:30.123Z',
        'thermal_value': 55,
        'battery_level': 60,
        'memory_usage': 6144,
      };

      // Act
      final result = DeviceData.fromJson(json);

      // Assert
      expect(result.timestamp.year, 2024);
      expect(result.timestamp.month, 12);
      expect(result.timestamp.day, 25);
      expect(result.timestamp.hour, 15);
      expect(result.timestamp.minute, 45);
    });

    test('toJson should convert DeviceData to JSON correctly', () {
      // Arrange
      final deviceData = DeviceData(
        deviceId: 'test-device-001',
        timestamp: DateTime.parse('2024-01-15T10:30:00.000Z'),
        thermalValue: 42,
        batteryLevel: 85,
        memoryUsage: 3072,
      );

      // Act
      final json = deviceData.toJson();

      // Assert
      expect(json['device_id'], 'test-device-001');
      expect(json['timestamp'], '2024-01-15T10:30:00.000Z');
      expect(json['thermal_value'], 42);
      expect(json['battery_level'], 85);
      expect(json['memory_usage'], 3072);
    });

    test('fromJson should handle numeric device_id by converting to string', () {
      // Arrange
      final json = {
        'device_id': 12345,
        'timestamp': '2024-01-15T10:30:00.000Z',
        'thermal_value': 45,
        'battery_level': 80,
        'memory_usage': 4096,
      };

      // Act
      final result = DeviceData.fromJson(json);

      // Assert
      expect(result.deviceId, '12345');
    });
  });
}
