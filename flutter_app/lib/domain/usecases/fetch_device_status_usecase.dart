import '../entities/device_response_entity.dart';
import '../repository/device_repository.dart';


class FetchDeviceStatusUseCase {
  final DeviceRepository repository;

  FetchDeviceStatusUseCase(this.repository);

  Future<DeviceResponseEntity> execute({int? page, int? limit}) async {
    return await repository.getDeviceVitals(page: page, limit: limit);
  }
}
