import 'dart:developer';

import 'package:flutter_app/data/data_source/local/local_storage_service.dart';
import 'package:flutter_app/data/model/analytics_response.dart';
import 'package:flutter_app/data/model/device_response.dart';
import 'package:flutter_app/domain/entities/analytics_entity.dart';
import 'package:flutter_app/domain/entities/device_data_entity.dart';
import 'package:flutter_app/domain/entities/device_response_entity.dart';
import 'package:flutter_app/domain/repository/device_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_it/get_it.dart';
import '../../core/resources/api_service.dart';
import '../../core/resources/service_locator.dart';
import '../../core/storage/device_vitals_hive_model.dart';
import '../data_source/remote/remote_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {

  final api = Get.find<ServiceLocator>().apiService();
  final _localStorage = GetIt.instance<LocalStorageService>();

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
          log('API Response Data: $data');
          log('Repository - API response received');
          
          if (data == null) {
            throw Exception('API returned null data');
          }
          
          if (data is Map<String, dynamic>) {
            return DeviceResponse.fromJson(data);
          }
          
          throw Exception('Unexpected data type: ${data.runtimeType}');
        },
      );

      log('Repository - Mapping response to entity');
      final entity = _mapToEntity(response);
      
      // Save to local storage for offline access
      try {
        final hiveModels = response.data.map((deviceData) => 
          DeviceVitalsHiveModel(
            deviceId: deviceData.deviceId,
            timestamp: deviceData.timestamp,
            thermalValue: deviceData.thermalValue,
            batteryLevel: deviceData.batteryLevel,
            memoryUsage: deviceData.memoryUsage,
          )
        ).toList();
        
        await _localStorage.saveDeviceVitals(hiveModels);
        log('Repository - Saved ${hiveModels.length} vitals to local storage');
      } catch (e) {
        log('Repository - Error saving to local storage: $e');
        // Don't throw, just log - we still have the API data
      }
      
      return entity;
    } catch (e) {
      log('Repository - Error in getDeviceVitals: $e');
      log('Repository - Attempting to load from local storage');
      
      // Fallback to local storage when API fails
      try {
        final localVitals = _localStorage.getDeviceVitals();
        
        if (localVitals.isEmpty) {
          log('Repository - No local data available');
          throw Exception('No internet connection and no cached data available');
        }
        
        log('Repository - Loaded ${localVitals.length} vitals from local storage');
        
        // Convert Hive models to entities
        final entities = localVitals.map((hiveModel) => DeviceDataEntity(
          deviceId: hiveModel.deviceId,
          timestamp: hiveModel.timestamp,
          thermalValue: hiveModel.thermalValue,
          batteryLevel: hiveModel.batteryLevel,
          memoryUsage: hiveModel.memoryUsage,
        )).toList();
        
        return DeviceResponseEntity(
          count: entities.length,
          data: entities,
        );
      } catch (localError) {
        log('Repository - Error loading from local storage: $localError');
        throw Exception('Failed to load data: $e');
      }
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
      
      // Save posted vital to local storage
      try {
        final hiveModel = DeviceVitalsHiveModel(
          deviceId: deviceId,
          timestamp: DateTime.now(),
          thermalValue: thermalValue,
          batteryLevel: batteryLevel,
          memoryUsage: memoryUsage,
        );
        
        await _localStorage.addDeviceVital(hiveModel);
        log('Repository - Saved posted vital to local storage');
      } catch (e) {
        log('Repository - Error saving posted vital to local storage: $e');
        // Don't throw, posting was successful
      }
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