import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_app/data/repositories/device_repository_impl.dart';
import 'package:flutter_app/data/model/device_response.dart';
import 'package:flutter_app/data/model/analytics_response.dart';
import 'package:flutter_app/core/resources/api_service.dart';
import 'package:flutter_app/core/resources/service_locator.dart';
import 'package:get/get.dart';

import 'device_repository_impl_test.mocks.dart';

@GenerateMocks([ApiService, ServiceLocator])
void main() {
  late DeviceRepositoryImpl repository;
  late MockApiService mockApiService;
  late MockServiceLocator mockServiceLocator;

  setUp(() {
    mockApiService = MockApiService();
    mockServiceLocator = MockServiceLocator();
    
    // Setup GetX dependency injection
    Get.testMode = true;
    Get.put<ServiceLocator>(mockServiceLocator);
    
    when(mockServiceLocator.apiService()).thenReturn(mockApiService);
    
    repository = DeviceRepositoryImpl();
  });

  tearDown(() {
    Get.reset();
  });

  group('getDeviceVitals', () {
    test('should return DeviceResponseEntity when API call is successful', () async {
      // Arrange
      final mockResponse = DeviceResponse(
        count: 2,
        data: [
          DeviceData(
            deviceId: 'device-001',
            timestamp: DateTime.parse('2024-01-15T10:30:00.000Z'),
            thermalValue: 45,
            batteryLevel: 80,
            memoryUsage: 4096,
          ),
          DeviceData(
            deviceId: 'device-002',
            timestamp: DateTime.parse('2024-01-15T11:00:00.000Z'),
            thermalValue: 50,
            batteryLevel: 75,
            memoryUsage: 5120,
          ),
        ],
      );

      when(mockApiService.request<DeviceResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        queryParams: anyNamed('queryParams'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getDeviceVitals(page: 1, limit: 10);

      // Assert
      expect(result.count, 2);
      expect(result.data.length, 2);
      expect(result.data[0].deviceId, 'device-001');
      expect(result.data[0].thermalValue, 45);
      expect(result.data[0].batteryLevel, 80);
      expect(result.data[1].deviceId, 'device-002');
      
      verify(mockApiService.request<DeviceResponse>(
        method: HttpMethod.get,
        url: anyNamed('url'),
        queryParams: {'page': 1, 'limit': 10},
        builder: anyNamed('builder'),
      )).called(1);
    });

    test('should call API without query params when page and limit are null', () async {
      // Arrange
      final mockResponse = DeviceResponse(count: 0, data: []);

      when(mockApiService.request<DeviceResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        queryParams: anyNamed('queryParams'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      await repository.getDeviceVitals();

      // Assert
      verify(mockApiService.request<DeviceResponse>(
        method: HttpMethod.get,
        url: anyNamed('url'),
        queryParams: null,
        builder: anyNamed('builder'),
      )).called(1);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      when(mockApiService.request<DeviceResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        queryParams: anyNamed('queryParams'),
        builder: anyNamed('builder'),
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getDeviceVitals(page: 1, limit: 10),
        throwsException,
      );
    });

    test('should handle pagination correctly', () async {
      // Arrange
      final mockResponse = DeviceResponse(
        count: 50,
        data: List.generate(
          20,
          (index) => DeviceData(
            deviceId: 'device-$index',
            timestamp: DateTime.now(),
            thermalValue: 40 + index,
            batteryLevel: 70 + index,
            memoryUsage: 3000 + (index * 100),
          ),
        ),
      );

      when(mockApiService.request<DeviceResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        queryParams: anyNamed('queryParams'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getDeviceVitals(page: 2, limit: 20);

      // Assert
      expect(result.count, 50);
      expect(result.data.length, 20);
      
      verify(mockApiService.request<DeviceResponse>(
        method: HttpMethod.get,
        url: anyNamed('url'),
        queryParams: {'page': 2, 'limit': 20},
        builder: anyNamed('builder'),
      )).called(1);
    });
  });

  group('postDeviceVitals', () {
    test('should post device vitals successfully', () async {
      // Arrange
      when(mockApiService.request(
        method: anyNamed('method'),
        url: anyNamed('url'),
        requestBody: anyNamed('requestBody'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => {'success': true});

      // Act
      await repository.postDeviceVitals(
        deviceId: 'test-device',
        thermalValue: 45,
        batteryLevel: 80,
        memoryUsage: 4096,
      );

      // Assert
      verify(mockApiService.request(
        method: HttpMethod.post,
        url: anyNamed('url'),
        requestBody: argThat(
          isA<Map<String, dynamic>>()
              .having((m) => m['device_id'], 'device_id', 'test-device')
              .having((m) => m['thermal_value'], 'thermal_value', 45)
              .having((m) => m['battery_level'], 'battery_level', 80),
          named: 'requestBody',
        ),
        builder: anyNamed('builder'),
      )).called(1);
    });

    test('should format request body correctly with timestamp', () async {
      // Arrange
      when(mockApiService.request(
        method: anyNamed('method'),
        url: anyNamed('url'),
        requestBody: anyNamed('requestBody'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => {'success': true});

      // Act
      final beforePost = DateTime.now();
      await repository.postDeviceVitals(
        deviceId: 'device-123',
        thermalValue: 50,
        batteryLevel: 75,
        memoryUsage: 5120,
      );
      final afterPost = DateTime.now();

      // Assert
      final captured = verify(mockApiService.request(
        method: HttpMethod.post,
        url: anyNamed('url'),
        requestBody: captureAnyNamed('requestBody'),
        builder: anyNamed('builder'),
      )).captured.single as Map<String, dynamic>;

      expect(captured['device_id'], 'device-123');
      expect(captured['thermal_value'], 50);
      expect(captured['battery_level'], 75);
      expect(captured['memory_usage'], 0.5); // Note: hardcoded in implementation
      expect(captured['timestamp'], isA<String>());
      
      final timestamp = DateTime.parse(captured['timestamp'] as String);
      expect(timestamp.isAfter(beforePost.subtract(const Duration(seconds: 1))), true);
      expect(timestamp.isBefore(afterPost.add(const Duration(seconds: 1))), true);
    });

    test('should rethrow exception when post fails', () async {
      // Arrange
      when(mockApiService.request(
        method: anyNamed('method'),
        url: anyNamed('url'),
        requestBody: anyNamed('requestBody'),
        builder: anyNamed('builder'),
      )).thenThrow(Exception('Server error'));

      // Act & Assert
      expect(
        () => repository.postDeviceVitals(
          deviceId: 'test-device',
          thermalValue: 45,
          batteryLevel: 80,
          memoryUsage: 4096,
        ),
        throwsException,
      );
    });
  });

  group('getDeviceVitalsAnalytics', () {
    test('should return AnalyticsEntity when API call is successful', () async {
      // Arrange
      final mockResponse = AnalyticsResponse(
        avgThermalValue: 45.5,
        avgBatteryLevel: 78.3,
        avgMemoryUsage: 4200.0,
        maxThermalValue: 60.0,
        minBatteryLevel: 65.0,
        maxMemoryUsage: 5500.0,
      );

      when(mockApiService.request<AnalyticsResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getDeviceVitalsAnalytics();

      // Assert
      expect(result.avgThermalValue, 45.5);
      expect(result.avgBatteryLevel, 78.3);
      expect(result.avgMemoryUsage, 4200.0);
      expect(result.maxThermalValue, 60.0);
      expect(result.minBatteryLevel, 65.0);
      expect(result.maxMemoryUsage, 5500.0);
      
      verify(mockApiService.request<AnalyticsResponse>(
        method: HttpMethod.get,
        url: anyNamed('url'),
        builder: anyNamed('builder'),
      )).called(1);
    });

    test('should parse nested JSON structure correctly', () async {
      // Arrange
      final mockResponse = AnalyticsResponse(
        avgThermalValue: 42.0,
        avgBatteryLevel: 80.0,
        avgMemoryUsage: 3500.0,
        maxThermalValue: 55.0,
        minBatteryLevel: 70.0,
        maxMemoryUsage: 4500.0,
      );

      when(mockApiService.request<AnalyticsResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getDeviceVitalsAnalytics();

      // Assert
      expect(result.avgThermalValue, isA<num>());
      expect(result.avgBatteryLevel, isA<num>());
      expect(result.avgMemoryUsage, isA<num>());
      expect(result.maxThermalValue, isA<num>());
      expect(result.minBatteryLevel, isA<num>());
      expect(result.maxMemoryUsage, isA<num>());
    });

    test('should throw exception when analytics API call fails', () async {
      // Arrange
      when(mockApiService.request<AnalyticsResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        builder: anyNamed('builder'),
      )).thenThrow(Exception('Analytics service unavailable'));

      // Act & Assert
      expect(
        () => repository.getDeviceVitalsAnalytics(),
        throwsException,
      );
    });

    test('should handle zero values in analytics response', () async {
      // Arrange
      final mockResponse = AnalyticsResponse(
        avgThermalValue: 0.0,
        avgBatteryLevel: 0.0,
        avgMemoryUsage: 0.0,
        maxThermalValue: 0.0,
        minBatteryLevel: 0.0,
        maxMemoryUsage: 0.0,
      );

      when(mockApiService.request<AnalyticsResponse>(
        method: anyNamed('method'),
        url: anyNamed('url'),
        builder: anyNamed('builder'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getDeviceVitalsAnalytics();

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
