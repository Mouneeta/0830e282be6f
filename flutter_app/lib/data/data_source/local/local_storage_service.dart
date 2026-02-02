import 'dart:developer';
import 'package:hive/hive.dart';
import '../../../core/storage/device_vitals_hive_model.dart';

class LocalStorageService {
  static const String _boxName = 'device_vitals';
  Box<DeviceVitalsHiveModel>? _box;

  // Initialize the box
  Future<void> init() async {
    try {
      _box = await Hive.openBox<DeviceVitalsHiveModel>(_boxName);
      log('LocalStorageService: Box opened successfully');
    } catch (e) {
      log('LocalStorageService: Error opening box: $e');
      rethrow;
    }
  }

  // Get the box instance
  Box<DeviceVitalsHiveModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Box is not initialized. Call init() first.');
    }
    return _box!;
  }

  // Save multiple device vitals (replace all)
  Future<void> saveDeviceVitals(List<DeviceVitalsHiveModel> vitals) async {
    try {
      await box.clear();
      await box.addAll(vitals);
      log('LocalStorageService: Saved ${vitals.length} device vitals');
    } catch (e) {
      log('LocalStorageService: Error saving device vitals: $e');
      rethrow;
    }
  }

  // Add a single device vital
  Future<void> addDeviceVital(DeviceVitalsHiveModel vital) async {
    try {
      await box.add(vital);
      log('LocalStorageService: Added device vital for ${vital.deviceId}');
    } catch (e) {
      log('LocalStorageService: Error adding device vital: $e');
      rethrow;
    }
  }

  // Get all device vitals
  List<DeviceVitalsHiveModel> getDeviceVitals() {
    try {
      final vitals = box.values.toList();
      log('LocalStorageService: Retrieved ${vitals.length} device vitals');
      return vitals;
    } catch (e) {
      log('LocalStorageService: Error getting device vitals: $e');
      return [];
    }
  }

  // Get device vitals with pagination
  List<DeviceVitalsHiveModel> getDeviceVitalsPaginated({
    required int page,
    required int limit,
  }) {
    try {
      final allVitals = box.values.toList();
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= allVitals.length) {
        return [];
      }

      final paginatedVitals = allVitals.sublist(
        startIndex,
        endIndex > allVitals.length ? allVitals.length : endIndex,
      );

      log('LocalStorageService: Retrieved page $page with ${paginatedVitals.length} items');
      return paginatedVitals;
    } catch (e) {
      log('LocalStorageService: Error getting paginated vitals: $e');
      return [];
    }
  }

  // Get count of stored vitals
  int getCount() {
    try {
      return box.length;
    } catch (e) {
      log('LocalStorageService: Error getting count: $e');
      return 0;
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    try {
      await box.clear();
      log('LocalStorageService: Cleared all device vitals');
    } catch (e) {
      log('LocalStorageService: Error clearing data: $e');
      rethrow;
    }
  }

  // Close the box
  Future<void> close() async {
    try {
      await _box?.close();
      log('LocalStorageService: Box closed');
    } catch (e) {
      log('LocalStorageService: Error closing box: $e');
    }
  }
}
