import 'dart:developer';

import 'package:flutter_app/data/model/analytics_response.dart';
import 'package:flutter_app/data/model/device_response.dart';
import 'package:flutter_app/domain/entities/analytics_entity.dart';
import 'package:flutter_app/domain/entities/device_data_entity.dart';
import 'package:flutter_app/domain/entities/device_response_entity.dart';
import 'package:flutter_app/domain/repository/device_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../core/resources/api_service.dart';
import '../../core/resources/service_locator.dart';
import '../data_source/remote/remote_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {

  final api = Get.find<ServiceLocator>().apiService();

  @override
  Future<DeviceResponseEntity> getDeviceVitals({int? page, int? limit}) async {
    try {
      log('Repository - getDeviceVitals called: page=$page, limit=$limit');
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      log('Repository - Making API request to ${RemoteEndpoint.getDeviceVitals}');
      final response = await api.request(
        method: HttpMethod.get,
        url: RemoteEndpoint.getDeviceVitals,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        builder: (data) {
          log('API Response Data: $data'); // Debug log
          log('Repository - API response received');
          
          if (data == null) {
            throw Exception('API returned null data');
          }
          
          // Handle if data is already a Map
          if (data is Map<String, dynamic>) {
            return DeviceResponse.fromJson(data);
          }
          
          throw Exception('Unexpected data type: ${data.runtimeType}');
        },
      );

      log('Repository - Mapping response to entity');
      return _mapToEntity(response);
    } catch (e) {
      log('Repository - Error in getDeviceVitals: $e');
      throw Exception(e);
    }
  }
  
  DeviceResponseEntity _mapToEntity(DeviceResponse response) {
    return DeviceResponseEntity(
      count: response.count,
      data: response.data.map((deviceData) => DeviceDataEntity(
        deviceId: deviceData.deviceId,
        timestamp: deviceData.timestamp,
        thermalValue: deviceData.thermalValue,
        batteryLevel: deviceData.batteryLevel,
        memoryUsage: deviceData.memoryUsage,
      )).toList(),
    );
  }
  
  DeviceResponseEntity _getMockData() {
    return DeviceResponseEntity(
      count: 1,
      data: [
        DeviceDataEntity(
          deviceId: 'MOCK-DEVICE-001',
          timestamp: DateTime.now(),
          thermalValue: 42,
          batteryLevel: 85,
          memoryUsage: 4200, // 4.2 GB in MB
        ),
      ],
    );
  }



  @override
  Future<void> postDeviceVitals({
    required String deviceId,
    required int thermalValue,
    required int batteryLevel,
    required int memoryUsage,
  }) async {
    try {
      final requestBody = {
        'device_id':  deviceId,
        'timestamp':  DateTime.now().toIso8601String(),
        'thermal_value':  thermalValue,
        'battery_level':  batteryLevel,
        'memory_usage':  0.5, // memoryUsage,
      };
      
      log('Posting device vitals: $requestBody');
      
      await api.request(
        method: HttpMethod.post,
        url: RemoteEndpoint.postDeviceVitals,
        requestBody: requestBody,
        builder: (data) {
          log('Post response: $data');
          return data;
        },
      );
      
      log('Device vitals posted successfully');
    } catch (e) {
      log('Error posting device vitals: $e');
      rethrow;
    }
  }

  @override
  Future<AnalyticsEntity> getDeviceVitalsAnalytics() async {
    try {
      log('Repository - getDeviceVitalsAnalytics called');
      log('Repository - Making API request to ${RemoteEndpoint.getDeviceVitalsAnalytics}');
      final response = await api.request(
        method: HttpMethod.get,
        url: RemoteEndpoint.getDeviceVitalsAnalytics,
        builder: (data) {
          log('Analytics API Response: $data');
          log('Repository - Analytics API response received');
          
          if (data == null) {
            throw Exception('API returned null data');
          }
          
          if (data is Map<String, dynamic>) {
            return AnalyticsResponse.fromJson(data);
          }
          
          throw Exception('Unexpected data type: ${data.runtimeType}');
        },
      );
      
      log('Repository - Mapping analytics response to entity');
      return AnalyticsEntity(
        avgThermalValue: response.avgThermalValue,
        avgBatteryLevel: response.avgBatteryLevel,
        avgMemoryUsage: response.avgMemoryUsage,
        maxThermalValue: response.maxThermalValue,
        minBatteryLevel: response.minBatteryLevel,
        maxMemoryUsage: response.maxMemoryUsage,
      );
    } catch (e) {
      log('Repository - Error in getDeviceVitalsAnalytics: $e');
      throw Exception(e);
    }
  }


}