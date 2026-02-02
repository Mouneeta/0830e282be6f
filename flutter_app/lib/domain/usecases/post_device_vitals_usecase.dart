import '../repository/device_repository.dart';

class PostDeviceVitalsUseCase {
  final DeviceRepository repository;

  PostDeviceVitalsUseCase(this.repository);

  Future<void> execute({
    required String deviceId,
    required int thermalValue,
    required int batteryLevel,
    required int memoryUsage,
  }) async {
    return await repository.postDeviceVitals(
      deviceId: deviceId,
      thermalValue: thermalValue,
      batteryLevel: batteryLevel,
      memoryUsage: memoryUsage,
    );
  }
}
