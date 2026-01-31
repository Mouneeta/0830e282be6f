import 'package:equatable/equatable.dart';
import 'device_data_entity.dart';

class DeviceResponseEntity extends Equatable {
  final int count;
  final List<DeviceDataEntity> data;

  const DeviceResponseEntity({
    required this.count,
    required this.data,
  });

  @override
  List<Object> get props => [count, data];
}
