import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/model/analytics_response.dart';

void main() {
  group('AnalyticsResponse', () {
    test('fromJson should parse nested JSON structure correctly', () {
      // Arrange
      final json = {
        'rolling_average': {
          'thermal': 45.5,
          'battery': 78.3,
          'memory': 4200.0,
        },
        'min': {
          'thermal': 30.0,
          'battery': 65.0,
          'memory': 3000.0,
        },
        'max': {
          'thermal': 60.0,
          'battery': 95.0,
          'memory': 5500.0,
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 45.5);
      expect(result.avgBatteryLevel, 78.3);
      expect(result.avgMemoryUsage, 4200.0);
      expect(result.maxThermalValue, 60.0);
      expect(result.minBatteryLevel, 65.0);
      expect(result.maxMemoryUsage, 5500.0);
    });

    test('fromJson should handle missing rolling_average with default values', () {
      // Arrange
      final json = {
        'min': {
          'thermal': 30.0,
          'battery': 65.0,
          'memory': 3000.0,
        },
        'max': {
          'thermal': 60.0,
          'battery': 95.0,
          'memory': 5500.0,
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 0.0);
      expect(result.avgBatteryLevel, 0.0);
      expect(result.avgMemoryUsage, 0.0);
      expect(result.maxThermalValue, 60.0);
      expect(result.minBatteryLevel, 65.0);
      expect(result.maxMemoryUsage, 5500.0);
    });

    test('fromJson should handle missing min with default values', () {
      // Arrange
      final json = {
        'rolling_average': {
          'thermal': 45.5,
          'battery': 78.3,
          'memory': 4200.0,
        },
        'max': {
          'thermal': 60.0,
          'battery': 95.0,
          'memory': 5500.0,
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 45.5);
      expect(result.avgBatteryLevel, 78.3);
      expect(result.avgMemoryUsage, 4200.0);
      expect(result.maxThermalValue, 60.0);
      expect(result.minBatteryLevel, 0.0);
      expect(result.maxMemoryUsage, 5500.0);
    });

    test('fromJson should handle missing max with default values', () {
      // Arrange
      final json = {
        'rolling_average': {
          'thermal': 45.5,
          'battery': 78.3,
          'memory': 4200.0,
        },
        'min': {
          'thermal': 30.0,
          'battery': 65.0,
          'memory': 3000.0,
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 45.5);
      expect(result.avgBatteryLevel, 78.3);
      expect(result.avgMemoryUsage, 4200.0);
      expect(result.maxThermalValue, 0.0);
      expect(result.minBatteryLevel, 65.0);
      expect(result.maxMemoryUsage, 0.0);
    });

    test('fromJson should handle completely empty JSON with all defaults', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 0.0);
      expect(result.avgBatteryLevel, 0.0);
      expect(result.avgMemoryUsage, 0.0);
      expect(result.maxThermalValue, 0.0);
      expect(result.minBatteryLevel, 0.0);
      expect(result.maxMemoryUsage, 0.0);
    });

    test('fromJson should handle missing nested fields with defaults', () {
      // Arrange
      final json = {
        'rolling_average': {
          'thermal': 45.5,
          // battery missing
          'memory': 4200.0,
        },
        'min': {
          // thermal missing
          'battery': 65.0,
          'memory': 3000.0,
        },
        'max': {
          'thermal': 60.0,
          'battery': 95.0,
          // memory missing
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 45.5);
      expect(result.avgBatteryLevel, 0.0);
      expect(result.avgMemoryUsage, 4200.0);
      expect(result.maxThermalValue, 60.0);
      expect(result.minBatteryLevel, 65.0);
      expect(result.maxMemoryUsage, 0.0);
    });

    test('fromJson should convert integer values to double', () {
      // Arrange
      final json = {
        'rolling_average': {
          'thermal': 45,
          'battery': 78,
          'memory': 4200,
        },
        'min': {
          'thermal': 30,
          'battery': 65,
          'memory': 3000,
        },
        'max': {
          'thermal': 60,
          'battery': 95,
          'memory': 5500,
        },
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, isA<double>());
      expect(result.avgBatteryLevel, isA<double>());
      expect(result.avgMemoryUsage, isA<double>());
      expect(result.maxThermalValue, isA<double>());
      expect(result.minBatteryLevel, isA<double>());
      expect(result.maxMemoryUsage, isA<double>());
      expect(result.avgThermalValue, 45.0);
      expect(result.avgBatteryLevel, 78.0);
    });

    test('fromJson should handle null nested objects', () {
      // Arrange
      final json = {
        'rolling_average': null,
        'min': null,
        'max': null,
      };

      // Act
      final result = AnalyticsResponse.fromJson(json);

      // Assert
      expect(result.avgThermalValue, 0.0);
      expect(result.avgBatteryLevel, 0.0);
      expect(result.avgMemoryUsage, 0.0);
      expect(result.maxThermalValue, 0.0);
      expect(result.minBatteryLevel, 0.0);
      expect(result.maxMemoryUsage, 0.0);
    });
  });
}
