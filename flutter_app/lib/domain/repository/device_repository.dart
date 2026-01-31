import '../entities/analytics_entity.dart';
import '../entities/device_response_entity.dart';

abstract class DeviceRepository {
  Future<DeviceResponseEntity> getDeviceVitals({int? page, int? limit});

  Future<void> postDeviceVitals({
    required String deviceId,
    required int thermalValue,
    required int batteryLevel,
    required int memoryUsage,
  });

  Future<AnalyticsEntity> getDeviceVitalsAnalytics();
}
