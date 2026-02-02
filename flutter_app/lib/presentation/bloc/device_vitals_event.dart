import 'package:equatable/equatable.dart';

abstract class DeviceVitalsEvent extends Equatable {
  const DeviceVitalsEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeviceVitals extends DeviceVitalsEvent {
  final int? page;
  final int? limit;
  
  const FetchDeviceVitals({this.page, this.limit});
  
  @override
  List<Object?> get props => [page, limit];
}

class RefreshDeviceVitals extends DeviceVitalsEvent {
  const RefreshDeviceVitals();
}

class LoadMoreDeviceVitals extends DeviceVitalsEvent {
  final int page;
  final int limit;
  
  const LoadMoreDeviceVitals({required this.page, required this.limit});
  
  @override
  List<Object?> get props => [page, limit];
}

class PostDeviceVitals extends DeviceVitalsEvent {
  final String deviceId;
  final int thermalValue;
  final int batteryLevel;
  final int memoryUsage;

  const PostDeviceVitals({
    required this.deviceId,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  @override
  List<Object> get props => [deviceId, thermalValue, batteryLevel, memoryUsage];
}

class FetchAnalytics extends DeviceVitalsEvent {
  const FetchAnalytics();
}
