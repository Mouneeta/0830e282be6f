import '../entities/analytics_entity.dart';
import '../repository/device_repository.dart';

class FetchAnalyticsUseCase {
  final DeviceRepository repository;

  FetchAnalyticsUseCase(this.repository);

  Future<AnalyticsEntity> execute() async {
    return await repository.getDeviceVitalsAnalytics();
  }
}
